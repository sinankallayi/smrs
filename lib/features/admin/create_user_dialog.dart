import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/configuration/config_service.dart';

class CreateUserDialog extends ConsumerStatefulWidget {
  final UserModel? userToEdit;
  final List<String>? allowedRoles;

  const CreateUserDialog({super.key, this.userToEdit, this.allowedRoles});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  String? _selectedSection;
  bool _isLoading = false;
  bool _isActive = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.userToEdit != null) {
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      _isActive = widget.userToEdit!.isActive;
      _selectedRole = widget.userToEdit!.role;
      _selectedSection = widget.userToEdit!.section;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final sectionsAsync = ref.watch(sectionsProvider);

    return AlertDialog(
      title: Text(widget.userToEdit != null ? 'Edit User' : 'Create User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                enabled: widget.userToEdit == null,
              ),
              if (widget.userToEdit == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              const SizedBox(height: 16),

              // Roles Dropdown
              rolesAsync.when(
                data: (roles) {
                  // Filter roles if allowedRoles is set
                  final validRoles =
                      widget.allowedRoles ??
                      roles.where((r) => r != AppRoles.superAdmin).toList();

                  if (validRoles.isEmpty)
                    return const Text('No roles available');

                  // Initialize selectedRole for new users if not set
                  if (!_initialized &&
                      _selectedRole == null &&
                      validRoles.isNotEmpty) {
                    _selectedRole = validRoles.contains(AppRoles.staff)
                        ? AppRoles.staff
                        : validRoles.first;
                    // If creating new user, section logic will trigger on change or explicit check
                  }

                  // Handle case where editing user has a role not in current list (legacy/removed)
                  // We add it temporarily to allowing editing other fields, or force change?
                  // Better to show it.
                  final displayRoles = [...validRoles];
                  if (_selectedRole != null &&
                      !displayRoles.contains(_selectedRole)) {
                    displayRoles.add(_selectedRole!);
                  }

                  if (displayRoles.length > 1) {
                    return DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: displayRoles
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedRole = v;
                          // Reset section if not section head (logic can be dynamic too but hardcoded for now based on requirement)
                          // Ideally getting 'metadata' about roles from Firestore would be better (e.g. role 'staff' needs section)
                          // For now, keeping legacy logic: Section Head needs section. Staff needs section (managed).
                          // Wait, previously: SectionHead needed section. Staff needed section?
                          // In UserManagementScreen logic: SectionHead -> select section.
                        });
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    );
                  } else if (displayRoles.isNotEmpty) {
                    _selectedRole = displayRoles.first;
                    return TextFormField(
                      initialValue: _selectedRole!.toUpperCase(),
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        enabled: false,
                      ),
                      readOnly: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
                error: (e, _) => Text('Error loading roles: $e'),
                loading: () => const LinearProgressIndicator(),
              ),

              const SizedBox(height: 16),

              // Sections Dropdown
              // Logic: Show section if role is sectionHead, or maybe staff needs it too?
              // Previous logic: "if (_selectedRole == AppRoles.sectionHead)"
              // User requirement: "manage roles and sections".
              // We should allow picking section for any role potentially, or just SectionHead.
              // Let's stick to existing logic: If role is 'sectionHead', show section.
              // BUT: `LeaveFormScreen` check: `if (userDetails.section == null && userDetails.role == AppRoles.staff)`
              // This implies Staff SHOULD have a section too.
              // So let's allow Section selection for SectionHead AND Staff.
              if (_selectedRole == AppRoles.sectionHead ||
                  _selectedRole == AppRoles.staff)
                sectionsAsync.when(
                  data: (sections) {
                    // Ensure selected section is valid

                    return DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: sections
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSection = v),
                      validator: (v) {
                        if ((_selectedRole == AppRoles.sectionHead ||
                                _selectedRole == AppRoles.staff) &&
                            v == null) {
                          return 'Required';
                        }
                        return null;
                      },
                    );
                  },
                  error: (e, _) => Text('Error loading sections: $e'),
                  loading: () => const LinearProgressIndicator(),
                ),

              if (widget.userToEdit != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SwitchListTile(
                    title: const Text('Active Account'),
                    subtitle: const Text('Disable to prevent login'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.userToEdit == null) {
        await ref
            .read(authControllerProvider.notifier)
            .createUser(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              role: _selectedRole!,
              section: _selectedSection,
            );
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .updateUser(
              uid: widget.userToEdit!.id,
              name: _nameController.text.trim(),
              role: _selectedRole!,
              section: _selectedSection,
              isActive: _isActive,
            );
      }
      if (mounted) Navigator.pop(context);
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
}
