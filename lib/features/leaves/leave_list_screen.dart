import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/utils/string_extensions.dart';
import '../auth/auth_provider.dart';
import 'leave_service.dart';

class LeaveListScreen extends ConsumerWidget {
  final UserModel user;
  final bool excludeCurrentUser;
  final bool onlyCurrentUser;
  // New role filters
  final String? targetRole;
  final List<String>? targetRoleFilter;

  // Internal helper enum
  // ignore: library_private_types_in_public_api

  const LeaveListScreen({
    super.key,
    required this.user,
    this.excludeCurrentUser = false,
    this.onlyCurrentUser = false,
    this.targetRole,
    this.targetRoleFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. "My Leaves" Mode (High Priority)
    if (onlyCurrentUser) {
      return SafeArea(
        child: LeaveListWidget(user: user, onlyCurrentUser: true),
      );
    }

    // 2. Section Head "Review/Dashboard" Mode
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
                    LeaveListWidget(
                      user: user,
                      filterStages: const [LeaveStage.sectionHeadReview],
                      excludeCurrentUser:
                          true, // Explicitly exclude self from review
                    ),
                    LeaveListWidget(
                      user: user,
                      filterStages: const [LeaveStage.finalization],
                      excludeCurrentUser: true,
                    ),
                    LeaveListWidget(
                      user: user,
                      filterStages: null, // Shows all/history
                      excludeCurrentUser: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    // 3. Management/Manager "Review" Mode
    else if (user.role != AppRoles.staff) {
      // Management View Logic
      // If showing "My Leaves" (onlyCurrentUser == true), show flat list
      // If showing "Review/Inbox" (excludeCurrentUser == true), show Pending/History tabs

      // We need to know which filters are active to decide layout.
      // But `LeaveListScreen` doesn't take these params in constructor, `_LeaveList` does.
      // Wait, `LeaveListScreen` is the top level. The Dashboard creates it.
      // We need to update `LeaveListScreen` to accept these params to pass down.

      // Since I cannot change the constructor of LeaveListScreen easily without cascading changes (it's called in Dashboard),
      // I will infer intent or add params to constructor.
      // I added params in `DashboardScreen` call: `LeaveListScreen(user: user, excludeCurrentUser: true)`
      // So I MUST update the constructor here.

      // Review/Inbox Mode (or default fallback for managers)
      // Separation logic:
      // Separation logic:
      // Management: Staff | Section Heads | Managers
      // Managers (MD etc): Staff | Section Heads

      final bool isManagementRole = user.role == AppRoles.management;

      return DefaultTabController(
        length: isManagementRole ? 3 : 2,
        child: SafeArea(
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Staff Leaves'.toTitleCase()),
                  Tab(text: 'Section Head Leaves'.toTitleCase()),
                  if (isManagementRole)
                    Tab(text: 'Manager Leaves'.toTitleCase()),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // 1. Staff Leaves (Filtered by role 'staff')
                    LeaveListWidget(
                      user: user,
                      filterStages: const [
                        LeaveStage.managementReview,
                        LeaveStage.sectionHeadReview,
                      ],
                      excludeCurrentUser: true,
                      targetRole: AppRoles.staff,
                    ),

                    // 2. Section Head Leaves (Filtered by role 'sectionHead')
                    LeaveListWidget(
                      user: user,
                      filterStages: const [LeaveStage.managementReview],
                      excludeCurrentUser: true,
                      targetRole: AppRoles.sectionHead,
                    ),

                    // 3. Manager Leaves (For Management Only)
                    if (isManagementRole)
                      LeaveListWidget(
                        user: user,
                        filterStages: const [LeaveStage.managementReview],
                        excludeCurrentUser: true,

                        // NEW LOGIC: Show ALL roles EXCEPT Staff and Section Head
                        // This effectively shows MD, EXD, HR, Floor Manager, Store Manager, etc.
                        excludeRoleFilter: const [
                          AppRoles.staff,
                          AppRoles.sectionHead,
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } // Staff View
    return SafeArea(child: LeaveListWidget(user: user));
  }
}

class LeaveListWidget extends ConsumerStatefulWidget {
  final UserModel user;
  final List<LeaveStage>? filterStages;
  final bool excludeCurrentUser;
  final bool onlyCurrentUser;
  // New role filters
  final String? targetRole;
  final List<String>? targetRoleFilter;
  final List<String>? excludeRoleFilter;

  const LeaveListWidget({
    required this.user,
    this.filterStages,
    this.excludeCurrentUser = false,
    this.onlyCurrentUser = false,
    this.targetRole,
    this.targetRoleFilter,
    this.excludeRoleFilter,
  });

  @override
  ConsumerState<LeaveListWidget> createState() => _LeaveListWidgetState();
}

class _LeaveListWidgetState extends ConsumerState<LeaveListWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  LeaveStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter UI
        // 1. Only for "Review/Work" views (where filterStages is null/empty or specifically requested)
        // 2. NOT for Staff (simplified view)
        // 3. NOT for "My Leaves" (onlyCurrentUser == true) - Requested by User
        if (widget.filterStages == null &&
            ![
              AppRoles.staff,
              AppRoles.sectionHead,
            ].contains(widget.user.role) &&
            !widget.onlyCurrentUser)
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

              // 2A. User Filter (Inbox vs My Leaves)
              if (widget.excludeCurrentUser) {
                // Must explicitly check != user.id
                leaves = leaves
                    .where((l) => l.userId != widget.user.id)
                    .toList();
              }
              if (widget.onlyCurrentUser) {
                leaves = leaves
                    .where((l) => l.userId == widget.user.id)
                    .toList();
              }

              // 2B. Role Separation Filter
              if (widget.targetRole != null) {
                leaves = leaves
                    .where((l) => l.userRole == widget.targetRole)
                    .toList();
              }
              if (widget.targetRoleFilter != null) {
                leaves = leaves
                    .where((l) => widget.targetRoleFilter!.contains(l.userRole))
                    .toList();
              }
              if (widget.excludeRoleFilter != null) {
                leaves = leaves
                    .where(
                      (l) => !widget.excludeRoleFilter!.contains(l.userRole),
                    )
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

class _LeaveCard extends ConsumerStatefulWidget {
  final LeaveRequestModel leave;
  final UserModel currentUser;

  const _LeaveCard({required this.leave, required this.currentUser});

  @override
  ConsumerState<_LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends ConsumerState<_LeaveCard> {
  bool _isExpanded = false;

  Color _getStatusColor(BuildContext context, LeaveStatus status) {
    // Check Effective Status (Hierarchy Based)
    final type = _getEffectiveStatusType();
    final scheme = Theme.of(context).colorScheme;

    if (type == _EffectiveStatusType.approved) return Colors.green;
    if (type == _EffectiveStatusType.rejected) return scheme.error;
    return Colors.orange;
  }

  _EffectiveStatusType _getEffectiveStatusType() {
    // Do not return early for Rejected. We must check hierarchy to see if a higher rank Approved it.
    // However, if it's strictly Approved (final), we can trust it?
    // Actually, getting rid of both is safer to enforce the "Highest Rank Rule" visually.
    // If the DB status is 'Approved', the highest rank entry SHOULD be an approval anyway.

    // We remove the db-status checks to rely purely on the timeline hierarchy for "My Decision" logic
    // UNLESS the timeline is empty, then we fall back to status.

    // Intermediate States: Check Hierarchy (Management > Managers > Section Head)
    // Order: SuperAdmin(4) > Management(3) > Managers(HR/Floor/Store)(2) > SectionHead(1) > Staff(0)
    int getRoleRank(String roleRaw) {
      final role = roleRaw.toLowerCase();
      if (role == AppRoles.superAdmin.toLowerCase()) return 4;
      if (role == AppRoles.management.toLowerCase()) return 3;

      // All managers (HR, Floor, Store, etc.) -> Rank 2
      if (![
        AppRoles.staff.toLowerCase(),
        AppRoles.sectionHead.toLowerCase(),
      ].contains(role))
        return 2;

      if (role == AppRoles.sectionHead.toLowerCase()) return 1;
      return 0; // Staff
    }

    TimelineEntry? highestRankEntry;
    int highestRank = -1;

    for (var entry in widget.leave.timeline) {
      final rank = getRoleRank(entry.byUserRole);
      // Strictly Higher Rank wins (Overrides generic timeline order)
      if (rank > highestRank) {
        highestRank = rank;
        highestRankEntry = entry;
      }
      // Same Rank? Latest action wins (Standard conflict resolution)
      else if (rank == highestRank) {
        highestRankEntry = entry;
      }
    }

    if (highestRankEntry != null) {
      final action = highestRankEntry.status.toLowerCase();
      if (action == 'approve') {
        // Only show APPROVED if:
        // 1. High Authority (Management/SuperAdmin) approved it (Rank >= 3)
        // 2. OR The DB status is strictly 'approved' (Finalized by workflow)
        if (highestRank >= 3 || widget.leave.status == LeaveStatus.approved) {
          return _EffectiveStatusType.approved;
        }
        return _EffectiveStatusType.pending; // Intermediate approval
      } else if (action == 'reject') {
        return _EffectiveStatusType.rejected;
      }
      // 'forward' or any other status falls through to PENDING
    }

    // Fallback: If no relevant timeline entry found (e.g. legacy data), trust the DB status
    if (widget.leave.status == LeaveStatus.rejected) {
      return _EffectiveStatusType.rejected;
    }
    if (widget.leave.status == LeaveStatus.approved) {
      return _EffectiveStatusType.approved;
    }

    return _EffectiveStatusType.pending;
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
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _getStatusColor(context, widget.leave.status),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.leave.userName.toTitleCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              _buildStatusBadge(context),
                              const SizedBox(width: 4),
                              Icon(
                                _isExpanded
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Display Section or Designations for Managers/SectionHeads
                      if (widget.leave.userRole == AppRoles.sectionHead &&
                          widget.leave.userSection != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Section: ${widget.leave.userSection!.toTitleCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else if (![
                        AppRoles.staff,
                        AppRoles.sectionHead,
                        AppRoles.management,
                      ].contains(widget.leave.userRole))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Designation: ${widget.leave.userRole.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            '${dateFormat.format(widget.leave.startDate)} - ${dateFormat.format(widget.leave.endDate)}',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getLeaveTypeLabel(widget.leave.type),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.leave.reason,
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      // EXPANDABLE CONTENT (Action History & Buttons)
                      if (_isExpanded) ...[
                        // Action History - Visible to ALL
                        if (widget.leave.timeline.isNotEmpty) ...[
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
                          ...widget.leave.timeline.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _getActionIcon(entry.status),
                                    size: 16,
                                    color: _getActionColor(
                                      context,
                                      entry.status,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                            AppRoles
                                                                .sectionHead &&
                                                        entry.byUserSection !=
                                                            null
                                                    ? '${entry.byUserName.toTitleCase()} (${entry.byUserSection!.toUpperCase()}) '
                                                    : '${entry.byUserName.toTitleCase()} (${entry.byUserRole.toUpperCase()}) ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: entry.status
                                                    .toUpperCase(),
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
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                        if (widget.currentUser.role == AppRoles.staff) ...[
                          Builder(
                            builder: (context) {
                              // Find the latest remark from a Section Head that is NOT a 'Forward' action
                              // 'Forward' remarks are for Management. 'Reject' remarks are for Staff.
                              final sectionHeadEntry = widget.leave.timeline
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final type = _getEffectiveStatusType();
    String statusText;
    Color statusColor;

    if (type == _EffectiveStatusType.approved) {
      statusText = 'APPROVED';
      statusColor = Colors.green;
    } else if (type == _EffectiveStatusType.rejected) {
      statusText = 'REJECTED';
      statusColor = Theme.of(context).colorScheme.error;
    } else {
      statusText = 'PENDING';
      statusColor = Colors.orange;
    }

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
    // 0.1 Check if I have ALREADY acted (Audit Trail check)
    // If I am in the timeline, I shouldn't see buttons again.
    final hasActed = widget.leave.timeline.any(
      (t) => t.byUserId == widget.currentUser.id,
    );
    if (hasActed) return false;

    // 1. Dynamic Flow Check
    // If the request has dynamic approvers defined, use that source of truth.
    if (widget.leave.currentApproverRoles.isNotEmpty) {
      return widget.leave.currentApproverRoles.any(
        (r) => r.toLowerCase() == widget.currentUser.role.toLowerCase(),
      );
    }

    // 2. Legacy Fallback
    // Section Head Actions
    if (widget.currentUser.role == AppRoles.sectionHead) {
      if (widget.leave.userId == widget.currentUser.id)
        return false; // Prevent acting on own leave
      return widget.leave.currentStage == LeaveStage.sectionHeadReview ||
          widget.leave.currentStage == LeaveStage.finalization;
    }
    // Management Actions
    // Management / Upper Authority Actions
    if (![
      AppRoles.staff,
      AppRoles.sectionHead,
    ].contains(widget.currentUser.role)) {
      // CANNOT act on own leaves
      if (widget.leave.userId == widget.currentUser.id) return false;

      // Can act on Management Review
      if (widget.leave.currentStage == LeaveStage.managementReview) return true;
      // Can intervene on Section Head Review
      if (widget.leave.currentStage == LeaveStage.sectionHeadReview)
        return true;
    }
    return false;
  }

  Widget _buildActionButtons(WidgetRef ref, BuildContext context) {
    List<Widget> buttons = [];
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Dynamic Flow Actions
    // If the user is a current approver in the dynamic flow, valid actions are Reject and Approve.
    // Case-insensitive check
    final isApprover = widget.leave.currentApproverRoles.any(
      (r) => r.toLowerCase() == widget.currentUser.role.toLowerCase(),
    );

    if (isApprover) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            'Approve',
            Colors.green,
            () => _showActionDialog(
              context,
              ref,
              LeaveAction.approve,
              'Approve Request',
            ),
          ),
        ],
      );
    }

    // 2. Legacy Fallback Actions
    if (widget.currentUser.role == AppRoles.sectionHead) {
      if (widget.leave.currentStage == LeaveStage.sectionHeadReview) {
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
      } else if (widget.leave.currentStage == LeaveStage.finalization) {
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
    ].contains(widget.currentUser.role)) {
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
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showActionDialog(
    BuildContext context,
    WidgetRef ref,
    LeaveAction action,
    String title,
  ) async {
    final remarkController = TextEditingController();
    final scheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action == LeaveAction.reject)
              const Text(
                'Please provide a reason for rejection.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: remarkController,
              decoration: InputDecoration(
                labelText: 'Remark (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (action == LeaveAction.reject &&
                  remarkController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reason is required for rejection'),
                  ),
                );
                return;
              }

              Navigator.pop(context); // Close dialog first

              try {
                final currentUser = await ref.read(userProfileProvider.future);
                if (currentUser == null) return;

                await ref
                    .read(leaveServiceProvider.notifier)
                    .processAction(
                      leave: widget.leave,
                      action: action,
                      actor: currentUser,
                      remark: remarkController.text.trim(),
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Action processed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _getLeaveTypeLabel(LeaveType type) {
    switch (type) {
      case LeaveType.fullDay:
        return 'Full Day';
      case LeaveType.halfDay:
        return 'Half Day';
      case LeaveType.lateArrival:
        return 'Late Arrival';
      case LeaveType.earlyDeparture:
        return 'Early Departure';
      case LeaveType.shortLeave:
        return 'Short Leave';
    }
  }
}

enum _EffectiveStatusType { pending, approved, rejected }
