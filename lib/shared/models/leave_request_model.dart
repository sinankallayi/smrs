import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_request_model.freezed.dart';
part 'leave_request_model.g.dart';

enum LeaveStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

// Custom converter for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class LeaveRequestModel with _$LeaveRequestModel {
  const factory LeaveRequestModel({
    required String id,
    required String userId,
    required String userName,
    required String userRole,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    required String reason,
    required LeaveStatus status,
    @TimestampConverter() required DateTime appliedAt,

    // Action fields (nullable)
    String? actionByUserId,
    String? actionByName,
    String? actionByRole,
    @TimestampConverter() DateTime? actionDate,
  }) = _LeaveRequestModel;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);
}
