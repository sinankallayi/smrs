// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_flow_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkflowStep _$WorkflowStepFromJson(Map<String, dynamic> json) {
  return _WorkflowStep.fromJson(json);
}

/// @nodoc
mixin _$WorkflowStep {
  String get name => throw _privateConstructorUsedError;
  List<String> get approverRoles => throw _privateConstructorUsedError;
  List<String> get viewerRoles => throw _privateConstructorUsedError;

  /// Serializes this WorkflowStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowStepCopyWith<WorkflowStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowStepCopyWith<$Res> {
  factory $WorkflowStepCopyWith(
    WorkflowStep value,
    $Res Function(WorkflowStep) then,
  ) = _$WorkflowStepCopyWithImpl<$Res, WorkflowStep>;
  @useResult
  $Res call({
    String name,
    List<String> approverRoles,
    List<String> viewerRoles,
  });
}

/// @nodoc
class _$WorkflowStepCopyWithImpl<$Res, $Val extends WorkflowStep>
    implements $WorkflowStepCopyWith<$Res> {
  _$WorkflowStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? approverRoles = null,
    Object? viewerRoles = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            approverRoles: null == approverRoles
                ? _value.approverRoles
                : approverRoles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            viewerRoles: null == viewerRoles
                ? _value.viewerRoles
                : viewerRoles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkflowStepImplCopyWith<$Res>
    implements $WorkflowStepCopyWith<$Res> {
  factory _$$WorkflowStepImplCopyWith(
    _$WorkflowStepImpl value,
    $Res Function(_$WorkflowStepImpl) then,
  ) = __$$WorkflowStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    List<String> approverRoles,
    List<String> viewerRoles,
  });
}

/// @nodoc
class __$$WorkflowStepImplCopyWithImpl<$Res>
    extends _$WorkflowStepCopyWithImpl<$Res, _$WorkflowStepImpl>
    implements _$$WorkflowStepImplCopyWith<$Res> {
  __$$WorkflowStepImplCopyWithImpl(
    _$WorkflowStepImpl _value,
    $Res Function(_$WorkflowStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? approverRoles = null,
    Object? viewerRoles = null,
  }) {
    return _then(
      _$WorkflowStepImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        approverRoles: null == approverRoles
            ? _value._approverRoles
            : approverRoles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        viewerRoles: null == viewerRoles
            ? _value._viewerRoles
            : viewerRoles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkflowStepImpl implements _WorkflowStep {
  const _$WorkflowStepImpl({
    required this.name,
    final List<String> approverRoles = const [],
    final List<String> viewerRoles = const [],
  }) : _approverRoles = approverRoles,
       _viewerRoles = viewerRoles;

  factory _$WorkflowStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkflowStepImplFromJson(json);

  @override
  final String name;
  final List<String> _approverRoles;
  @override
  @JsonKey()
  List<String> get approverRoles {
    if (_approverRoles is EqualUnmodifiableListView) return _approverRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_approverRoles);
  }

  final List<String> _viewerRoles;
  @override
  @JsonKey()
  List<String> get viewerRoles {
    if (_viewerRoles is EqualUnmodifiableListView) return _viewerRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_viewerRoles);
  }

  @override
  String toString() {
    return 'WorkflowStep(name: $name, approverRoles: $approverRoles, viewerRoles: $viewerRoles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowStepImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._approverRoles,
              _approverRoles,
            ) &&
            const DeepCollectionEquality().equals(
              other._viewerRoles,
              _viewerRoles,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_approverRoles),
    const DeepCollectionEquality().hash(_viewerRoles),
  );

  /// Create a copy of WorkflowStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowStepImplCopyWith<_$WorkflowStepImpl> get copyWith =>
      __$$WorkflowStepImplCopyWithImpl<_$WorkflowStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkflowStepImplToJson(this);
  }
}

abstract class _WorkflowStep implements WorkflowStep {
  const factory _WorkflowStep({
    required final String name,
    final List<String> approverRoles,
    final List<String> viewerRoles,
  }) = _$WorkflowStepImpl;

  factory _WorkflowStep.fromJson(Map<String, dynamic> json) =
      _$WorkflowStepImpl.fromJson;

