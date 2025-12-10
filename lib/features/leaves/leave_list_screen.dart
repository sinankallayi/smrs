import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import 'leave_service.dart';

class LeaveListScreen extends ConsumerWidget {
  final UserModel user;

  const LeaveListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user.role == AppRoles.sectionHead) {
      return DefaultTabController(
        length: 3,
        child: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Finalization'),
                  Tab(text: 'History'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaveList(
                      user: user,
                      filterStage: LeaveStage.sectionHeadReview,
                    ),
                    _LeaveList(
                      user: user,
                      filterStage: LeaveStage.finalization,
                    ),
                    _LeaveList(
                      user: user,
                      filterStage: null, // Shows all/history
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (user.role == AppRoles.md ||
        user.role == AppRoles.exd ||
        user.role == AppRoles.hr) {
      // Management View
      return DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Pending Review'),
                  Tab(text: 'History'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaveList(
                      user: user,
                      filterStage: LeaveStage.managementReview,
                    ),
                    _LeaveList(user: user, filterStage: null), // History
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Staff View
    return SafeArea(child: _LeaveList(user: user));
  }
}

class _LeaveList extends ConsumerWidget {
  final UserModel user;
  final LeaveStage? filterStage;

  const _LeaveList({required this.user, this.filterStage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<LeaveRequestModel>>(
      stream: ref.watch(leaveServiceProvider.notifier).getLeaves(user),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var leaves = snapshot.data!;

        // Filter if stage is specified, otherwise show all (History)
        if (filterStage != null) {
          leaves = leaves.where((l) => l.currentStage == filterStage).toList();
        }

        // Sort by date descending (newest first)
        leaves.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

        if (leaves.isEmpty)
          return const Center(child: Text('No requests found.'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _LeaveCard(leave: leaves[index], currentUser: user),
        );
      },
    );
  }
}

class _LeaveCard extends ConsumerWidget {
  final LeaveRequestModel leave;
  final UserModel currentUser;

  const _LeaveCard({required this.leave, required this.currentUser});

  Color _getStatusColor(BuildContext context, LeaveStatus status) {
    // Mask 'Management Approved' as Pending (Orange) for Staff
    if (currentUser.role == AppRoles.staff &&
        status == LeaveStatus.managementApproved) {
      return Colors.orange;
    }

    final scheme = Theme.of(context).colorScheme;

    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.forwarded:
        return scheme.primary;
      case LeaveStatus.managementApproved:
        return Colors.purple;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return scheme.error;
    }
  }

  Color _getActionColor(BuildContext context, String action) {
    final scheme = Theme.of(context).colorScheme;
    switch (action.toLowerCase()) {
      case 'forward':
        return scheme.primary;
      case 'approve':
        return Colors.green;
      case 'reject':
        return scheme.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'forward':
        return LucideIcons.arrowRightCircle;
      case 'approve':
        return LucideIcons.checkCircle2;
      case 'reject':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final scheme = Theme.of(context).colorScheme;

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
              _buildStatusBadge(context),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}',
          ),
          const SizedBox(height: 4),
          Text(leave.reason, style: TextStyle(color: Colors.grey[600])),

          // Action History - Hidden for Staff
          if (leave.timeline.isNotEmpty &&
              currentUser.role != AppRoles.staff) ...[
            const Divider(height: 24),
            const Text(
              'Action History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ...leave.timeline.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getActionIcon(entry.status),
                      size: 16,
                      color: _getActionColor(context, entry.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      entry.byUserRole ==
                                              AppRoles.sectionHead &&
                                          entry.byUserSection != null
                                      ? '${entry.byUserName} (${entry.byUserRole} - ${entry.byUserSection}) '
                                      : '${entry.byUserName} (${entry.byUserRole}) ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: entry.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getActionColor(
                                      context,
                                      entry.status,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, hh:mm a').format(entry.date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          if (entry.remark.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Remark: ${entry.remark}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // STAFF ONLY: Show Section Head Remark if available
          if (currentUser.role == AppRoles.staff) ...[
            Builder(
              builder: (context) {
                // Find the latest remark from a Section Head that is NOT a 'Forward' action
                // 'Forward' remarks are for Management. 'Reject' remarks are for Staff.
                final sectionHeadEntry = leave.timeline
                    .cast<TimelineEntry?>()
                    .firstWhere(
                      (e) =>
                          e != null &&
                          e.byUserRole == 'sectionHead' &&
                          e.status != 'forward' &&
                          e.remark.isNotEmpty,
                      orElse: () => null,
                    );

                if (sectionHeadEntry != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note from Section Head:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sectionHeadEntry.remark,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          if (_canAct()) ...[
            const SizedBox(height: 16),
            _buildActionButtons(ref, context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String statusText = leave.status.name.toUpperCase().replaceAll('_', ' ');
    Color statusColor = _getStatusColor(context, leave.status);

    // MASKING for Staff: Show "PENDING" instead of "MANAGEMENT APPROVED"
    if (currentUser.role == AppRoles.staff &&
        leave.status == LeaveStatus.managementApproved) {
      statusText = 'PENDING';
      // statusColor is already handled by _getStatusColor
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  bool _canAct() {
    // Section Head Actions
    if (currentUser.role == AppRoles.sectionHead) {
      return leave.currentStage == LeaveStage.sectionHeadReview ||
          leave.currentStage == LeaveStage.finalization;
    }
    // Management Actions
    if ([AppRoles.md, AppRoles.exd, AppRoles.hr].contains(currentUser.role)) {
      return leave.currentStage == LeaveStage.managementReview;
    }
    return false;
  }

  Widget _buildActionButtons(WidgetRef ref, BuildContext context) {
    List<Widget> buttons = [];
    final scheme = Theme.of(context).colorScheme;

    if (currentUser.role == AppRoles.sectionHead) {
      if (leave.currentStage == LeaveStage.sectionHeadReview) {
        buttons = [
          _actionBtn(
            context,
            'Reject',
            scheme.error,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.reject,
              'Reject Request',
            ),
          ),
          const SizedBox(width: 8),
          _actionBtn(
            context,
            'Forward',
            scheme.primary,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.forward,
              'Forward to Management',
            ),
          ),
          const SizedBox(width: 8),
          _actionBtn(
            context,
            'Approve',
            Colors.green,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.approve,
              'Approve Request',
            ),
          ),
        ];
      } else if (leave.currentStage == LeaveStage.finalization) {
        buttons = [
          _actionBtn(
            context,
            'Reject',
            scheme.error,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.reject,
              'Reject Finalization',
            ),
          ),
          const SizedBox(width: 8),
          _actionBtn(
            context,
            'Finalize Plan',
            Colors.green,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.approve,
              'Finalize Roster',
            ),
          ),
        ];
      }
    } else if ([
      AppRoles.md,
      AppRoles.exd,
      AppRoles.hr,
    ].contains(currentUser.role)) {
      buttons = [
        _actionBtn(
          context,
          'Reject',
          scheme.error,
          () => _showActionDialog(
            context,
            ref,
            LeaveAction.reject,
            'Reject Request',
          ),
        ),
        const SizedBox(width: 8),
        _actionBtn(
          context,
          'Accept', // Renamed from Grant Permission
          Colors.purple,
          () => _showActionDialog(
            context,
            ref,
            LeaveAction.approve,
            'Accept Request',
          ),
        ),
      ];
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons);
  }

  Widget _actionBtn(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  void _showActionDialog(
    BuildContext context,
    WidgetRef ref,
    LeaveAction action,
    String title,
  ) {
    final remarkController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark (Required)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Remark is required' : null,
                  ),
                ],
              ),
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          try {
                            await ref
                                .read(leaveServiceProvider.notifier)
                                .processAction(
                                  leave: leave,
                                  action: action,
                                  actor: currentUser,
                                  remark: remarkController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Action Processed: ${action.name}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }
}
