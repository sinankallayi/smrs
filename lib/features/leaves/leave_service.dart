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
    }
    // MD and Manager see all. Could add extra filters here.

    return query.orderBy('appliedAt', descending: true).snapshots().map((qs) {
      return qs.docs
          .map((doc) => LeaveRequestModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> createLeave(LeaveRequestModel leave) async {
    await _leavesColl.doc(leave.id).set(leave.toJson());
  }

  Future<void> updateLeave(LeaveRequestModel leave) async {
    await _leavesColl.doc(leave.id).update(leave.toJson());
  }

  Future<void> updateStatus({
    required String leaveId,
    required LeaveStatus status,
    required String actionByUserId,
    required String actionByName,
    required String actionByRole,
  }) async {
    await _leavesColl.doc(leaveId).update({
      'status': status.name, // Enum to string ?? depending on serialization
      'actionByUserId': actionByUserId,
      'actionByName': actionByName,
      'actionByRole': actionByRole,
      'actionDate': Timestamp.now(),
    });
  }

  Future<void> deleteLeave(String leaveId) async {
    await _leavesColl.doc(leaveId).delete();
  }
}
