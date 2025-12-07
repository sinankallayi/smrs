// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveRequestModelImpl _$$LeaveRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveRequestModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userRole: json['userRole'] as String,
  startDate: const TimestampConverter().fromJson(
    json['startDate'] as Timestamp,
  ),
  endDate: const TimestampConverter().fromJson(json['endDate'] as Timestamp),
  reason: json['reason'] as String,
  status: $enumDecode(_$LeaveStatusEnumMap, json['status']),
  appliedAt: const TimestampConverter().fromJson(
    json['appliedAt'] as Timestamp,
  ),
  actionByUserId: json['actionByUserId'] as String?,
  actionByName: json['actionByName'] as String?,
  actionByRole: json['actionByRole'] as String?,
  actionDate: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['actionDate'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$LeaveRequestModelImplToJson(
  _$LeaveRequestModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userRole': instance.userRole,
  'startDate': const TimestampConverter().toJson(instance.startDate),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'reason': instance.reason,
  'status': _$LeaveStatusEnumMap[instance.status]!,
  'appliedAt': const TimestampConverter().toJson(instance.appliedAt),
  'actionByUserId': instance.actionByUserId,
  'actionByName': instance.actionByName,
  'actionByRole': instance.actionByRole,
  'actionDate': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.actionDate,
    const TimestampConverter().toJson,
  ),
};

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
