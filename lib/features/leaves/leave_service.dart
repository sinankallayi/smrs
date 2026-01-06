import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../configuration/leave_flow_service.dart';

part 'leave_service.g.dart';

@riverpod
class LeaveService extends _$LeaveService {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _leavesColl =>
      FirebaseFirestore.instance.collection('leaves');

  Stream<List<LeaveRequestModel>> getLeaves(UserModel user) {
    Query<Map<String, dynamic>> query = _leavesColl;

    if (user.role == AppRoles.staff) {
      // Optimization for staff: just their own leaves
      query = query.where('userId', isEqualTo: user.id);
    } else if (user.role == AppRoles.sectionHead) {
      // Legacy Code Compatibility:
      // If we still have users with literal 'sectionHead' role (from old data) or if logic reverts.
      query = query.where(
        Filter.or(
          Filter('userId', isEqualTo: user.id),
          Filter.and(
            Filter('relevantRoles', arrayContains: user.role),
            Filter('userSection', isEqualTo: user.section),
          ),
        ),
      );
    } else {
      // For others (Management, specific Manager Roles like HR, and dynamic Section Heads like 'Kitchen'),
      // show leaves they created OR leaves relevant to them.
      // E.g. If user.role is 'Kitchen', and relevantRoles contains 'Kitchen', they see it.
      query = query.where(
        Filter.or(
          Filter('userId', isEqualTo: user.id),
          Filter('relevantRoles', arrayContains: user.role),
        ),
      );
    }

    return query.orderBy('appliedAt', descending: true).snapshots().map((qs) {
      return qs.docs
          .map((doc) => LeaveRequestModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Helper to resolve dynamic roles (e.g. converting 'sectionHead' -> 'Kitchen')
  List<String> _resolveRoles(List<String> roles, String? section) {
    if (section == null) return roles;
    return roles.map((r) {
      if (r == AppRoles.sectionHead) return section;
      return r;
    }).toList();
  }

  Future<void> createLeave(LeaveRequestModel leave) async {
    // Fetch dynamic initial state
    final flowService = ref.read(leaveFlowServiceProvider.notifier);
    final initialState = await flowService.getInitialState(leave.userRole);

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

      newLeave = leave.copyWith(
        currentApproverRoles: resolvedApprovers,
        currentViewerRoles: resolvedViewers,
        relevantRoles: [
          ...resolvedApprovers,
          ...resolvedViewers,
        ].toSet().toList(),
        currentStepIndex: initialState.stepIndex,
        currentStepName: initialState.stepName,
        status: LeaveStatus.pending,
      );
    } else {
      // Fallback to legacy logic if no flow configured
      if (leave.userRole != AppRoles.staff) {
        newLeave = leave.copyWith(
          currentStage: LeaveStage.managementReview,
          status: LeaveStatus.pending,
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
    LeaveStatus newStatus = leave.status;

    // Dynamic Logic
    List<String> nextApprovers = leave.currentApproverRoles;
    List<String> nextViewers = leave.currentViewerRoles;
    int nextStepIndex = leave.currentStepIndex;
    String? nextStepName = leave.currentStepName;

    if (action == LeaveAction.reject) {
      newStatus = LeaveStatus.rejected;
      // nextApprovers = []; // STOP: Don't clear. Allow others to act (Voting/Opinion).
    } else if (action == LeaveAction.approve || action == LeaveAction.forward) {
      // Calculate next step
      final flowService = ref.read(leaveFlowServiceProvider.notifier);
      final nextState = await flowService.getNextState(
        leave.userRole,
        leave.currentStepIndex,
      );

      if (nextState != null) {
        // Move to next step by default
        final resolvedApprovers = _resolveRoles(
          nextState.approverRoles,
          leave.userSection,
        );
        final resolvedViewers = _resolveRoles(
          nextState.viewerRoles,
          leave.userSection,
        );

        nextApprovers = resolvedApprovers;
        nextViewers = resolvedViewers;
        nextStepIndex = nextState.stepIndex;
        nextStepName = nextState.stepName;

        newStatus = LeaveStatus.pending;

        // If the actor is part of the "Management" group (Management only),
        // their Approval overrides any future steps defined in the config.
        final isManagementAuthority = [
          AppRoles.management,
        ].contains(actor.role);

        if (isManagementAuthority) {
          newStatus = LeaveStatus.approved;
          // Clear future approvers to prevent further actions
          nextApprovers = [];
        }
      } else {
        // End of workflow -> Approved
        newStatus = LeaveStatus.approved;
        // Clear approvers as no further action needed
        // nextApprovers = []; // Keep them empty or set to empty if not already?
        // Actually, if it's approved, we usually want to stop acts.
        nextApprovers = [];
      }
    }

    final timelineEntry = TimelineEntry(
      byUserId: actor.id,
      byUserName: actor.name,
      byUserRole: actor.role,
      byUserSection: actor.section,
      status: action.name,
      remark: remark,
      date: DateTime.now(),
    );

    final updatedTimeline = [...leave.timeline, timelineEntry];

    final updatedLeave = leave.copyWith(
      status: newStatus,
      timeline: updatedTimeline,
      currentApproverRoles: nextApprovers,
      currentViewerRoles: nextViewers,
      relevantRoles: {
        ...leave.relevantRoles,
        ...nextApprovers,
        ...nextViewers,
      }.toList(),
      currentStepIndex: nextStepIndex,
      currentStepName: nextStepName,
    );

    // Convert to JSON and save
    // Ensure all fields are valid for Firestore
    final json = updatedLeave.toJson();

    // Explicitly serialize nested objects (TimelineEntry) to Maps because generated code might miss this
    // without explicitToJson: true (which causes conflicts).
    json['timeline'] = updatedLeave.timeline.map((e) => e.toJson()).toList();

    await _leavesColl.doc(leave.id).set(json, SetOptions(merge: true));
  }

  Future<void> deleteLeave(String leaveId) async {
    await _leavesColl.doc(leaveId).delete();
  }
}

enum LeaveAction { forward, approve, reject }
