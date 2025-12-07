import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/leaves/leave_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'home_screen.dart';
import '../../features/leaves/leave_form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // We can get the user role to decide which tabs to show if needed.
    // For now, general tabs for everyone.
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      extendBody: true, // For glass effect on bottom nav
      body: userAsync.when(
        data: (user) {
          if (user == null)
            return const Center(child: CircularProgressIndicator());

          final pages = [
            HomeScreen(user: user),
            LeaveListScreen(user: user), // We will implement this
            Container(), // Notifications placeholder
            const SettingsScreen(), // We will implement this
          ];

          return IndexedStack(index: _selectedIndex, children: pages);
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          backgroundColor:
              Colors.transparent, // Glass effect handled by container
          elevation: 0,
          indicatorColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.2),
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Leaves',
            ),
            NavigationDestination(icon: Icon(LucideIcons.bell), label: 'Inbox'),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton:
          (_selectedIndex == 1 && userAsync.valueOrNull?.role == UserRole.staff)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaveFormScreen()),
                );
              },
              child: const Icon(LucideIcons.plus),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
