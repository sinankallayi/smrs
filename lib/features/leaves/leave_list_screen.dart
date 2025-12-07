import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import 'leave_service.dart';

class LeaveListScreen extends ConsumerWidget {
  final UserModel user;

  const LeaveListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        body: StreamBuilder<List<LeaveRequestModel>>(
          stream: ref.watch(leaveServiceProvider.notifier).getLeaves(user),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final leaves = snapshot.data!;

            if (leaves.isEmpty) {
              return const Center(child: Text('No leave requests found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: leaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final leave = leaves[index];
                return _LeaveCard(leave: leave, currentUser: user);
              },
            );
          },
        ),
      ),
    );
  }
}

class _LeaveCard extends ConsumerWidget {
  final LeaveRequestModel leave;
  final UserModel currentUser;

  const _LeaveCard({required this.leave, required this.currentUser});

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leave.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(leave.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(leave.status)),
                ),
                child: Text(
                  leave.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(leave.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            leave.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          if (leave.status == LeaveStatus.pending &&
              (currentUser.role == UserRole.md ||
                  currentUser.role == UserRole.manager))
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        _updateStatus(ref, context, LeaveStatus.rejected),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        _updateStatus(ref, context, LeaveStatus.approved),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    BuildContext context,
    LeaveStatus status,
  ) async {
    try {
      await ref
          .read(leaveServiceProvider.notifier)
          .updateStatus(
            leaveId: leave.id,
            status: status,
            actionByUserId: currentUser.id,
            actionByName: currentUser.name,
            actionByRole: currentUser.role.name,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request ${status.name}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
