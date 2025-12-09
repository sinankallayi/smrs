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
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      section: $enumDecodeNullable(_$UserSectionEnumMap, json['section']),
      createdBy: json['createdBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'section': _$UserSectionEnumMap[instance.section],
      'createdBy': instance.createdBy,
      'isActive': instance.isActive,
    };

const _$UserRoleEnumMap = {
  UserRole.superAdmin: 'superAdmin',
  UserRole.md: 'md',
  UserRole.exd: 'exd',
  UserRole.hr: 'hr',
  UserRole.sectionHead: 'sectionHead',
  UserRole.staff: 'staff',
};

const _$UserSectionEnumMap = {
  UserSection.bakery: 'bakery',
  UserSection.fancy: 'fancy',
  UserSection.vegetable: 'vegetable',
};
