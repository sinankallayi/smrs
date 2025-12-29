import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../auth/auth_provider.dart';
import 'leave_list_screen.dart'; // Imports LeaveListWidget

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(
      ' ',
    ).map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
  }
}

class OfficeHistoryScreen extends ConsumerWidget {
  const OfficeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isManagementRole = user.role == AppRoles.management;
        final bool isSectionHead = user.role == AppRoles.sectionHead;

        // Calculate tab count dynamically
        // 1. My History (Unless Management)
        // 2. Staff (Always)
        // 3. Section Heads (Only if NOT Section Head)
        // 4. Managers (Only if Management)
        int tabCount = 1; // Staff (Always)
        if (!isManagementRole) tabCount++; // My History
        if (!isSectionHead) tabCount++; // Section Heads
        if (isManagementRole) tabCount++; // Managers

        return Scaffold(
          appBar: AppBar(title: const Text('Office History')),
          body: DefaultTabController(
            length: tabCount,
            child: SafeArea(
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true, // Allow scrolling if tabs don't fit
                    tabs: [
                      if (!isManagementRole)
                        Tab(text: 'My History'.toTitleCase()),
                      Tab(text: 'Staff'.toTitleCase()),
                      if (!isSectionHead)
                        Tab(text: 'Section Heads'.toTitleCase()),
                      if (isManagementRole) Tab(text: 'Managers'.toTitleCase()),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 0. My History
                        if (!isManagementRole)
                          LeaveListWidget(
                            user: user,
                            filterStages: null, // History
                            onlyCurrentUser: true, // Only MY leaves
                          ),

                        // 1. Staff History (All Stages)
                        LeaveListWidget(
                          user: user,
                          filterStages: null, // ALL stages = History
                          excludeCurrentUser: true,
                          targetRole: AppRoles.staff,
                        ),

                        // 2. Section Head History
                        if (!isSectionHead)
                          LeaveListWidget(
                            user: user,
                            filterStages: null,
                            excludeCurrentUser: true,
                            targetRole: AppRoles.sectionHead,
                          ),

                        // 3. Manager History
                        if (isManagementRole)
                          LeaveListWidget(
                            user: user,
                            filterStages: null,
                            excludeCurrentUser: true,
                            targetRoleFilter: const [
                              AppRoles.md,
                              AppRoles.exd,
                              AppRoles.hr,
                            ],
                          ),
                      ],
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
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
