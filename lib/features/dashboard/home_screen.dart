import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/utils/string_extensions.dart';
import '../../shared/models/leave_request_model.dart';
import '../leaves/leave_service.dart';

class HomeScreen extends ConsumerWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic background could go here
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]!
                      : Colors.grey[50]!,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,'.toTitleCase(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              user.name.toTitleCase(),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.role.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Specific Content
                  StreamBuilder<List<LeaveRequestModel>>(
                    stream: ref
                        .watch(leaveServiceProvider.notifier)
                        .getLeaves(user),
                    builder: (context, snapshot) {
                      final leaves = snapshot.data ?? [];
                      int pendingCount = 0;
                      int forwardedCount = 0;

                      if (user.role == AppRoles.staff) {
                        // Staff Logic
                        pendingCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage ==
                                  LeaveStage.sectionHeadReview,
                            )
                            .length;
                        forwardedCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage == LeaveStage.managementReview,
                            )
                            .length;

                        return Column(
                          children: [
                            _buildSummaryCard(
                              context,
                              'Leave Balance'.toTitleCase(),
                              '12 Days'.toTitleCase(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Pending Requests'.toTitleCase(),
                                    '$pendingCount',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Forwarded Requests'.toTitleCase(),
                                    '$forwardedCount',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (user.role == AppRoles.sectionHead) {
                        // Section Head Logic
                        pendingCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage ==
                                  LeaveStage.sectionHeadReview,
                            )
                            .length;
                        forwardedCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage == LeaveStage.managementReview,
                            )
                            .length;

                        return Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Pending Requests'.toTitleCase(),
                                '$pendingCount',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Forwarded Leaves'.toTitleCase(),
                                '$forwardedCount',
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Management Logic
                        // pending = Total Inbox (All waiting for review)
                        pendingCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage == LeaveStage.managementReview,
                            )
                            .length;
                        // forwarded = Subset from Section Heads
                        forwardedCount = leaves
                            .where(
                              (l) =>
                                  l.currentStage ==
                                      LeaveStage.managementReview &&
                                  l.status == LeaveStatus.sectionHeadForwarded,
                            )
                            .length;

                        return Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Pending Requests'.toTitleCase(),
                                '$pendingCount',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Forwarded Leaves'.toTitleCase(),
                                '$forwardedCount',
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value) {
    return GlassContainer(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
