import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'leave_request_model.freezed.dart';
part 'leave_request_model.g.dart';

// Custom converter for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

enum LeaveStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('forwarded')
  forwarded,
  @JsonValue('management_approved')
  managementApproved,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

enum LeaveStage {
  @JsonValue('section_head_review')
  sectionHeadReview,
  @JsonValue('management_review')
  managementReview,
  @JsonValue('finalization')
  finalization,
  @JsonValue('completed')
  completed,
}

@freezed
class TimelineEntry with _$TimelineEntry {
  const factory TimelineEntry({
    required String byUserId,
    required String byUserName,
    required String byUserRole,
    String? byUserSection, // Added to show specific section for Section Heads
    required String status, // String representation of action taken
    required String remark,
    @TimestampConverter() required DateTime date,
  }) = _TimelineEntry;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) =>
      _$TimelineEntryFromJson(json);
}

@freezed
class LeaveRequestModel with _$LeaveRequestModel {
  const factory LeaveRequestModel({
    required String id,
    required String userId,
    required String userName,
    required String userRole,
    String? userSection,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    required String reason,

    // Workflow State
    required LeaveStatus status,
    required LeaveStage currentStage,

    @TimestampConverter() required DateTime appliedAt,

    // Approval Timeline
    @Default([]) List<TimelineEntry> timeline,

    // Metadata
    @Default(true) bool isActive,
  }) = _LeaveRequestModel;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);
}
