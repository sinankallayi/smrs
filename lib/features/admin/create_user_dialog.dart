import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';

class CreateUserDialog extends ConsumerStatefulWidget {
  final UserModel? userToEdit;
  final List<UserRole>?
  allowedRoles; // If null, allow all (except superAdmin maybe?)

  const CreateUserDialog({super.key, this.userToEdit, this.allowedRoles});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late UserRole _selectedRole;
  UserSection? _selectedSection;
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    // Determine initial role
    if (widget.userToEdit != null) {
      _selectedRole = widget.userToEdit!.role;
      _selectedSection = widget.userToEdit!.section;
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      _isActive = widget.userToEdit!.isActive;
    } else {
      // Default to first allowed role or just staff
      if (widget.allowedRoles != null && widget.allowedRoles!.isNotEmpty) {
        _selectedRole = widget.allowedRoles!.first;
      } else {
        _selectedRole = UserRole.staff;
      }

      if (_selectedRole == UserRole.sectionHead) {
        _selectedSection = UserSection.values.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userToEdit != null;

    // Filter available roles
    final availableRoles =
        widget.allowedRoles ??
        UserRole.values.where((r) => r != UserRole.superAdmin).toList();

    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Create User'),
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
                enabled: !isEditing,
              ),
              if (!isEditing)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              const SizedBox(height: 16),

              // Only show dropdown if there is more than one choice
              if (availableRoles.length > 1)
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: availableRoles.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedRole = v!;
                      if (_selectedRole != UserRole.sectionHead) {
                        _selectedSection = null;
                      } else if (_selectedSection == null) {
                        _selectedSection = UserSection.values.first;
                      }
                    });
                  },
                )
              else
                // Read-only display if only one role is allowed
                TextFormField(
                  initialValue: _selectedRole.name.toUpperCase(),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    enabled: false,
                  ),
                  readOnly: true,
                ),

              if (_selectedRole == UserRole.sectionHead)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: DropdownButtonFormField<UserSection>(
                    value: _selectedSection,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: UserSection.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedSection = v),
                    validator: (v) =>
                        _selectedRole == UserRole.sectionHead && v == null
                        ? 'Required'
                        : null,
                  ),
                ),

              if (isEditing)
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
        // Create
        await ref
            .read(authControllerProvider.notifier)
            .createUser(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              role: _selectedRole,
              section: _selectedSection,
            );
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .updateUser(
              uid: widget.userToEdit!.id,
              name: _nameController.text.trim(),
              role: _selectedRole,
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
