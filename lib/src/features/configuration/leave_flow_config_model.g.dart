// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_flow_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkflowStepImpl _$$WorkflowStepImplFromJson(Map<String, dynamic> json) =>
    _$WorkflowStepImpl(
      name: json['name'] as String,
      approverRoles:
          (json['approverRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewerRoles:
          (json['viewerRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WorkflowStepImplToJson(_$WorkflowStepImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'approverRoles': instance.approverRoles,
      'viewerRoles': instance.viewerRoles,
    };

_$LeaveWorkflowImpl _$$LeaveWorkflowImplFromJson(Map<String, dynamic> json) =>
    _$LeaveWorkflowImpl(
      requestorRole: json['requestorRole'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LeaveWorkflowImplToJson(_$LeaveWorkflowImpl instance) =>
    <String, dynamic>{
      'requestorRole': instance.requestorRole,
      'steps': instance.steps,
    };

_$LeaveFlowConfigModelImpl _$$LeaveFlowConfigModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveFlowConfigModelImpl(
  workflows:
      (json['workflows'] as List<dynamic>?)
          ?.map((e) => LeaveWorkflow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$LeaveFlowConfigModelImplToJson(
  _$LeaveFlowConfigModelImpl instance,
) => <String, dynamic>{'workflows': instance.workflows};
