import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/user_model.dart';
import '../../features/configuration/config_service.dart';

import 'user_management_screen.dart';
import 'leave_flow_configuration_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: rolesAsync.when(
        data: (roles) {
          // 1. Managers Card (Between SectionHead and Management)
          // Exclude SuperAdmin, Management, Staff, and SectionHead
          final managerRoles = roles.where((r) {
            return r != AppRoles.superAdmin &&
                r != AppRoles.management &&
                r != AppRoles.staff &&
                r != AppRoles.sectionHead;
          }).toList();

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _AdminCard(
                icon: LucideIcons.briefcase,
                title: 'Managers',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserManagementScreen(
                      title: 'Managers',
                      allowedRoles: managerRoles,
                    ),
                  ),
                ),
              ),
              _AdminCard(
                icon: LucideIcons.shieldAlert, // Different icon for Management
                title: 'Management',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserManagementScreen(
                      title: 'Management',
                      allowedRoles: const [
                        AppRoles.management,
                      ], // Explicitly pass the single role
                    ),
                  ),
                ),
              ),
              _AdminCard(
                icon: LucideIcons.store,
                title: 'Section Heads',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserManagementScreen(
                      title: 'Section Heads',
                      allowedRoles: [AppRoles.sectionHead],
                    ),
                  ),
                ),
              ),
              _AdminCard(
                icon: LucideIcons.workflow,
                title: 'Leave Flow',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LeaveFlowConfigurationScreen(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