  @override
  String get name;
  @override
  List<String> get approverRoles;
  @override
  List<String> get viewerRoles;

  /// Create a copy of WorkflowStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowStepImplCopyWith<_$WorkflowStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveWorkflow _$LeaveWorkflowFromJson(Map<String, dynamic> json) {
  return _LeaveWorkflow.fromJson(json);
}

/// @nodoc
mixin _$LeaveWorkflow {
  String get requestorRole => throw _privateConstructorUsedError;
  List<WorkflowStep> get steps => throw _privateConstructorUsedError;

  /// Serializes this LeaveWorkflow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveWorkflow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveWorkflowCopyWith<LeaveWorkflow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveWorkflowCopyWith<$Res> {
  factory $LeaveWorkflowCopyWith(
    LeaveWorkflow value,
    $Res Function(LeaveWorkflow) then,
  ) = _$LeaveWorkflowCopyWithImpl<$Res, LeaveWorkflow>;
  @useResult
  $Res call({String requestorRole, List<WorkflowStep> steps});
}

/// @nodoc
class _$LeaveWorkflowCopyWithImpl<$Res, $Val extends LeaveWorkflow>
    implements $LeaveWorkflowCopyWith<$Res> {
  _$LeaveWorkflowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveWorkflow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? requestorRole = null, Object? steps = null}) {
    return _then(
      _value.copyWith(
            requestorRole: null == requestorRole
                ? _value.requestorRole
                : requestorRole // ignore: cast_nullable_to_non_nullable
                      as String,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<WorkflowStep>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveWorkflowImplCopyWith<$Res>
    implements $LeaveWorkflowCopyWith<$Res> {
  factory _$$LeaveWorkflowImplCopyWith(
    _$LeaveWorkflowImpl value,
    $Res Function(_$LeaveWorkflowImpl) then,
  ) = __$$LeaveWorkflowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String requestorRole, List<WorkflowStep> steps});
}

/// @nodoc
class __$$LeaveWorkflowImplCopyWithImpl<$Res>
    extends _$LeaveWorkflowCopyWithImpl<$Res, _$LeaveWorkflowImpl>
    implements _$$LeaveWorkflowImplCopyWith<$Res> {
  __$$LeaveWorkflowImplCopyWithImpl(
    _$LeaveWorkflowImpl _value,
    $Res Function(_$LeaveWorkflowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveWorkflow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? requestorRole = null, Object? steps = null}) {
    return _then(
      _$LeaveWorkflowImpl(
        requestorRole: null == requestorRole
            ? _value.requestorRole
            : requestorRole // ignore: cast_nullable_to_non_nullable
                  as String,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<WorkflowStep>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveWorkflowImpl implements _LeaveWorkflow {
  const _$LeaveWorkflowImpl({
    required this.requestorRole,
    required final List<WorkflowStep> steps,
  }) : _steps = steps;

  factory _$LeaveWorkflowImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveWorkflowImplFromJson(json);

  @override
  final String requestorRole;
  final List<WorkflowStep> _steps;
  @override
  List<WorkflowStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  String toString() {
    return 'LeaveWorkflow(requestorRole: $requestorRole, steps: $steps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveWorkflowImpl &&
            (identical(other.requestorRole, requestorRole) ||
                other.requestorRole == requestorRole) &&
            const DeepCollectionEquality().equals(other._steps, _steps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    requestorRole,
    const DeepCollectionEquality().hash(_steps),
  );

  /// Create a copy of LeaveWorkflow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveWorkflowImplCopyWith<_$LeaveWorkflowImpl> get copyWith =>
      __$$LeaveWorkflowImplCopyWithImpl<_$LeaveWorkflowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveWorkflowImplToJson(this);
  }
}

abstract class _LeaveWorkflow implements LeaveWorkflow {
  const factory _LeaveWorkflow({
    required final String requestorRole,
    required final List<WorkflowStep> steps,
  }) = _$LeaveWorkflowImpl;

  factory _LeaveWorkflow.fromJson(Map<String, dynamic> json) =
      _$LeaveWorkflowImpl.fromJson;

  @override
  String get requestorRole;
  @override
  List<WorkflowStep> get steps;

  /// Create a copy of LeaveWorkflow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveWorkflowImplCopyWith<_$LeaveWorkflowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveFlowConfigModel _$LeaveFlowConfigModelFromJson(Map<String, dynamic> json) {
  return _LeaveFlowConfigModel.fromJson(json);
}

/// @nodoc
mixin _$LeaveFlowConfigModel {
  List<LeaveWorkflow> get workflows => throw _privateConstructorUsedError;

  /// Serializes this LeaveFlowConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveFlowConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveFlowConfigModelCopyWith<LeaveFlowConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveFlowConfigModelCopyWith<$Res> {
  factory $LeaveFlowConfigModelCopyWith(
    LeaveFlowConfigModel value,
    $Res Function(LeaveFlowConfigModel) then,
  ) = _$LeaveFlowConfigModelCopyWithImpl<$Res, LeaveFlowConfigModel>;
  @useResult
  $Res call({List<LeaveWorkflow> workflows});
}

/// @nodoc
class _$LeaveFlowConfigModelCopyWithImpl<
  $Res,
  $Val extends LeaveFlowConfigModel
>
    implements $LeaveFlowConfigModelCopyWith<$Res> {
  _$LeaveFlowConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveFlowConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? workflows = null}) {
    return _then(
      _value.copyWith(
            workflows: null == workflows
                ? _value.workflows
                : workflows // ignore: cast_nullable_to_non_nullable
                      as List<LeaveWorkflow>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveFlowConfigModelImplCopyWith<$Res>
    implements $LeaveFlowConfigModelCopyWith<$Res> {
  factory _$$LeaveFlowConfigModelImplCopyWith(
    _$LeaveFlowConfigModelImpl value,
    $Res Function(_$LeaveFlowConfigModelImpl) then,
  ) = __$$LeaveFlowConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LeaveWorkflow> workflows});
}

/// @nodoc
class __$$LeaveFlowConfigModelImplCopyWithImpl<$Res>
    extends _$LeaveFlowConfigModelCopyWithImpl<$Res, _$LeaveFlowConfigModelImpl>
    implements _$$LeaveFlowConfigModelImplCopyWith<$Res> {
  __$$LeaveFlowConfigModelImplCopyWithImpl(
    _$LeaveFlowConfigModelImpl _value,
    $Res Function(_$LeaveFlowConfigModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveFlowConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? workflows = null}) {
    return _then(
      _$LeaveFlowConfigModelImpl(
        workflows: null == workflows
            ? _value._workflows
            : workflows // ignore: cast_nullable_to_non_nullable
                  as List<LeaveWorkflow>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveFlowConfigModelImpl implements _LeaveFlowConfigModel {
  const _$LeaveFlowConfigModelImpl({
    final List<LeaveWorkflow> workflows = const [],
  }) : _workflows = workflows;

  factory _$LeaveFlowConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveFlowConfigModelImplFromJson(json);

  final List<LeaveWorkflow> _workflows;
  @override
  @JsonKey()
  List<LeaveWorkflow> get workflows {
    if (_workflows is EqualUnmodifiableListView) return _workflows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workflows);
  }

  @override
  String toString() {
    return 'LeaveFlowConfigModel(workflows: $workflows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveFlowConfigModelImpl &&
            const DeepCollectionEquality().equals(
              other._workflows,
              _workflows,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_workflows));

  /// Create a copy of LeaveFlowConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveFlowConfigModelImplCopyWith<_$LeaveFlowConfigModelImpl>
  get copyWith =>
      __$$LeaveFlowConfigModelImplCopyWithImpl<_$LeaveFlowConfigModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveFlowConfigModelImplToJson(this);
  }
}

abstract class _LeaveFlowConfigModel implements LeaveFlowConfigModel {
  const factory _LeaveFlowConfigModel({final List<LeaveWorkflow> workflows}) =
      _$LeaveFlowConfigModelImpl;

  factory _LeaveFlowConfigModel.fromJson(Map<String, dynamic> json) =
      _$LeaveFlowConfigModelImpl.fromJson;

  @override
  List<LeaveWorkflow> get workflows;

  /// Create a copy of LeaveFlowConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveFlowConfigModelImplCopyWith<_$LeaveFlowConfigModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
