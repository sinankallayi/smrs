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

  Stream<List<LeaveRequestModel>> getLeaves(UserModel user) {
    Query<Map<String, dynamic>> query = _leavesColl;

    if (user.role == AppRoles.staff) {
      // Optimization for staff: just their own leaves
      query = query.where('userId', isEqualTo: user.id);
    } else if (user.role == AppRoles.sectionHead) {
      // Section Heads: OWN leaves OR (Relevant leaves AND same section)
      // This strict check prevents seeing leaves from other sections even if 'sectionHead' is in relevantRoles
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
      // For others (Management, etc), show leaves they created OR leaves relevant to them
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

  Future<void> createLeave(LeaveRequestModel leave) async {
    // Fetch dynamic initial state
    final flowService = ref.read(leaveFlowServiceProvider.notifier);
    final initialState = await flowService.getInitialState(leave.userRole);

    LeaveRequestModel newLeave = leave;

    if (initialState != null) {
      // Dynamic Flow
      newLeave = leave.copyWith(
        currentApproverRoles: initialState.approverRoles,
        currentViewerRoles: initialState.viewerRoles,
        relevantRoles: [
          ...initialState.approverRoles,
          ...initialState.viewerRoles,
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
          status: LeaveStatus.forwarded,
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
        // Move to next step
        nextApprovers = nextState.approverRoles;
        nextViewers = nextState.viewerRoles;
        nextStepIndex = nextState.stepIndex;
        nextStepName = nextState.stepName;

        newStatus = LeaveStatus.forwarded;
        if (actor.role == AppRoles.sectionHead) {
          newStatus = LeaveStatus.sectionHeadForwarded;
        } else if (actor.role == AppRoles.management) {
          // Logic for intermediate management steps?
        }
      } else {
        // End of workflow -> Approved
        newStatus = LeaveStatus.approved;
        // Clear approvers as no further action needed
        nextApprovers = [];
      }
    }

    final timelineEntry = TimelineEntry(
      byUserId: actor.id,
      byUserName: actor.name,
      byUserRole: actor.role,
      byUserSection: actor.section,
      byUserEmployeeId: actor.employeeId, // Capture Employee ID
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
