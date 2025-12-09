import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/glass_container.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

enum UserType { management, sectionHead }

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserType _userType = UserType.sectionHead;
  UserRole _selectedRole = UserRole.md;
  UserSection _selectedSection = UserSection.bakery;

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Determine Role and Section based on UserType
    UserRole finalRole;
    UserSection? finalSection;

    if (_userType == UserType.management) {
      finalRole = _selectedRole;
      finalSection = null;
    } else {
      finalRole = UserRole.sectionHead;
      finalSection = _selectedSection;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            role: finalRole,
            section: finalSection,
          );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                width: 400,
                opacity: 0.2,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(
                            LucideIcons.user,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white60),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(
                            LucideIcons.mail,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white60),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(
                            LucideIcons.lock,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white60),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // User Type Dropdown
                      DropdownButtonFormField<UserType>(
                        value: _userType,
                        dropdownColor: Colors.black87,
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            LucideIcons.users,
                            color: Colors.white70,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          DropdownMenuItem(
                            value: UserType.sectionHead,
                            child: const Text('Section Head'),
                          ),
                          DropdownMenuItem(
                            value: UserType.management,
                            child: const Text('Management'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _userType = v!),
                      ),
                      const SizedBox(height: 16),

                      // Conditional: Section Dropdown
                      if (_userType == UserType.sectionHead)
                        DropdownButtonFormField<UserSection>(
                          value: _selectedSection,
                          dropdownColor: Colors.black87,
                          decoration: const InputDecoration(
                            labelText: 'Section',
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              LucideIcons.store,
                              color: Colors.white70,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: UserSection.values.map((section) {
                            return DropdownMenuItem(
                              value: section,
                              child: Text(section.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedSection = v!),
                        ),

                      // Conditional: Role Dropdown
                      if (_userType == UserType.management)
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          dropdownColor: Colors.black87,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              LucideIcons.shield,
                              color: Colors.white70,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: [UserRole.md, UserRole.exd, UserRole.hr].map((
                            role,
                          ) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Register'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
