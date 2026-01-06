import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../utils/string_extensions.dart';
import 'leave_list_screen.dart';

class ManagerReviewScreen extends ConsumerWidget {
  final UserModel user;

  const ManagerReviewScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Staff Leaves'.toTitleCase()),
                Tab(text: 'Section Head Leaves'.toTitleCase()),
                Tab(text: 'HR Leaves'.toTitleCase()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 1. Staff Leaves (All)
                  LeaveListWidget(
                    user: user,
                    excludeCurrentUser: true,
                    targetRole: AppRoles.staff,
                  ),

                  // 2. Section Head Leaves
                  LeaveListWidget(
                    user: user,
                    excludeCurrentUser: true,
                    // Filter for Section Head users
                    customFilter: (l) {
                      final r = l.userRole.toLowerCase().replaceAll(' ', '');
                      return r == AppRoles.sectionHead.toLowerCase();
                    },
                  ),

                  // 3. HR Leaves
                  LeaveListWidget(
                    user: user,
                    excludeCurrentUser: true,
                    targetRole: AppRoles.hr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
