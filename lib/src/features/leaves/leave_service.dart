import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/leave_request_model.dart';
import '../../models/user_model.dart';
import '../configuration/leave_flow_service.dart';

part 'leave_service.g.dart';

@riverpod
class LeaveService extends _$LeaveService {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _leavesColl =>
      FirebaseFirestore.instance.collection('leaves');

  /// Helper to dynamically resolve role placeholders like 'sectionHead'
  /// to the specific section name (e.g. 'bakery').
  List<String> _resolveRoles(List<String> roles, String? section) {
    if (section == null || section.isEmpty) return roles;
    return roles.map((role) {
      if (role == AppRoles.sectionHead) {
        return section; // Replace 'sectionHead' with the actual section name
      }
      return role;
    }).toList();
  }

  Stream<List<LeaveRequestModel>> getLeaves(UserModel user) {
    Query<Map<String, dynamic>> query = _leavesColl;

    if (user.role == AppRoles.staff) {
      // Optimization for staff: just their own leaves
      query = query.where('userId', isEqualTo: user.id);
    } else if (user.role == AppRoles.manager) {
      // "Manager" Visibility:
      // 1. GLOBAL: Sees ALL Staff Leaves (Monitoring)
      // 2. ASSIGNED: Sees Section Head / HR Leaves ONLY if assigned in Config (relevantRoles)
      query = query.where(
        Filter.or(
          Filter('userRole', isEqualTo: AppRoles.staff),
          Filter('relevantRoles', arrayContains: user.role),
        ),
      );
    } else {
      // For others (Section Heads, HR, Management):
      // Robust Query: Check multiple case variations of the user's role OR Section
      // This ensures that "Manager" user can see leaves assigned to "manager" config,
      // AND "Finance" manager can see leaves assigned to "Finance" approver.
      // And Section Heads can see leaves from other sections if they are configured as approvers.
      final searchTerms = <String>{
        user.role,
        user.role.toLowerCase(),
        user.role.toLowerCase().replaceAll(' ', ''),
      };

      if (user.section != null && user.section!.isNotEmpty) {
        final sec = user.section!.trim();
        final role = user.role.trim();

        searchTerms.add(sec);
        searchTerms.add(sec.toLowerCase());

        // Combinatorial: "Finance" + "Manager" -> "Finance Manager"
        final compositeBase = '$sec $role';
        searchTerms.add(compositeBase); // As-is
        searchTerms.add(compositeBase.toLowerCase());
        searchTerms.add(compositeBase.replaceAll(' ', '').toLowerCase());

        // Ensure Title Case Composite (Critical for Config matching: "Finance Manager")
        if (sec.isNotEmpty && role.isNotEmpty) {
          final secTitle =
              sec[0].toUpperCase() + sec.substring(1).toLowerCase();
          final roleTitle =
              role[0].toUpperCase() + role.substring(1).toLowerCase();
          searchTerms.add('$secTitle $roleTitle');
        }
      }

      query = query.where(
        Filter.or(
          Filter('userId', isEqualTo: user.id),
          Filter('relevantRoles', arrayContainsAny: searchTerms.toList()),
        ),
      );
    }

    return query.orderBy('appliedAt', descending: true).snapshots().map((qs) {
      return qs.docs
          .map((doc) => LeaveRequestModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> createLeave(LeaveRequestModel leave) async {
    // Fetch dynamic initial state
    // Fetch dynamic initial state
    final flowService = ref.read(leaveFlowServiceProvider.notifier);

    // Heuristic: If user is "Manager" but has a Section, treat as Section Head for workflow lookup
    // This ensures we load the "Section Head" configuration (with HR approver) instead of generic Manager float.
    String configRole = leave.userRole;
    final normalizedRole = leave.userRole.toLowerCase();

    // Check if role is effectively a section head (Manager with Section, or explicit Section Head)
    if (normalizedRole == AppRoles.sectionHead.toLowerCase() ||
        (normalizedRole.contains('manager') &&
            leave.userSection != null &&
            leave.userSection!.isNotEmpty)) {
      configRole = AppRoles.sectionHead;
    }

    final initialState = await flowService.getInitialState(configRole);

    LeaveRequestModel newLeave = leave;

    if (initialState != null) {
      // Dynamic Flow
      final resolvedApprovers = _resolveRoles(
        initialState.approverRoles,
        leave.userSection,
      );
      final resolvedViewers = _resolveRoles(
        initialState.viewerRoles,
        leave.userSection,
      );

      final allRelevantRoles = {...resolvedApprovers, ...resolvedViewers};

      // SAFETY: Ensure Management (Directors) AND HR ALWAYS have visibility of Section Head and Manager leaves
      if (leave.userRole != AppRoles.staff) {
        allRelevantRoles.add(AppRoles.management);
        allRelevantRoles.add(AppRoles.hr); // Enforce HR visibility

        // CRITICAL FIX: If no approvers defined in config, default to Management AND HR to prevent auto-approval and ensure actionability
        if (resolvedApprovers.isEmpty) {
          resolvedApprovers.add(AppRoles.management);
          resolvedApprovers.add(AppRoles.hr);
        }
      }

      // Robust Visibility: Expand relevantRoles to include lowercase/normalized variations
      // This handles mismatches like "Store Manager" vs "storeManager" vs "store manager".
      final expandedRelevantRoles = <String>{};
      for (final role in allRelevantRoles) {
        expandedRelevantRoles.add(role);
        expandedRelevantRoles.add(role.toLowerCase());
        expandedRelevantRoles.add(role.toLowerCase().replaceAll(' ', ''));
      }

      newLeave = leave.copyWith(
        currentApproverRoles: resolvedApprovers,
        currentViewerRoles: resolvedViewers,
        relevantRoles: expandedRelevantRoles.toList(),
        currentStepIndex: initialState.stepIndex,
        currentStepName: initialState.stepName,
      );
    } else {
      // Fallback to legacy logic if no flow configured
      if (leave.userRole != AppRoles.staff) {
        // Default: Managament Review for non-staff
        newLeave = leave.copyWith(
          currentStage: LeaveStage.managementReview,
          relevantRoles: [
            AppRoles.management,
            AppRoles.hr,
          ], // Explicitly grant Management & HR visibility
          currentApproverRoles: [
            AppRoles.management,
            AppRoles.hr,
          ], // Ensure Pending status (not auto-approved) and HR can act
        );
      }
    }

    await _leavesColl.doc(newLeave.id).set(newLeave.toJson());
  }

  Future<void> processAction({
    required LeaveRequestModel leave,
    required LeaveAction action,
    required UserModel actor,
    required String remark,
  }) async {
    // 1. Prepare Next State Variables (default to current)
    // CRITICAL: Make a mutable copy so we can remove actors from the pending list.
    List<String> nextApprovers = List<String>.from(leave.currentApproverRoles);
    List<String> nextViewers = leave.currentViewerRoles;
    int nextStepIndex = leave.currentStepIndex;
    String? nextStepName = leave.currentStepName;
    LeaveStage nextStage = leave.currentStage;

    // 2. Determine Action Logic
    if (action == LeaveAction.reject) {
      // HIERARCHY PROTECTION:
      // Rejection does not stop the workflow if Management has already approved (Override).

      // Parallel Action: Remove actor from pending list so they don't act again.
      if (nextApprovers.contains(actor.role)) {
        nextApprovers.remove(actor.role);
      }
    } else if (action == LeaveAction.approve || action == LeaveAction.forward) {
      final isManagement = actor.role == AppRoles.management;

      // Override Check: Management acting when NOT the current designated approver
      final isOverride =
          isManagement &&
          !leave.currentApproverRoles.contains(AppRoles.management);

      if (isOverride) {
        // MANAGEMENT OVERRIDE:
        // Status becomes Approved via Timeline logic.
        // We do NOT advance the step/stage.
      } else {
        // NORMAL FLOW (Parallel Approval Check)

        // A. Remove the acting role from the pending list
        if (nextApprovers.contains(actor.role)) {
          nextApprovers.remove(actor.role);
        }

        // B. Check if all approvers have acted
        if (nextApprovers.isEmpty) {
          // ALL Roles for this stage have acted. Move to NEXT STAGE.
          final flowService = ref.read(leaveFlowServiceProvider.notifier);

          // Check for Dynamic Flow
          final nextState = await flowService.getNextState(
            leave.userRole,
            leave.currentStepIndex,
          );

          if (nextState != null) {
            // --- DYNAMIC FLOW ---
            nextApprovers = _resolveRoles(
              nextState.approverRoles,
              leave.userSection,
            );
            nextViewers = _resolveRoles(
              nextState.viewerRoles,
              leave.userSection,
            );
            nextStepIndex = nextState.stepIndex;
            nextStepName = nextState.stepName;
          } else {
            // --- LEGACY FLOW FALLBACK ---
            if (leave.currentStage == LeaveStage.sectionHeadReview) {
              // Transition to Management Review
              nextStage = LeaveStage.managementReview;
              nextStepIndex = leave.currentStepIndex + 1;
              nextStepName = 'Management Review';
              nextApprovers = [
                AppRoles.management,
                AppRoles.hr,
                AppRoles.exd,
                AppRoles.md,
              ];
            } else if (leave.currentStage == LeaveStage.managementReview) {
              // End of Workflow
              nextApprovers = [];
            }
          }
        }

        // Management Finality Override within Normal Flow
        if (isManagement) {
          nextApprovers = [];
        }
      }
    }

    // 3. Create Timeline Entry
    final timelineEntry = TimelineEntry(
      byUserId: actor.id,
      byUserName: actor.name,
      byUserRole: actor.role,
      byUserSection: actor.section,
      byUserEmployeeId: actor.employeeId,
      status: action.name,
      remark: remark,
      date: DateTime.now(),
    );

    // 4. Update Leave
    final updatedTimeline = [...leave.timeline, timelineEntry];

    final updatedLeave = leave.copyWith(
      timeline: updatedTimeline,
      currentApproverRoles: nextApprovers,
      currentViewerRoles: nextViewers,
      relevantRoles: {
        ...leave.relevantRoles,
        ...nextApprovers, // Add new approvers
        ...nextViewers,
        actor.role, // Ensure actor remains relevant
      }.toList(),
      currentStepIndex: nextStepIndex,
      currentStepName: nextStepName,
      currentStage: nextStage,
    );

    // 5. Save to Firestore
    final json = updatedLeave.toJson();
    json['timeline'] = updatedLeave.timeline.map((e) => e.toJson()).toList();

    await _leavesColl.doc(leave.id).set(json, SetOptions(merge: true));
  }

  Future<void> deleteLeave(String leaveId) async {
    await _leavesColl.doc(leaveId).delete();
  }
}

enum LeaveAction { forward, approve, reject }
