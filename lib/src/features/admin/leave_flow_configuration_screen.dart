import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/user_model.dart';
import '../../features/configuration/leave_flow_config_model.dart';
import '../../features/configuration/leave_flow_service.dart';
import '../../features/configuration/config_service.dart';
import '../../widgets/glass_container.dart';

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
          r != AppRoles.sectionHead &&
          r != AppRoles.hr; // Exclude HR from managers
    }).toList();
  }

  Future<void> _loadCurrentConfig(List<String> availableRoles) async {
    final config = await ref.read(leaveFlowServiceProvider.future);

    // Initialize state for ALL roles (Staff, SH, HR, and every Manager)
    final allRequestorRoles = [
      AppRoles.staff,
      AppRoles.sectionHead,
      AppRoles.hr, // Added HR
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

      List<String> selectedApprovers = [];

      // 1. Management
      if (approverMap[AppRoles.management] == true) {
        selectedApprovers.add(AppRoles.management);
      }

      // 2. HR
      if (approverMap[AppRoles.hr] == true) {
        selectedApprovers.add(AppRoles.hr);
      }

      // 3. Section Head
      if (approverMap[AppRoles.sectionHead] == true) {
        selectedApprovers.add(AppRoles.sectionHead);
      }

      // 4. Managers
      for (var mRole in managerRoles) {
        if (approverMap[mRole] == true) {
          selectedApprovers.add(mRole);
        }
      }

      // Create a single approval step if any approvers are selected
      if (selectedApprovers.isNotEmpty) {
        steps.add(
          WorkflowStep(
            name: 'Approval Review',
            approverRoles: selectedApprovers,
            viewerRoles: _getViewers(viewerMap, selectedApprovers),
          ),
        );
      }

      return LeaveWorkflow(requestorRole: requestorRole, steps: steps);
    }

    // Build for Staff
    workflows.add(buildWorkflow(AppRoles.staff));

    // Build for Section Head
    workflows.add(buildWorkflow(AppRoles.sectionHead));

    // Build for HR
    workflows.add(buildWorkflow(AppRoles.hr));

    // Build for EACH Manager Role individually
    for (var mRole in managerRoles) {
      // Allow full customization for managers (no forced overrides)
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return rolesAsync.when(
      data: (roles) {
        if (!_isInit) {
          _isInit = true;
          _loadCurrentConfig(roles);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final managerRoles = _getManagerRoles(roles);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Leave Flow Config'),
              elevation: 0,
              bottom: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Staff'),
                  Tab(text: 'Section Head'),
                  Tab(text: 'Managers'),
                  Tab(text: 'HR'), // MOVED TO END
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _saveConfig(roles),
                  ),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TabBarView(
                      children: [
                        // Staff Tab
                        GlassContainer(
                          opacity: 0.05,
                          color: isDark ? Colors.white : Colors.black,
                          height: double.infinity,
                          child: _buildRoleConfig(
                            'Staff',
                            AppRoles.staff,
                            managerRoles,
                            hasSectionHeadOption: true,
                            hasHrOption: true,
                          ),
                        ),
                        // Section Head Tab
                        GlassContainer(
                          opacity: 0.05,
                          color: isDark ? Colors.white : Colors.black,
                          height: double.infinity,
                          child: _buildRoleConfig(
                            'Section Head',
                            AppRoles.sectionHead,
                            managerRoles,
                            hasSectionHeadOption: false,
                            hasHrOption: true,
                          ),
                        ),
                        // Managers Tab (Moved before HR)
                        GlassContainer(
                          opacity: 0.05,
                          color: isDark ? Colors.white : Colors.black,
                          height: double.infinity,
                          child: _buildManagersTab(managerRoles),
                        ),
                        // HR Tab (Moved to End)
                        GlassContainer(
                          opacity: 0.05,
                          color: isDark ? Colors.white : Colors.black,
                          height: double.infinity,
                          child: _buildRoleConfig(
                            'HR',
                            AppRoles.hr,
                            managerRoles,
                            hasSectionHeadOption: false,
                            hasHrOption: false,
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.all(16),
      itemCount: managerRoles.length,
      itemBuilder: (context, index) {
        final role = managerRoles[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).cardColor.withOpacity(0.5),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: ExpansionTile(
            title: Text(
              role.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            subtitle: const Text(
              'Configure approval flow',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              _buildRoleConfig(
                role.toUpperCase(),
                role,
                managerRoles,
                hasSectionHeadOption: false,
                hasHrOption: true, // Managers might need HR approval
                isNested: true,
                showVisibility: true, // ENABLED
                showApprovalChain: true, // ENABLED
              ),
            ],
          ),
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
    required bool hasHrOption, // New Param
    bool isNested = false,
    bool showVisibility = true,
    bool showApprovalChain = true,
  }) {
    final approvers = _approvers[requestorRole] ?? {};
    final viewers = _viewers[requestorRole] ?? {};

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
          _buildHeader('Approval Chain', LucideIcons.gitCommit),
          const SizedBox(height: 12),

          // 1. Management (TOP)
          _buildCheck(
            approvers,
            AppRoles.management,
            'Management', // Removed (Directors)
            linkedMap: viewers,
          ),

          const SizedBox(height: 12),

          // 2. HR
          if (hasHrOption)
            _buildCheck(approvers, AppRoles.hr, 'HR', linkedMap: viewers),

          const SizedBox(height: 12),

          // 3. MANAGERS
          Text(
            'MANAGERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          if (managerRoles.isEmpty)
            const Text(
              'No manager roles defined.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
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

          // 4. Section Head (BOTTOM)
          if (hasSectionHeadOption) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            _buildCheck(
              approvers,
              AppRoles.sectionHead,
              'Section Head',
              linkedMap: viewers,
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Auto-Assigned to Management',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (showVisibility) ...[
          const SizedBox(height: 32),
          _buildHeader('Visibility', LucideIcons.eye),
          const SizedBox(height: 4),
          const Text(
            'Who can see these requests?',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),

          // 1. Management (TOP)
          _buildCheck(
            viewers,
            AppRoles.management,
            'Management',
            isDisabled: approvers[AppRoles.management] == true,
          ),

          const SizedBox(height: 12),

          // 2. HR
          if (hasHrOption)
            _buildCheck(
              viewers,
              AppRoles.hr,
              'HR',
              isDisabled: approvers[AppRoles.hr] == true,
            ),

          const SizedBox(height: 12),

          // 3. MANAGERS
          Text(
            'MANAGERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
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

          // 4. Section Head (BOTTOM)
          if (hasSectionHeadOption) ...[
            const SizedBox(height: 12),
            _buildCheck(
              viewers,
              AppRoles.sectionHead,
              'Section Head',
              isDisabled: approvers[AppRoles.sectionHead] == true,
            ),
          ],
        ],
        const SizedBox(height: 24),
      ],
    );

    if (isNested) {
      return Padding(padding: const EdgeInsets.all(16), child: content);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: content,
    );
  }

  Widget _buildHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
