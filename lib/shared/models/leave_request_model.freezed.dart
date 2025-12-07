// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) {
  return _LeaveRequestModel.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequestModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endDate => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  LeaveStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get appliedAt => throw _privateConstructorUsedError; // Action fields (nullable)
  String? get actionByUserId => throw _privateConstructorUsedError;
  String? get actionByName => throw _privateConstructorUsedError;
  String? get actionByRole => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get actionDate => throw _privateConstructorUsedError;

  /// Serializes this LeaveRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveRequestModelCopyWith<LeaveRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRequestModelCopyWith<$Res> {
  factory $LeaveRequestModelCopyWith(
    LeaveRequestModel value,
    $Res Function(LeaveRequestModel) then,
  ) = _$LeaveRequestModelCopyWithImpl<$Res, LeaveRequestModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String userRole,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime endDate,
    String reason,
    LeaveStatus status,
    @TimestampConverter() DateTime appliedAt,
    String? actionByUserId,
    String? actionByName,
    String? actionByRole,
    @TimestampConverter() DateTime? actionDate,
  });
}

/// @nodoc
class _$LeaveRequestModelCopyWithImpl<$Res, $Val extends LeaveRequestModel>
    implements $LeaveRequestModelCopyWith<$Res> {
  _$LeaveRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userRole = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? appliedAt = null,
    Object? actionByUserId = freezed,
    Object? actionByName = freezed,
    Object? actionByRole = freezed,
    Object? actionDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userRole: null == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LeaveStatus,
            appliedAt: null == appliedAt
                ? _value.appliedAt
                : appliedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            actionByUserId: freezed == actionByUserId
                ? _value.actionByUserId
                : actionByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionByName: freezed == actionByName
                ? _value.actionByName
                : actionByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionByRole: freezed == actionByRole
                ? _value.actionByRole
                : actionByRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionDate: freezed == actionDate
                ? _value.actionDate
                : actionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveRequestModelImplCopyWith<$Res>
    implements $LeaveRequestModelCopyWith<$Res> {
  factory _$$LeaveRequestModelImplCopyWith(
    _$LeaveRequestModelImpl value,
    $Res Function(_$LeaveRequestModelImpl) then,
  ) = __$$LeaveRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String userRole,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime endDate,
    String reason,
    LeaveStatus status,
    @TimestampConverter() DateTime appliedAt,
    String? actionByUserId,
    String? actionByName,
    String? actionByRole,
    @TimestampConverter() DateTime? actionDate,
  });
}

/// @nodoc
class __$$LeaveRequestModelImplCopyWithImpl<$Res>
    extends _$LeaveRequestModelCopyWithImpl<$Res, _$LeaveRequestModelImpl>
    implements _$$LeaveRequestModelImplCopyWith<$Res> {
  __$$LeaveRequestModelImplCopyWithImpl(
    _$LeaveRequestModelImpl _value,
    $Res Function(_$LeaveRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userRole = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? appliedAt = null,
    Object? actionByUserId = freezed,
    Object? actionByName = freezed,
    Object? actionByRole = freezed,
    Object? actionDate = freezed,
  }) {
    return _then(
      _$LeaveRequestModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userRole: null == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LeaveStatus,
        appliedAt: null == appliedAt
            ? _value.appliedAt
            : appliedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        actionByUserId: freezed == actionByUserId
            ? _value.actionByUserId
            : actionByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionByName: freezed == actionByName
            ? _value.actionByName
            : actionByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionByRole: freezed == actionByRole
            ? _value.actionByRole
            : actionByRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionDate: freezed == actionDate
            ? _value.actionDate
            : actionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveRequestModelImpl implements _LeaveRequestModel {
  const _$LeaveRequestModelImpl({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    @TimestampConverter() required this.startDate,
    @TimestampConverter() required this.endDate,
    required this.reason,
    required this.status,
    @TimestampConverter() required this.appliedAt,
    this.actionByUserId,
    this.actionByName,
    this.actionByRole,
    @TimestampConverter() this.actionDate,
  });

  factory _$LeaveRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveRequestModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String userRole;
  @override
  @TimestampConverter()
  final DateTime startDate;
  @override
  @TimestampConverter()
  final DateTime endDate;
  @override
  final String reason;
  @override
  final LeaveStatus status;
  @override
  @TimestampConverter()
  final DateTime appliedAt;
  // Action fields (nullable)
  @override
  final String? actionByUserId;
  @override
  final String? actionByName;
  @override
  final String? actionByRole;
  @override
  @TimestampConverter()
  final DateTime? actionDate;

  @override
  String toString() {
    return 'LeaveRequestModel(id: $id, userId: $userId, userName: $userName, userRole: $userRole, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, appliedAt: $appliedAt, actionByUserId: $actionByUserId, actionByName: $actionByName, actionByRole: $actionByRole, actionDate: $actionDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.appliedAt, appliedAt) ||
                other.appliedAt == appliedAt) &&
            (identical(other.actionByUserId, actionByUserId) ||
                other.actionByUserId == actionByUserId) &&
            (identical(other.actionByName, actionByName) ||
                other.actionByName == actionByName) &&
            (identical(other.actionByRole, actionByRole) ||
                other.actionByRole == actionByRole) &&
            (identical(other.actionDate, actionDate) ||
                other.actionDate == actionDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userName,
    userRole,
    startDate,
    endDate,
    reason,
    status,
    appliedAt,
    actionByUserId,
    actionByName,
    actionByRole,
    actionDate,
  );

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveRequestModelImplCopyWith<_$LeaveRequestModelImpl> get copyWith =>
      __$$LeaveRequestModelImplCopyWithImpl<_$LeaveRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveRequestModelImplToJson(this);
  }
}

abstract class _LeaveRequestModel implements LeaveRequestModel {
  const factory _LeaveRequestModel({
    required final String id,
    required final String userId,
    required final String userName,
    required final String userRole,
    @TimestampConverter() required final DateTime startDate,
    @TimestampConverter() required final DateTime endDate,
    required final String reason,
    required final LeaveStatus status,
    @TimestampConverter() required final DateTime appliedAt,
    final String? actionByUserId,
    final String? actionByName,
    final String? actionByRole,
    @TimestampConverter() final DateTime? actionDate,
  }) = _$LeaveRequestModelImpl;

  factory _LeaveRequestModel.fromJson(Map<String, dynamic> json) =
      _$LeaveRequestModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String get userRole;
  @override
  @TimestampConverter()
  DateTime get startDate;
  @override
  @TimestampConverter()
  DateTime get endDate;
  @override
  String get reason;
  @override
  LeaveStatus get status;
  @override
  @TimestampConverter()
  DateTime get appliedAt; // Action fields (nullable)
  @override
  String? get actionByUserId;
  @override
  String? get actionByName;
  @override
  String? get actionByRole;
  @override
  @TimestampConverter()
  DateTime? get actionDate;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestModelImplCopyWith<_$LeaveRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
