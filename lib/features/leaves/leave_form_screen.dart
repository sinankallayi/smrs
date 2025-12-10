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
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select dates')));
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
      if (userDetails.section == null && userDetails.role == AppRoles.staff) {
        throw Exception('User has no section assigned');
      }

      final leave = LeaveRequestModel(
        id: const Uuid().v4(),
        userId: userDetails.id,
        userName: userDetails.name,
        userRole: userDetails.role,
        userSection: userDetails
            .section, // Fallback handled by nullable type or validation
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        status: LeaveStatus.pending,
        currentStage: LeaveStage.sectionHeadReview,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
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
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DateButton(
                          label: 'End Date',
                          date: _endDate,
                          onTap: () => _pickDate(false),
                        ),
                      ),
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
