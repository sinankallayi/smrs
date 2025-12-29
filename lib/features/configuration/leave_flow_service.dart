import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/user_model.dart';
import 'leave_flow_config_model.dart';
import '../../shared/models/leave_request_model.dart';

part 'leave_flow_service.g.dart';

@riverpod
class LeaveFlowService extends _$LeaveFlowService {
  @override
  Future<LeaveFlowConfigModel> build() async {
    // Load config on startup
    return _fetchConfig();
  }

  DocumentReference<Map<String, dynamic>> get _configDoc =>
      FirebaseFirestore.instance.collection('configurations').doc('leave_flow');

  Future<LeaveFlowConfigModel> _fetchConfig() async {
    final snapshot = await _configDoc.get();
    if (snapshot.exists && snapshot.data() != null) {
      return LeaveFlowConfigModel.fromJson(snapshot.data()!);
    }
    // Return default empty config or maybe a hardcoded default for migration?
    return const LeaveFlowConfigModel(workflows: []);
  }

  Future<void> saveConfig(LeaveFlowConfigModel config) async {
    // Manually serialize to ensure deep copy and avoid "Instance of X" errors in Firestore
    final data = {
      'workflows': config.workflows
          .map(
            (w) => {
              'requestorRole': w.requestorRole,
              'steps': w.steps
                  .map(
                    (s) => {
                      'name': s.name,
                      'approverRoles': s.approverRoles,
                      'viewerRoles': s.viewerRoles,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    await _configDoc.set(data);
    // Invalidate self to reload state
    ref.invalidateSelf();
  }

  /// Calculates the initial state for a new leave request based on the user's role.
  /// If no workflow lies for this role, returns null (caller should handle fallback).
  Future<
    ({
      List<String> approverRoles,
      List<String> viewerRoles,
      String stepName,
      int stepIndex,
    })?
  >
  getInitialState(String requestorRole) async {
    final config = await future;
    final workflow = config.workflows.firstWhere(
      (w) => w.requestorRole == requestorRole,
      orElse: () => const LeaveWorkflow(requestorRole: '', steps: []),
    );

    if (workflow.steps.isEmpty) return null;

    final firstStep = workflow.steps.first;
    return (
      approverRoles: firstStep.approverRoles,
      viewerRoles: firstStep.viewerRoles,
      stepName: firstStep.name,
      stepIndex: 0,
    );
  }

  /// Calculates the next state after an approval.
  /// Returns null if this was the last step (workflow complete).
  Future<
    ({
      List<String> approverRoles,
      List<String> viewerRoles,
      String stepName,
      int stepIndex,
    })?
  >
  getNextState(String requestorRole, int currentStepIndex) async {
    final config = await future;
    final workflow = config.workflows.firstWhere(
      (w) => w.requestorRole == requestorRole,
      orElse: () => const LeaveWorkflow(requestorRole: '', steps: []),
    );

    int nextIndex = currentStepIndex + 1;
    if (nextIndex >= workflow.steps.length) {
      return null;
    }

    final nextStep = workflow.steps[nextIndex];
    return (
      approverRoles: nextStep.approverRoles,
      viewerRoles: nextStep.viewerRoles,
      stepName: nextStep.name,
      stepIndex: nextIndex,
    );
  }
}
