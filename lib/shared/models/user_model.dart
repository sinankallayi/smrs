import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  @JsonValue('superAdmin')
  superAdmin,
  @JsonValue('md')
  md,
  @JsonValue('exd')
  exd,
  @JsonValue('hr')
  hr,
  @JsonValue('sectionHead')
  sectionHead,
  @JsonValue('staff')
  staff,
}

enum UserSection {
  @JsonValue('bakery')
  bakery,
  @JsonValue('fancy')
  fancy,
  @JsonValue('vegetable')
  vegetable,
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    UserSection? section,
    String? createdBy, // For staff created by HR
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
