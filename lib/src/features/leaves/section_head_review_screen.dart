import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import 'leave_list_screen.dart';

class SectionHeadReviewScreen extends ConsumerWidget {
  final UserModel user;

  const SectionHeadReviewScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Single View - Staff Leaves Only
    return SafeArea(
      child: LeaveListWidget(
        user: user,
        targetRole: AppRoles.staff,
        excludeCurrentUser: true,
      ),
    );
  }
}
