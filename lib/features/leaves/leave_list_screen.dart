import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/utils/string_extensions.dart';
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
              TabBar(
                tabs: [
                  Tab(text: 'Pending'.toTitleCase()),
                  Tab(text: 'Finalization'.toTitleCase()),
                  Tab(text: 'History'.toTitleCase()),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaveList(
                      user: user,
                      filterStages: const [LeaveStage.sectionHeadReview],
                    ),
                    _LeaveList(
                      user: user,
                      filterStages: const [LeaveStage.finalization],
                    ),
                    _LeaveList(
                      user: user,
                      filterStages: null, // Shows all/history
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (user.role != AppRoles.staff) {
      // Management View
      return DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Pending Review'.toTitleCase()),
                  Tab(text: 'History'.toTitleCase()),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaveList(
                      user: user,
                      // Show both Management Review AND Section Head Review
                      // so Management can intervene if needed.
                      filterStages: const [
                        LeaveStage.managementReview,
                        LeaveStage.sectionHeadReview,
                      ],
                    ),
                    _LeaveList(user: user, filterStages: null), // History
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

class _LeaveList extends ConsumerStatefulWidget {
  final UserModel user;
  final List<LeaveStage>? filterStages;

  const _LeaveList({required this.user, this.filterStages});

  @override
  ConsumerState<_LeaveList> createState() => _LeaveListState();
}

class _LeaveListState extends ConsumerState<_LeaveList> {
  DateTime? _startDate;
  DateTime? _endDate;
  LeaveStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter UI (Only for History view or if needed)
        if (widget.filterStages == null &&
            ![AppRoles.staff, AppRoles.sectionHead].contains(widget.user.role))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: _startDate != null && _endDate != null
                            ? DateTimeRange(start: _startDate!, end: _endDate!)
                            : null,
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked.start;
                          _endDate = picked.end;
                        });
                      }
                    },
                    icon: const Icon(LucideIcons.calendar),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                          : 'Date Range'.toTitleCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<LeaveStatus?>(
                    value: _statusFilter,
                    hint: Text('Status'.toTitleCase()),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All'.toTitleCase()),
                      ),
                      ...LeaveStatus.values.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.name.replaceAll('_', ' ').toTitleCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _statusFilter = val),
                    underline: Container(), // Remove default underline
                  ),
                  if (_startDate != null || _statusFilter != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.xCircle, size: 20),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _statusFilter = null;
                        });
                      },
                      tooltip: 'Clear Filters'.toTitleCase(),
                    ),
                  ],
                ],
              ),
            ),
          ),

        Expanded(
          child: StreamBuilder<List<LeaveRequestModel>>(
            stream: ref
                .watch(leaveServiceProvider.notifier)
                .getLeaves(widget.user),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              var leaves = snapshot.data!;

              // 1. Stage Filter
              if (widget.filterStages != null) {
                leaves = leaves
                    .where((l) => widget.filterStages!.contains(l.currentStage))
                    .toList();
              }

              // 2. Status Filter
              if (_statusFilter != null) {
                leaves = leaves
                    .where((l) => l.status == _statusFilter)
                    .toList();
              }

              // 3. Date Range Filter (Overlap Logic)
              if (_startDate != null && _endDate != null) {
                // Filter leaves that overlap with the selected range
                // Leave Start <= Range End AND Leave End >= Range Start
                // We user _endDate! + 1 day mostly to include the full end day if times are mismatched,
                // but usually DateRangePicker returns midnight.
                // Let's stick to standard overlap:
                final rangeStart = _startDate!;
                final rangeEnd = _endDate!
                    .add(const Duration(days: 1))
                    .subtract(const Duration(seconds: 1)); // End of the day

                leaves = leaves.where((l) {
                  return l.startDate.isBefore(rangeEnd) &&
                      l.endDate.isAfter(rangeStart);
                }).toList();
              }

              // Sort by date descending (newest first)
              leaves.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

              if (leaves.isEmpty)
                return Center(
                  child: Text('No requests found.'.toSentenceCase()),
                );

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: leaves.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _LeaveCard(leave: leaves[index], currentUser: widget.user),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LeaveCard extends ConsumerWidget {
  final LeaveRequestModel leave;
  final UserModel currentUser;

  const _LeaveCard({required this.leave, required this.currentUser});

  Color _getStatusColor(BuildContext context, LeaveStatus status) {
    // Masking REMOVED to show full transparency
    final scheme = Theme.of(context).colorScheme;

    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.forwarded:
      case LeaveStatus.sectionHeadForwarded:
        return scheme.primary;
      case LeaveStatus.managersApproved:
      case LeaveStatus.managementApprovedLegacy:
        return Colors.purple;
      case LeaveStatus.managementApproved:
        return Colors.indigo;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getStatusColor(context, leave.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leave.userName.toTitleCase(),
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

                  // Action History - Visible to ALL
                  if (leave.timeline.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Action History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black54,
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
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              entry.byUserRole ==
                                                      AppRoles.sectionHead &&
                                                  entry.byUserSection != null
                                              ? '${entry.byUserName.toTitleCase()} (${entry.byUserSection!.toUpperCase()}) '
                                              : '${entry.byUserName.toTitleCase()} (${entry.byUserRole.toUpperCase()}) ',
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
                                    DateFormat(
                                      'MMM dd, hh:mm a',
                                    ).format(entry.date),
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
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String statusText = leave.status.name.toUpperCase().replaceAll('_', ' ');

    if (leave.status == LeaveStatus.managementApprovedLegacy) {
      statusText = 'MANAGERS APPROVED';
    } else if (leave.status == LeaveStatus.managersApproved) {
      statusText = 'MANAGERS APPROVED';
    } else if (leave.status == LeaveStatus.sectionHeadForwarded) {
      statusText = 'SECTION HEAD FORWARDED';
    } else if (leave.status == LeaveStatus.managementApproved) {
      statusText = 'MANAGEMENT APPROVED';
    }

    Color statusColor = _getStatusColor(context, leave.status);

    // Masking REMOVED

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
    // Management / Upper Authority Actions
    if (![AppRoles.staff, AppRoles.sectionHead].contains(currentUser.role)) {
      // Can act on Management Review
      if (leave.currentStage == LeaveStage.managementReview) return true;
      // Can intervene on Section Head Review
      if (leave.currentStage == LeaveStage.sectionHeadReview) return true;
    }
    return false;
  }

  Widget _buildActionButtons(WidgetRef ref, BuildContext context) {
    List<Widget> buttons = [];
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser.role == AppRoles.sectionHead) {
      if (leave.currentStage == LeaveStage.sectionHeadReview) {
        buttons = [
          _actionBtn(
            context,
            'Reject',
            isDark ? Colors.red : scheme.error,
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
            isDark ? Colors.red : scheme.error,
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
    } else if (![
      AppRoles.staff,
      AppRoles.sectionHead,
    ].contains(currentUser.role)) {
      // Management / Upper Authority Buttons
      buttons = [
        _actionBtn(
          context,
          'Reject',
          isDark ? Colors.red : scheme.error,
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
          'Approve', // Renamed from Accept/Grant Permission
          Colors.green,
          () => _showActionDialog(
            context,
            ref,
            LeaveAction.approve,
            'Approve Request',
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
