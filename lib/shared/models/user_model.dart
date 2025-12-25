import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

class AppRoles {
  static const String superAdmin = 'superAdmin';
  static const String md = 'md';
  static const String exd = 'exd';
  static const String hr = 'hr';
  static const String sectionHead = 'sectionHead';
  static const String management = 'management';
  static const String staff = 'staff';

  static const List<String> values = [
    superAdmin,
    md,
    exd,
    hr,
    sectionHead,

    management,
    staff,
  ];
}

class AppSections {
  static const String bakery = 'bakery';
  static const String fancy = 'fancy';
  static const String vegetable = 'vegetable';

  static const List<String> values = [bakery, fancy, vegetable];
}

Object? _readEmployeeId(Map json, String key) {
  return json['employeeId'] ?? json['staffId'];
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required String role, // Changed from UserRole
    String? section, // Changed from UserSection
    @JsonKey(readValue: _readEmployeeId) String? employeeId,
    String? createdBy,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
