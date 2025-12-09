import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/user_model.dart';
import '../auth/auth_provider.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              // Router listens to auth state changes and will redirect to /login automatically
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _AdminCard(
            icon: LucideIcons.briefcase,
            title: 'Management\n(HR/ExD/MD)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserManagementScreen(
                  title: 'Management Team',
                  allowedRoles: [UserRole.hr, UserRole.exd, UserRole.md],
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
                  allowedRoles: [UserRole.sectionHead],
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
