import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../features/configuration/leave_flow_config_model.dart';
import '../../features/configuration/leave_flow_service.dart';
import '../../features/configuration/config_service.dart';

class LeaveFlowConfigurationScreen extends ConsumerStatefulWidget {
  const LeaveFlowConfigurationScreen({super.key});

  @override
  ConsumerState<LeaveFlowConfigurationScreen> createState() =>
      _LeaveFlowConfigurationScreenState();
}

class _LeaveFlowConfigurationScreenState
    extends ConsumerState<LeaveFlowConfigurationScreen> {
  bool _isLoading = true;
  bool _isInit = false;

  // Master State Maps
  // Key: Requestor Role -> { Target Role : isSelected }
  final Map<String, Map<String, bool>> _approvers = {};
  final Map<String, Map<String, bool>> _viewers = {};

  @override
  void initState() {
    super.initState();
  }

  List<String> _getManagerRoles(List<String> allRoles) {
    return allRoles.where((r) {
      return r != AppRoles.superAdmin &&
          r != AppRoles.management &&
          r != AppRoles.staff &&
          r != AppRoles.sectionHead;
    }).toList();
  }

  Future<void> _loadCurrentConfig(List<String> availableRoles) async {
    final config = await ref.read(leaveFlowServiceProvider.future);

    // Initialize state for ALL roles (Staff, SH, and every Manager)
    final allRequestorRoles = [
      AppRoles.staff,
      AppRoles.sectionHead,
      ..._getManagerRoles(availableRoles),
    ];

    for (var requestor in allRequestorRoles) {
      _approvers[requestor] = {};
      _viewers[requestor] = {};
    }

    // Load existing config
    for (var requestor in allRequestorRoles) {
      final workflow = config.workflows.firstWhere(
        (w) => w.requestorRole == requestor,
        orElse: () => const LeaveWorkflow(requestorRole: '', steps: []),
      );

      for (var step in workflow.steps) {
        for (var role in step.approverRoles) {
          _approvers[requestor]?[role] = true;
        }
        for (var role in step.viewerRoles) {
          _viewers[requestor]?[role] = true;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<String> _getViewers(
    Map<String, bool> viewersMap,
    List<String> currentStepApprovers,
  ) {
    Set<String> v = {};
    viewersMap.forEach((role, isSelected) {
      if (isSelected) v.add(role);
    });
    v.addAll(currentStepApprovers);
    return v.toList();
  }

  Future<void> _saveConfig(List<String> availableRoles) async {
    setState(() => _isLoading = true);

    final managerRoles = _getManagerRoles(availableRoles);
    List<LeaveWorkflow> workflows = [];

    // Helper to build workflow for any role
    LeaveWorkflow buildWorkflow(String requestorRole) {
      List<WorkflowStep> steps = [];
      final approverMap = _approvers[requestorRole] ?? {};
      final viewerMap = _viewers[requestorRole] ?? {};

      // 1. Supervisory Review (Section Head + Managers)
      // Combined into one step so ANY of them can approve in parallel
      List<String> supervisoryApprovers = [];
      if (approverMap[AppRoles.sectionHead] == true) {
        supervisoryApprovers.add(AppRoles.sectionHead);
      }
      for (var mRole in managerRoles) {
        if (approverMap[mRole] == true) {
          supervisoryApprovers.add(mRole);
        }
      }

      if (supervisoryApprovers.isNotEmpty) {
        steps.add(
          WorkflowStep(
            name: 'Supervisory Review',
            approverRoles: supervisoryApprovers,
            viewerRoles: _getViewers(viewerMap, supervisoryApprovers),
          ),
        );
      }

      // 2. Management (Directors) - Added here for Parallel Approval
      if (approverMap[AppRoles.management] == true) {
        supervisoryApprovers.add(AppRoles.management);
      }

      if (supervisoryApprovers.isNotEmpty) {
        steps.add(
          WorkflowStep(
            name: 'Approval Review', // Renamed from Supervisory
            approverRoles: supervisoryApprovers,
            viewerRoles: _getViewers(viewerMap, supervisoryApprovers),
          ),
        );
      }

      return LeaveWorkflow(requestorRole: requestorRole, steps: steps);
    }

    // Build for Staff
    workflows.add(buildWorkflow(AppRoles.staff));

    // Build for Section Head
    workflows.add(buildWorkflow(AppRoles.sectionHead));

    // Build for EACH Manager Role individually
    for (var mRole in managerRoles) {
      // Force Management as approver for Managers (implicit rule)
      if (_approvers[mRole] == null) _approvers[mRole] = {};
      _approvers[mRole]![AppRoles.management] = true;
      workflows.add(buildWorkflow(mRole));
    }

    final newConfig = LeaveFlowConfigModel(workflows: workflows);

    try {
      await ref.read(leaveFlowServiceProvider.notifier).saveConfig(newConfig);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return rolesAsync.when(
      data: (roles) {
        if (!_isInit) {
          _isInit = true;
          // Initial load of config against these roles
          _loadCurrentConfig(roles);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final managerRoles = _getManagerRoles(roles);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Leave Flow Config'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Staff Flow'),
                  Tab(text: 'Section Head Flow'),
                  Tab(text: 'Manager Flow'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _saveConfig(roles),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildRoleConfig(
                        'Staff',
                        AppRoles.staff,
                        managerRoles,
                        hasSectionHeadOption: true,
                      ),
                      _buildRoleConfig(
                        'Section Head',
                        AppRoles.sectionHead,
                        managerRoles,
                        hasSectionHeadOption: false,
                      ),
                      // Dynamic Tab for Managers
                      _buildManagersTab(managerRoles),
                    ],
                  ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildManagersTab(List<String> managerRoles) {
    if (managerRoles.isEmpty) {
      return const Center(child: Text('No manager roles found.'));
    }
    return ListView.builder(
      itemCount: managerRoles.length,
      itemBuilder: (context, index) {
        final role = managerRoles[index];
        return ExpansionTile(
          title: Text(role.toUpperCase()),
          subtitle: const Text('Configure approval flow'),
          children: [
            _buildRoleConfig(
              role.toUpperCase(),
              role,
              managerRoles,
              hasSectionHeadOption: false,
              isNested: true,
              showVisibility: false, // HIDDEN for Managers as requested
              showApprovalChain: false, // HIDDEN: Fixed to Management
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheck(
    Map<String, bool> map,
    String key,
    String label, {
    Map<String, bool>? linkedMap,
    bool isDisabled = false,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: map[key] ?? false,
      onChanged: isDisabled
          ? null
          : (val) {
              setState(() {
                map[key] = val ?? false;
                // Auto-sync linked map if provided
                if (linkedMap != null) {
                  linkedMap[key] = val ?? false;
                }
              });
            },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildRoleConfig(
    String title,
    String requestorRole,
    List<String> managerRoles, {
    required bool hasSectionHeadOption,
    bool isNested = false,
    bool showVisibility = true,
    bool showApprovalChain = true,
  }) {
    // Access state dynamically
    final approvers = _approvers[requestorRole] ?? {};
    final viewers = _viewers[requestorRole] ?? {};

    // Ensure state exists if not yet init (defensive)
    if (_approvers[requestorRole] == null) {
      _approvers[requestorRole] = approvers;
    }
    if (_viewers[requestorRole] == null) {
      _viewers[requestorRole] = viewers;
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showApprovalChain) ...[
          _buildHeader('Approval Chain (Who needs to approve?)'),
          if (hasSectionHeadOption)
            _buildCheck(
              approvers,
              AppRoles.sectionHead,
              'Section Head',
              linkedMap: viewers,
            ),

          const SizedBox(height: 8),
          const Text(
            'Managers:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (managerRoles.isEmpty)
            const Text(
              'No manager roles defined.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          // Filter out SELF from potential approvers if requestor is a manager
          ...managerRoles
              .where((m) => m != requestorRole)
              .map(
                (role) => _buildCheck(
                  approvers,
                  role,
                  role.toUpperCase(),
                  linkedMap: viewers,
                ),
              ),

          const Divider(),
          _buildCheck(
            approvers,
            AppRoles.management,
            'Management (Directors)',
            linkedMap: viewers,
          ),
        ] else ...[
          // Implicit message for Managers
          const Text(
            'Approval Chain: Management (Fixed)',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],

        if (showVisibility) ...[
          const SizedBox(height: 24),
          _buildHeader('Visibility (Who can view?)'),
          const Text(
            'Note: Approvers can always view respective leaves.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (hasSectionHeadOption)
            _buildCheck(
              viewers,
              AppRoles.sectionHead,
              'Section Head',
              isDisabled: approvers[AppRoles.sectionHead] == true,
            ),

          const SizedBox(height: 8),
          const Text(
            'Managers:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...managerRoles
              .where((m) => m != requestorRole)
              .map(
                (role) => _buildCheck(
                  viewers,
                  role,
                  role.toUpperCase(),
                  isDisabled: approvers[role] == true,
                ),
              ),

          const SizedBox(height: 8),
          _buildCheck(
            viewers,
            AppRoles.management,
            'Management',
            isDisabled: approvers[AppRoles.management] == true,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );

    if (isNested) {
      return Padding(padding: const EdgeInsets.all(16), child: content);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
