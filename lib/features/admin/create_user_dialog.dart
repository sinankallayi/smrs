import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/configuration/config_service.dart';
import '../../shared/widgets/glass_container.dart';

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
  final _employeeIdController = TextEditingController();

  String? _selectedRole;
  String? _selectedSection;
  bool _isLoading = false;
  bool _isActive = true;
  bool _initialized = false;

  bool get _shouldShowEmployeeId {
    if (_selectedRole == null) return false;
    // Show for all roles that are NOT Super Admin
    // Based on user request: management, managers (md/exd/hr), sectionhead, staff
    return _selectedRole != AppRoles.superAdmin;
  }

  @override
  void initState() {
    super.initState();
    if (widget.userToEdit != null) {
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      // Note: userToEdit.employeeId will rely on generated code update
      // If build_runner hasn't run yet, this might show an error in IDE but is correct code.
      // We can use dynamic dispatch or just wait for build.
      // For safety during transition, we might try to read staffId if employeeId is missing?
      // But we renamed the field in UserModel, so we must wait for build.
      _employeeIdController.text = widget.userToEdit!.employeeId ?? '';
      _isActive = widget.userToEdit!.isActive;
      _selectedRole = widget.userToEdit!.role;
      _selectedSection = widget.userToEdit!.section;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final sectionsAsync = ref.watch(
      sectionsProvider,
    ); // Move this up effectively (it was already here but we use it more centrally)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white70 : Colors.black54;
    final fillColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        borderRadius: 20,
        color: glassColor,
        opacity: isDark ? 0.6 : 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.userToEdit != null ? 'Edit User' : 'Create User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Employee ID Field
                      if (_shouldShowEmployeeId) ...[
                        TextFormField(
                          controller: _employeeIdController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Employee ID',
                            labelStyle: TextStyle(color: hintColor),
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (_shouldShowEmployeeId &&
                                (v == null || v.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        enabled: widget.userToEdit == null,
                      ),
                      if (widget.userToEdit == null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: hintColor),
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                      const SizedBox(height: 16),

                      rolesAsync.when(
                        data: (roles) {
                          // Filter roles based on permissions
                          final currentUser = ref
                              .watch(userProfileProvider)
                              .valueOrNull;
                          List<String> validRoles = [];

                          if (currentUser?.role == AppRoles.hr) {
                            // HR can only create Staff
                            validRoles = [AppRoles.staff];
                          } else {
                            // SuperAdmin (or default fallthrough if logic changes)
                            validRoles =
                                widget.allowedRoles ??
                                roles
                                    .where((r) => r != AppRoles.superAdmin)
                                    .toList();
                          }

                          if (validRoles.isEmpty)
                            return Text(
                              'No roles available',
                              style: TextStyle(color: textColor),
                            );

                          // Initialize selectedRole for new users if not set
                          if (!_initialized &&
                              _selectedRole == null &&
                              validRoles.isNotEmpty) {
                            _selectedRole = validRoles.contains(AppRoles.staff)
                                ? AppRoles.staff
                                : validRoles.first;
                          }

                          final displayRoles = [...validRoles];
                          if (_selectedRole != null &&
                              !displayRoles.contains(_selectedRole)) {
                            displayRoles.add(_selectedRole!);
                          }

                          if (displayRoles.length > 1) {
                            return DropdownButtonFormField<String>(
                              value: _selectedRole,
                              style: TextStyle(color: textColor),
                              dropdownColor: isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                labelStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: displayRoles
                                  .map(
                                    (r) => DropdownMenuItem<String>(
                                      value: r,
                                      child: Text(
                                        r.toUpperCase(),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedRole = v;
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          } else if (displayRoles.isNotEmpty) {
                            _selectedRole = displayRoles.first;
                            return const SizedBox.shrink();
                          }
                          return const SizedBox.shrink();
                        },
                        error: (e, _) => Text(
                          'Error loading roles: $e',
                          style: TextStyle(color: textColor),
                        ),
                        loading: () => const LinearProgressIndicator(),
                      ),

                      const SizedBox(height: 16),

                      // Only show Section dropdown if it's explicitly 'staff' role
                      // OR if we are in a legacy mode where sectionHead is still used as a role string (unlikely but safe)
                      // If the selected role IS a section name, we don't show this dropdown (section is implied).
                      if (_selectedRole == AppRoles.staff)
                        sectionsAsync.when(
                          data: (sections) {
                            return DropdownButtonFormField<String>(
                              value: _selectedSection,
                              style: TextStyle(color: textColor),
                              dropdownColor: isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              decoration: InputDecoration(
                                labelText: 'Section',
                                labelStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: sections
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s.toUpperCase(),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedSection = v),
                              validator: (v) {
                                if (_selectedRole == AppRoles.staff &&
                                    v == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            );
                          },
                          error: (e, _) => Text(
                            'Error loading sections: $e',
                            style: TextStyle(color: textColor),
                          ),
                          loading: () => const LinearProgressIndicator(),
                        ),

                      if (widget.userToEdit != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SwitchListTile(
                            title: Text(
                              'Active Account',
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Text(
                              'Disable to prevent login',
                              style: TextStyle(color: hintColor),
                            ),
                            value: _isActive,
                            activeColor: Colors.blueAccent,
                            onChanged: (v) => setState(() => _isActive = v),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ... (keeping the buttons)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: hintColor)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _saveUser(sectionsAsync.valueOrNull ?? []),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUser(List<String> sections) async {
    // Safety check: ensure role is selected
    if (_selectedRole == null) {
      if (widget.allowedRoles != null && widget.allowedRoles!.isNotEmpty) {
        // If allowedRoles only has 1 and it's management, it might not be set in UI if hidden?
        // actually UI logic sets it if single.
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Determine if selected role is a section role
      String? finalSection = _selectedSection;

      // If the selected role is in the list of sections, strictly set section to that role
      if (sections.contains(_selectedRole)) {
        finalSection = _selectedRole;
      }

      if (widget.userToEdit == null) {
        await ref
            .read(authControllerProvider.notifier)
            .createUser(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              role: _selectedRole!,
              section: finalSection,
              employeeId: _employeeIdController.text.trim().isEmpty
                  ? null
                  : _employeeIdController.text.trim(),
            );
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .updateUser(
              uid: widget.userToEdit!.id,
              name: _nameController.text.trim(),
              role: _selectedRole!,
              section: finalSection,
              employeeId: _employeeIdController.text.trim().isEmpty
                  ? null
                  : _employeeIdController.text.trim(),
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
