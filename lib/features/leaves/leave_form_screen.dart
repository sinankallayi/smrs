import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/leave_request_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import '../auth/auth_provider.dart';
import 'leave_service.dart';

class LeaveFormScreen extends ConsumerStatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  ConsumerState<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends ConsumerState<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  LeaveType _selectedType = LeaveType.fullDay; // Default to Full Day
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // For single-day leave types, End Date might not be set by user, fallback to Start Date
    if (_selectedType != LeaveType.fullDay && _startDate != null) {
      _endDate = _startDate;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select dates')));
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authControllerProvider).value!;
      // Need to fetch user details (name, role) from profile or assume current
      // Ideally we pass the full user object, but let's grab from userProfileProvider for safety
      final userDetails = await ref.read(userProfileProvider.future);

      if (userDetails == null) throw Exception('User not found');

      // Ensure user has a section (Section Head needs to know where to route)
      // Staff MUST have a section
      if (userDetails.section == null && userDetails.role == AppRoles.staff) {
        throw Exception('User has no section assigned');
      }

      // Determine initial stage based on role
      LeaveStage initialStage = LeaveStage.sectionHeadReview;
      LeaveStatus initialStatus = LeaveStatus.pending;

      // If not Staff, route to Management Review
      if (userDetails.role != AppRoles.staff) {
        initialStage = LeaveStage.managementReview;
        initialStatus = LeaveStatus.forwarded;
      }

      final leave = LeaveRequestModel(
        id: const Uuid().v4(),
        userId: userDetails.id,
        userName: userDetails.name,
        userRole: userDetails.role,
        userSection: userDetails.section,
        type: _selectedType, // Pass selected type
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        status: initialStatus,
        currentStage: initialStage,
        appliedAt: DateTime.now(),
        timeline: [],
      );

      await ref.read(leaveServiceProvider.notifier).createLeave(leave);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave Request Submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If non-full day, and picking End Date (which shouldn't happen via UI but for safety),
    // force it to be same as start date or don't allow.
    // Actually, for non-full day, we only let them pick Start Date.

    final firstDate = isStart ? today : (_startDate ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? today)
          : (_endDate != null && _endDate!.isAfter(firstDate)
                ? _endDate!
                : firstDate),
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // If non-full day, End Date must match Start Date
          if (_selectedType != LeaveType.fullDay) {
            _endDate = picked;
          } else {
            // If the new Start Date is after the existing End Date, reset End Date
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          }
        } else {
          // Double check logic same as before
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date cannot be before start date'),
              ),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('New Leave Request')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassContainer(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Dates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Leave Type Selector
                  DropdownButtonFormField<LeaveType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: LeaveType.values.map((type) {
                      String label;
                      switch (type) {
                        case LeaveType.fullDay:
                          label = 'Full Day';
                          break;
                        case LeaveType.halfDay:
                          label = 'Half Day';
                          break;
                        case LeaveType.lateArrival:
                          label = 'Late Arrival';
                          break;
                        case LeaveType.earlyDeparture:
                          label = 'Early Departure';
                          break;
                        case LeaveType.shortLeave:
                          label = 'Short Leave';
                          break;
                      }
                      return DropdownMenuItem(value: type, child: Text(label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedType = val;
                          if (_selectedType != LeaveType.fullDay &&
                              _startDate != null) {
                            // If switching to single-day type, ensure End Date matches Start Date
                            _endDate = _startDate;
                          } else if (_selectedType == LeaveType.fullDay &&
                              _endDate == null &&
                              _startDate != null) {
                            // Optional: reset end date to null if switching back to full day?
                            // Or keep it as is. Keeping it as is is safer.
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Start Date', // Or just 'Date' for single day
                          date: _startDate,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      if (_selectedType == LeaveType.fullDay) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DateButton(
                            label: 'End Date',
                            date: _endDate,
                            onTap: () => _pickDate(false),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Reason',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Why are you taking leave?',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Submit Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.calendar,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('MMM dd').format(date!) : 'Select',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
