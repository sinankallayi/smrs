// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimelineEntryImpl _$$TimelineEntryImplFromJson(Map<String, dynamic> json) =>
    _$TimelineEntryImpl(
      byUserId: json['byUserId'] as String,
      byUserName: json['byUserName'] as String,
      byUserRole: json['byUserRole'] as String,
      status: json['status'] as String,
      remark: json['remark'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$$TimelineEntryImplToJson(_$TimelineEntryImpl instance) =>
    <String, dynamic>{
      'byUserId': instance.byUserId,
      'byUserName': instance.byUserName,
      'byUserRole': instance.byUserRole,
      'status': instance.status,
      'remark': instance.remark,
      'date': const TimestampConverter().toJson(instance.date),
    };

_$LeaveRequestModelImpl _$$LeaveRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveRequestModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userRole: json['userRole'] as String,
  userSection: json['userSection'] as String?,
  startDate: const TimestampConverter().fromJson(
    json['startDate'] as Timestamp,
  ),
  endDate: const TimestampConverter().fromJson(json['endDate'] as Timestamp),
  reason: json['reason'] as String,
  status: $enumDecode(_$LeaveStatusEnumMap, json['status']),
  currentStage: $enumDecode(_$LeaveStageEnumMap, json['currentStage']),
  appliedAt: const TimestampConverter().fromJson(
    json['appliedAt'] as Timestamp,
  ),
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$LeaveRequestModelImplToJson(
  _$LeaveRequestModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userRole': instance.userRole,
  'userSection': instance.userSection,
  'startDate': const TimestampConverter().toJson(instance.startDate),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'reason': instance.reason,
  'status': _$LeaveStatusEnumMap[instance.status]!,
  'currentStage': _$LeaveStageEnumMap[instance.currentStage]!,
  'appliedAt': const TimestampConverter().toJson(instance.appliedAt),
  'timeline': instance.timeline,
  'isActive': instance.isActive,
};

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.forwarded: 'forwarded',
  LeaveStatus.managementApproved: 'management_approved',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
};

const _$LeaveStageEnumMap = {
  LeaveStage.sectionHeadReview: 'section_head_review',
  LeaveStage.managementReview: 'management_review',
  LeaveStage.finalization: 'finalization',
  LeaveStage.completed: 'completed',
};
