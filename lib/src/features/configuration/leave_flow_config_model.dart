import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_flow_config_model.freezed.dart';
part 'leave_flow_config_model.g.dart';

@freezed
class WorkflowStep with _$WorkflowStep {
  const factory WorkflowStep({
    required String name,
    @Default([]) List<String> approverRoles,
    @Default([]) List<String> viewerRoles,
  }) = _WorkflowStep;

  factory WorkflowStep.fromJson(Map<String, dynamic> json) =>
      _$WorkflowStepFromJson(json);
}

@freezed
class LeaveWorkflow with _$LeaveWorkflow {
  const factory LeaveWorkflow({
    required String requestorRole,
    required List<WorkflowStep> steps,
  }) = _LeaveWorkflow;

  factory LeaveWorkflow.fromJson(Map<String, dynamic> json) =>
      _$LeaveWorkflowFromJson(json);
}

@freezed
class LeaveFlowConfigModel with _$LeaveFlowConfigModel {
  const factory LeaveFlowConfigModel({
    @Default([]) List<LeaveWorkflow> workflows,
  }) = _LeaveFlowConfigModel;

  factory LeaveFlowConfigModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveFlowConfigModelFromJson(json);
}
