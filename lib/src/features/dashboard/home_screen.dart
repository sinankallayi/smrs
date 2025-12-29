import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_container.dart';
import '../../utils/string_extensions.dart';
import '../../models/leave_request_model.dart';
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
                            if (user.role == AppRoles.sectionHead &&
                                user.section != null) ...[
                              Text(
                                user.section!.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                            ] else ...[
                              Text(
                                user.role.toUpperCase(),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.8),
                                    ),
                              ),
                            ],
                            if (user.employeeId != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${user.employeeId}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.8),
                                    ),
                              ),
                            ],
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
                        // Management & Executives Logic (MD, EXD, HR, Management)

                        // 1. Inbox (Requests to Review)
                        // Exclude own requests to avoid reviewing self
                        final inboxLeaves = leaves
                            .where((l) => l.userId != user.id)
                            .toList();

                        // Pending in Inbox: Waiting for Management Review
                        final inboxPending = inboxLeaves
                            .where(
                              (l) =>
                                  l.currentStage == LeaveStage.managementReview,
                            )
                            .length;

                        // Forwarded to Inbox: Specifically from Section Heads
                        final inboxForwarded = inboxLeaves
                            .where(
                              (l) =>
                                  l.currentStage ==
                                      LeaveStage.managementReview &&
                                  l.status == LeaveStatus.sectionHeadForwarded,
                            )
                            .length;

                        // 2. My Leaves (Personal)
                        final myLeaves = leaves
                            .where((l) => l.userId == user.id)
                            .toList();

                        // My Pending: Waiting for approval (could be Management Review if submitted directly)
                        final myPending = myLeaves
                            .where(
                              (l) =>
                                  l.status == LeaveStatus.pending ||
                                  l.status == LeaveStatus.forwarded ||
                                  l.status == LeaveStatus.sectionHeadForwarded,
                            )
                            .length;

                        // My Approved
                        final myApproved = myLeaves
                            .where(
                              (l) =>
                                  l.status == LeaveStatus.approved ||
                                  l.status == LeaveStatus.managementApproved ||
                                  l.status == LeaveStatus.managersApproved,
                            )
                            .length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Inbox Pending'.toTitleCase(),
                                    '$inboxPending',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'From Sections'.toTitleCase(),
                                    '$inboxForwarded',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'My Leaves',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'My Pending'.toTitleCase(),
                                    '$myPending',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'My Approved'.toTitleCase(),
                                    '$myApproved',
                                  ),
                                ),
                              ],
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
