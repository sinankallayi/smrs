import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/leaves/leave_list_screen.dart';
import '../../features/leaves/section_head_review_screen.dart';
import '../../features/leaves/manager_review_screen.dart';
import '../../features/leaves/management_review_screen.dart';
import '../../features/leaves/hr_review_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'home_screen.dart';
import 'manage_staff_screen.dart';
import '../../features/leaves/leave_form_screen.dart';

import '../admin/super_admin_home_screen.dart';
import '../../widgets/glass_nav_bar.dart';

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

        // RE-DOING LIST CONSTRUCTION FOR CLARITY
        final List<Widget> finalPages = [HomeScreen(user: user)];
        final List<NavigationDestination> finalDestinations = [
          const NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
        ];

        // 2. Second Tab: Leaves / Review
        if (user.role == AppRoles.staff) {
          finalPages.add(LeaveListScreen(user: user));
          finalDestinations.add(
            const NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Leaves',
            ),
          );
        } else {
          // Manager/SectionHead: "Review" or "Leaves" (Office)

          // Role Helper Booleans
          final normalizedRole = user.role.trim().toLowerCase().replaceAll(
            ' ',
            '',
          );

          // Strict Checks Only
          final isSectionHead =
              normalizedRole == AppRoles.sectionHead.toLowerCase();
          final isHR = normalizedRole == AppRoles.hr.toLowerCase();
          final isManagement =
              normalizedRole == AppRoles.management.toLowerCase();
          // Any other role is a "Manager"
          // Any other role is a "Manager"

          if (isSectionHead) {
            finalPages.add(SectionHeadReviewScreen(user: user));
          } else if (isHR) {
            finalPages.add(HRReviewScreen(user: user));
          } else if (isManagement) {
            finalPages.add(ManagementReviewScreen(user: user));
          } else if (normalizedRole == AppRoles.manager.toLowerCase()) {
            // Strict Manager
            finalPages.add(ManagerReviewScreen(user: user));
          } else {
            // Fallback for undefined roles (e.g. custom roles not mapped) - Treat as Staff/Basic
            finalPages.add(LeaveListScreen(user: user));
          }

          finalDestinations.add(
            const NavigationDestination(
              icon: Icon(LucideIcons.checkSquare),
              label: 'Review',
            ),
          );
        }

        // 3. Middle Tabs (Role Specific)
        // Only for Managers who process leaves AND apply for leaves (MD, EXD, HR, SectionHead, Custom Managers)
        // Management role is purely for approval, so they don't get 'My Leaves' or 'Apply'.
        if (![
          AppRoles.staff,
          AppRoles.management,
          AppRoles.superAdmin,
        ].contains(user.role)) {
          finalPages.add(LeaveListScreen(user: user, onlyCurrentUser: true));
          finalDestinations.add(
            const NavigationDestination(
              icon: Icon(LucideIcons.fileSignature),
              label: 'My Leaves',
            ),
          );
        }

        if (user.role == AppRoles.hr) {
          finalPages.add(const ManageStaffScreen());
          finalDestinations.add(
            const NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'Staff',
            ),
          );
        }

        // 4. Last Tab: Settings
        finalPages.add(const SettingsScreen());
        finalDestinations.add(
          const NavigationDestination(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        );

        return Scaffold(
          extendBody: true,
          body: IndexedStack(index: _selectedIndex, children: finalPages),
          bottomNavigationBar: GlassNavBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            destinations: finalDestinations,
          ),
          floatingActionButton:
              // Show FAB if:
              // 1. Staff on 'Leaves' tab (index 1)
              // 2. Manager on 'My Leaves' tab (index 2)
              // Management role does NOT see this.
              ((_selectedIndex == 1 && user.role == AppRoles.staff) ||
                  (_selectedIndex == 2 &&
                      ![
                        AppRoles.staff,
                        AppRoles.management,
                        AppRoles.superAdmin,
                      ].contains(user.role)))
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
