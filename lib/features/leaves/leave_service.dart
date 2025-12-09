import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';

part 'leave_service.g.dart';

@riverpod
class LeaveService extends _$LeaveService {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _leavesColl =>
      FirebaseFirestore.instance.collection('leaves');

  Stream<List<LeaveRequestModel>> getLeaves(UserModel user) {
    Query<Map<String, dynamic>> query = _leavesColl;

    if (user.role == UserRole.staff) {
      query = query.where('userId', isEqualTo: user.id);
    } else if (user.role == UserRole.sectionHead) {
      // Section Head: Leaves from their section
      if (user.section != null) {
        // Enforce Firestore Rule: resource.data.userSection == user.section
        query = query.where('userSection', isEqualTo: user.section!.name);
      }
    } else if ([UserRole.md, UserRole.exd, UserRole.hr].contains(user.role)) {
      // Management: Fetch ALL requests to support History view.
      // Client-side filtering will separate 'Pending' from 'History'.
      // query = query.where('currentStage', isEqualTo: 'management_review');
    }

    // Note: For complex multi-field queries, indexes will be needed.
    // We will do basic ordering here.
    return query.orderBy('appliedAt', descending: true).snapshots().map((qs) {
      final leaves = qs.docs
          .map((doc) => LeaveRequestModel.fromJson(doc.data()))
          .toList();

      // Additional In-Memory Filtering for Security/View Logic
      if (user.role == UserRole.sectionHead) {
        return leaves.where((l) => l.userSection == user.section).toList();
      }
      return leaves;
    });
  }

  Future<void> createLeave(LeaveRequestModel leave) async {
    await _leavesColl.doc(leave.id).set(leave.toJson());
  }

  Future<void> processAction({
    required LeaveRequestModel leave,
    required LeaveAction action,
    required UserModel actor,
    required String remark,
  }) async {
    LeaveStatus newStatus = leave.status;
    LeaveStage newStage = leave.currentStage;

    // State Machine Logic
    if (leave.currentStage == LeaveStage.sectionHeadReview) {
      // Step 2: Section Head Review
      if (action == LeaveAction.reject) {
        newStatus = LeaveStatus.rejected;
        newStage = LeaveStage.completed;
      } else if (action == LeaveAction.forward) {
        newStatus = LeaveStatus.forwarded;
        newStage = LeaveStage.managementReview;
      } else if (action == LeaveAction.approve) {
        newStatus = LeaveStatus.approved;
        newStage = LeaveStage.completed;
      }
    } else if (leave.currentStage == LeaveStage.managementReview) {
      // Step 3: Management Review
      if (action == LeaveAction.reject) {
        newStatus = LeaveStatus.rejected;
        newStage = LeaveStage.completed;
      } else if (action == LeaveAction.approve) {
        // "Grant"
        newStatus = LeaveStatus.managementApproved;
        newStage = LeaveStage.finalization;
      }
    } else if (leave.currentStage == LeaveStage.finalization) {
      // Step 4: Finalization
      if (action == LeaveAction.reject) {
        newStatus = LeaveStatus.rejected;
        newStage = LeaveStage.completed;
      } else if (action == LeaveAction.approve) {
        // "Finalize"
        newStatus = LeaveStatus.approved;
        newStage = LeaveStage.completed;
      }
    }

    final timelineEntry = TimelineEntry(
      byUserId: actor.id,
      byUserName: actor.name,
      byUserRole: actor.role.name,
      status: action.name,
      remark: remark,
      date: DateTime.now(),
    );

    final updatedTimeline = [...leave.timeline, timelineEntry];

    final updatedLeave = leave.copyWith(
      status: newStatus,
      currentStage: newStage,
      timeline: updatedTimeline,
    );

    // Serialize explicitly to ensure nested objects are converted
    final json = updatedLeave.toJson();
    json['timeline'] = updatedTimeline.map((e) => e.toJson()).toList();

    await _leavesColl.doc(leave.id).update(json);
  }

  Future<void> deleteLeave(String leaveId) async {
    await _leavesColl.doc(leaveId).delete();
  }
}

enum LeaveAction { forward, approve, reject }
