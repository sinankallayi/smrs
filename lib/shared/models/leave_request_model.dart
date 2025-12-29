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
  @JsonValue('managersapproved')
  managersApproved,
  @JsonValue('management_approved') // Support for existing records
  managementApprovedLegacy,
  @JsonValue('sectionheadforwarded')
  sectionHeadForwarded,
  @JsonValue('managementapproved')
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

  Map<String, dynamic> toJson();
}

enum LeaveType {
  @JsonValue('full_day')
  fullDay,
  @JsonValue('half_day')
  halfDay,
  @JsonValue('late_arrival')
  lateArrival,
  @JsonValue('early_departure')
  earlyDeparture,
  @JsonValue('short_leave')
  shortLeave,
}

@freezed
class LeaveRequestModel with _$LeaveRequestModel {
  const factory LeaveRequestModel({
    required String id,
    required String userId,
    required String userName,
    required String userRole,
    String? userSection,
    @Default(LeaveType.fullDay) LeaveType type, // Added Leave Type
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    required String reason,

    // Workflow State
    required LeaveStatus status,
    required LeaveStage currentStage,

    @TimestampConverter() required DateTime appliedAt,

    // Dynamic Workflow State
    @Default([]) List<String> currentApproverRoles,
    @Default([]) List<String> currentViewerRoles,
    @Default(0) int currentStepIndex,
    String? currentStepName,
    @Default([])
    List<String>
    relevantRoles, // Combined approvers + viewers for Firestore query
    // Approval Timeline
    @Default([]) List<TimelineEntry> timeline,

    // Metadata
    @Default(true) bool isActive,
  }) = _LeaveRequestModel;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);

  Map<String, dynamic> toJson();
}
