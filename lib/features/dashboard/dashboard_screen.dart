import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/leaves/leave_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'home_screen.dart';
import 'manage_staff_screen.dart';
import '../../features/leaves/leave_form_screen.dart';

import '../admin/super_admin_home_screen.dart';
import '../../shared/widgets/glass_nav_bar.dart';

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

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user.role == AppRoles.superAdmin) {
          return const SuperAdminHomeScreen();
        }

        List<Widget> pages = [
          HomeScreen(user: user),
          LeaveListScreen(user: user),
          // Container(), // Notifications placeholder - Removed
          const SettingsScreen(),
        ];

        List<NavigationDestination> destinations = [
          const NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.calendar),
            label: 'Leaves',
          ),

          const NavigationDestination(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ];

        if (user.role == AppRoles.hr) {
          pages.insert(2, const ManageStaffScreen());
          destinations.insert(
            2,
            const NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'Staff',
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: IndexedStack(index: _selectedIndex, children: pages),
          bottomNavigationBar: GlassNavBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            destinations: destinations,
          ),
          floatingActionButton:
              (_selectedIndex == 1 && user.role == AppRoles.staff)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaveFormScreen(),
                      ),
                    );
                  },
                  child: const Icon(LucideIcons.plus),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
