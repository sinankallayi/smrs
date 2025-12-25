// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      section: json['section'] as String?,
      employeeId: _readEmployeeId(json, 'employeeId') as String?,
      createdBy: json['createdBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'section': instance.section,
      'employeeId': instance.employeeId,
      'createdBy': instance.createdBy,
      'isActive': instance.isActive,
    };
