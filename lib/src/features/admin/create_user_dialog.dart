import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/configuration/config_service.dart';
import '../../widgets/glass_container.dart';

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
  String? _selectedDesignation; // For Manager Titles
  bool _isLoading = false;
  bool _isActive = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.userToEdit != null) {
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      _employeeIdController.text = widget.userToEdit!.employeeId ?? '';
      _isActive = widget.userToEdit!.isActive;
      _selectedRole = widget.userToEdit!.role;
      _selectedSection = widget.userToEdit!.section;
      _selectedDesignation = widget.userToEdit!.designation;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final sectionsAsync = ref.watch(sectionsProvider);
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
                      // Employee ID Field - Always visible and required
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
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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
                          // Filter roles if allowedRoles is set
                          final validRoles =
                              widget.allowedRoles ??
                              roles
                                  .where((r) => r != AppRoles.superAdmin)
                                  .toList();

                          if (validRoles.isEmpty) {
                            return Text(
                              'No roles available',
                              style: TextStyle(color: textColor),
                            );
                          }

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

                          if (displayRoles.isNotEmpty) {
                            if (_selectedRole == null) {
                              _selectedRole = displayRoles.first;
                            }

                            // If only 1 role is available (e.g. Strict Section Head), show it as Text
                            if (displayRoles.length == 1) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: InputDecorator(
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
                                  child: Text(
                                    _selectedRole!.toUpperCase(),
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }

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
                                  // Reset dependent fields when role changes
                                  _selectedSection = null;
                                  _selectedDesignation = null;
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            );
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

                      // 1. MANAGER FLOW: Show "Manager Title" Dropdown - Sourced from Roles
                      if (_selectedRole == AppRoles.manager)
                        rolesAsync.when(
                          data: (managerTitles) {
                            if (managerTitles.isEmpty)
                              return const SizedBox.shrink();

                            // Exclude strict 'manager' string from titles unless explicitly desired
                            final titles = managerTitles
                                .where((t) => t != AppRoles.manager)
                                .toList();

                            if (titles.isEmpty) return const SizedBox.shrink();

                            return DropdownButtonFormField<String>(
                              value: _selectedDesignation,
                              style: TextStyle(color: textColor),
                              dropdownColor: isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              decoration: InputDecoration(
                                labelText: 'Manager Title',
                                labelStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: titles
                                  .map(
                                    (t) => DropdownMenuItem<String>(
                                      value: t,
                                      child: Text(
                                        t.toUpperCase(),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedDesignation = v),
                              validator: (v) =>
                                  (_selectedRole == AppRoles.manager &&
                                      v == null)
                                  ? 'Required'
                                  : null,
                            );
                          },
                          error: (e, _) => const SizedBox.shrink(),
                          loading: () => const LinearProgressIndicator(),
                        ),

                      // 2. SECTION HEAD & STAFF FLOW: Show "Section" Dropdown
                      if (_selectedRole == AppRoles.sectionHead ||
                          _selectedRole == AppRoles.staff)
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
                                if (_selectedRole == AppRoles.sectionHead &&
                                    v == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            );
                          },
                          error: (e, _) => Text(
                            'Error: $e',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: hintColor)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveUser(),
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

  Future<void> _saveUser() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Strict mapping:
      // Role is ALWAYS the System Role (_selectedRole).
      // Designation is passed for Managers.
      // Section is passed for Section Heads.

      if (widget.userToEdit == null) {
        await ref
            .read(authControllerProvider.notifier)
            .createUser(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              role: _selectedRole!,
              section: _selectedSection,
              designation: _selectedDesignation,
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
              section: _selectedSection,
              designation: _selectedDesignation,
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
} // End Class
