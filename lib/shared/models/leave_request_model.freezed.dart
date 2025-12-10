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

TimelineEntry _$TimelineEntryFromJson(Map<String, dynamic> json) {
  return _TimelineEntry.fromJson(json);
}

/// @nodoc
mixin _$TimelineEntry {
  String get byUserId => throw _privateConstructorUsedError;
  String get byUserName => throw _privateConstructorUsedError;
  String get byUserRole => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // String representation of action taken
  String get remark => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this TimelineEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineEntryCopyWith<TimelineEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineEntryCopyWith<$Res> {
  factory $TimelineEntryCopyWith(
    TimelineEntry value,
    $Res Function(TimelineEntry) then,
  ) = _$TimelineEntryCopyWithImpl<$Res, TimelineEntry>;
  @useResult
  $Res call({
    String byUserId,
    String byUserName,
    String byUserRole,
    String status,
    String remark,
    @TimestampConverter() DateTime date,
  });
}

/// @nodoc
class _$TimelineEntryCopyWithImpl<$Res, $Val extends TimelineEntry>
    implements $TimelineEntryCopyWith<$Res> {
  _$TimelineEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byUserId = null,
    Object? byUserName = null,
    Object? byUserRole = null,
    Object? status = null,
    Object? remark = null,
    Object? date = null,
  }) {
    return _then(
      _value.copyWith(
            byUserId: null == byUserId
                ? _value.byUserId
                : byUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            byUserName: null == byUserName
                ? _value.byUserName
                : byUserName // ignore: cast_nullable_to_non_nullable
                      as String,
            byUserRole: null == byUserRole
                ? _value.byUserRole
                : byUserRole // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            remark: null == remark
                ? _value.remark
                : remark // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimelineEntryImplCopyWith<$Res>
    implements $TimelineEntryCopyWith<$Res> {
  factory _$$TimelineEntryImplCopyWith(
    _$TimelineEntryImpl value,
    $Res Function(_$TimelineEntryImpl) then,
  ) = __$$TimelineEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String byUserId,
    String byUserName,
    String byUserRole,
    String status,
    String remark,
    @TimestampConverter() DateTime date,
  });
}

/// @nodoc
class __$$TimelineEntryImplCopyWithImpl<$Res>
    extends _$TimelineEntryCopyWithImpl<$Res, _$TimelineEntryImpl>
    implements _$$TimelineEntryImplCopyWith<$Res> {
  __$$TimelineEntryImplCopyWithImpl(
    _$TimelineEntryImpl _value,
    $Res Function(_$TimelineEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byUserId = null,
    Object? byUserName = null,
    Object? byUserRole = null,
    Object? status = null,
    Object? remark = null,
    Object? date = null,
  }) {
    return _then(
      _$TimelineEntryImpl(
        byUserId: null == byUserId
            ? _value.byUserId
            : byUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        byUserName: null == byUserName
            ? _value.byUserName
            : byUserName // ignore: cast_nullable_to_non_nullable
                  as String,
        byUserRole: null == byUserRole
            ? _value.byUserRole
            : byUserRole // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        remark: null == remark
            ? _value.remark
            : remark // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelineEntryImpl implements _TimelineEntry {
  const _$TimelineEntryImpl({
    required this.byUserId,
    required this.byUserName,
    required this.byUserRole,
    required this.status,
    required this.remark,
    @TimestampConverter() required this.date,
  });

  factory _$TimelineEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineEntryImplFromJson(json);

  @override
  final String byUserId;
  @override
  final String byUserName;
  @override
  final String byUserRole;
  @override
  final String status;
  // String representation of action taken
  @override
  final String remark;
  @override
  @TimestampConverter()
  final DateTime date;

  @override
  String toString() {
    return 'TimelineEntry(byUserId: $byUserId, byUserName: $byUserName, byUserRole: $byUserRole, status: $status, remark: $remark, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineEntryImpl &&
            (identical(other.byUserId, byUserId) ||
                other.byUserId == byUserId) &&
            (identical(other.byUserName, byUserName) ||
                other.byUserName == byUserName) &&
            (identical(other.byUserRole, byUserRole) ||
                other.byUserRole == byUserRole) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.remark, remark) || other.remark == remark) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    byUserId,
    byUserName,
    byUserRole,
    status,
    remark,
    date,
  );

  /// Create a copy of TimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineEntryImplCopyWith<_$TimelineEntryImpl> get copyWith =>
      __$$TimelineEntryImplCopyWithImpl<_$TimelineEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineEntryImplToJson(this);
  }
}

abstract class _TimelineEntry implements TimelineEntry {
  const factory _TimelineEntry({
    required final String byUserId,
    required final String byUserName,
    required final String byUserRole,
    required final String status,
    required final String remark,
    @TimestampConverter() required final DateTime date,
  }) = _$TimelineEntryImpl;

  factory _TimelineEntry.fromJson(Map<String, dynamic> json) =
      _$TimelineEntryImpl.fromJson;

  @override
  String get byUserId;
  @override
  String get byUserName;
  @override
  String get byUserRole;
  @override
  String get status; // String representation of action taken
  @override
  String get remark;
  @override
  @TimestampConverter()
  DateTime get date;

  /// Create a copy of TimelineEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineEntryImplCopyWith<_$TimelineEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) {
  return _LeaveRequestModel.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequestModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  String? get userSection => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endDate => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError; // Workflow State
  LeaveStatus get status => throw _privateConstructorUsedError;
  LeaveStage get currentStage => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get appliedAt => throw _privateConstructorUsedError; // Approval Timeline
  List<TimelineEntry> get timeline =>
      throw _privateConstructorUsedError; // Metadata
  bool get isActive => throw _privateConstructorUsedError;

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
    String? userSection,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime endDate,
    String reason,
    LeaveStatus status,
    LeaveStage currentStage,
    @TimestampConverter() DateTime appliedAt,
    List<TimelineEntry> timeline,
    bool isActive,
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
    Object? userSection = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? currentStage = null,
    Object? appliedAt = null,
    Object? timeline = null,
    Object? isActive = null,
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
            userSection: freezed == userSection
                ? _value.userSection
                : userSection // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            currentStage: null == currentStage
                ? _value.currentStage
                : currentStage // ignore: cast_nullable_to_non_nullable
                      as LeaveStage,
            appliedAt: null == appliedAt
                ? _value.appliedAt
                : appliedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as List<TimelineEntry>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
    String? userSection,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime endDate,
    String reason,
    LeaveStatus status,
    LeaveStage currentStage,
    @TimestampConverter() DateTime appliedAt,
    List<TimelineEntry> timeline,
    bool isActive,
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
    Object? userSection = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? currentStage = null,
    Object? appliedAt = null,
    Object? timeline = null,
    Object? isActive = null,
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
        userSection: freezed == userSection
            ? _value.userSection
            : userSection // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        currentStage: null == currentStage
            ? _value.currentStage
            : currentStage // ignore: cast_nullable_to_non_nullable
                  as LeaveStage,
        appliedAt: null == appliedAt
            ? _value.appliedAt
            : appliedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        timeline: null == timeline
            ? _value._timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as List<TimelineEntry>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
    this.userSection,
    @TimestampConverter() required this.startDate,
    @TimestampConverter() required this.endDate,
    required this.reason,
    required this.status,
    required this.currentStage,
    @TimestampConverter() required this.appliedAt,
    final List<TimelineEntry> timeline = const [],
    this.isActive = true,
  }) : _timeline = timeline;

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
  final String? userSection;
  @override
  @TimestampConverter()
  final DateTime startDate;
  @override
  @TimestampConverter()
  final DateTime endDate;
  @override
  final String reason;
  // Workflow State
  @override
  final LeaveStatus status;
  @override
  final LeaveStage currentStage;
  @override
  @TimestampConverter()
  final DateTime appliedAt;
  // Approval Timeline
  final List<TimelineEntry> _timeline;
  // Approval Timeline
  @override
  @JsonKey()
  List<TimelineEntry> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  // Metadata
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'LeaveRequestModel(id: $id, userId: $userId, userName: $userName, userRole: $userRole, userSection: $userSection, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, currentStage: $currentStage, appliedAt: $appliedAt, timeline: $timeline, isActive: $isActive)';
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
            (identical(other.userSection, userSection) ||
                other.userSection == userSection) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.appliedAt, appliedAt) ||
                other.appliedAt == appliedAt) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userName,
    userRole,
    userSection,
    startDate,
    endDate,
    reason,
    status,
    currentStage,
    appliedAt,
    const DeepCollectionEquality().hash(_timeline),
    isActive,
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
    final String? userSection,
    @TimestampConverter() required final DateTime startDate,
    @TimestampConverter() required final DateTime endDate,
    required final String reason,
    required final LeaveStatus status,
    required final LeaveStage currentStage,
    @TimestampConverter() required final DateTime appliedAt,
    final List<TimelineEntry> timeline,
    final bool isActive,
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
  String? get userSection;
  @override
  @TimestampConverter()
  DateTime get startDate;
  @override
  @TimestampConverter()
  DateTime get endDate;
  @override
  String get reason; // Workflow State
  @override
  LeaveStatus get status;
  @override
  LeaveStage get currentStage;
  @override
  @TimestampConverter()
  DateTime get appliedAt; // Approval Timeline
  @override
  List<TimelineEntry> get timeline; // Metadata
  @override
  bool get isActive;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestModelImplCopyWith<_$LeaveRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
