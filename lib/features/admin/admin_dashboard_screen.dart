import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/user_model.dart';
import '../../features/configuration/config_service.dart';

import 'user_management_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          rolesAsync.when(
            data: (roles) {
              // Filter out system roles to get Management roles
              final managementRoles = roles
                  .where(
                    (r) =>
                        r != AppRoles.superAdmin &&
                        r != AppRoles.sectionHead &&
                        r != AppRoles.staff,
                  )
                  .toList();
              // Ensure core management roles are always present if not deleted
              // (This might be redundant if Firestore is the source of truth, but good for safety)

              return _AdminCard(
                icon: LucideIcons.briefcase,
                title: 'Management',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserManagementScreen(
                      title: 'Management Team',
                      allowedRoles: managementRoles,
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
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
        ],
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
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
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
