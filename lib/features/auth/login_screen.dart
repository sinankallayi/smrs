import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/glass_container.dart';
import 'auth_provider.dart';
import 'widgets/grid_painter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // Navigation is handled by router redirect
    } catch (e) {
      if (mounted) {
        _showError("Oops! ${e.toString().split(']').last.trim()}");
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
          // Background - Professional Dark Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF263238), // Blue Grey 900
                  Color(0xFF37474F), // Blue Grey 800
                  Color(0xFF000000), // Black
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Subtle Tech overlay pattern
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40), // Top spacing
                  GlassContainer(
                    width: 400,
                    opacity: 0.2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.shieldCheck,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'SMRS Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your credentials to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 32),
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
                            obscureText: _isObscured,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(
                                LucideIcons.lock,
                                color: Colors.white70,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => _isObscured = !_isObscured),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                  child: Icon(
                                    _isObscured
                                        ? LucideIcons.eye
                                        : LucideIcons.eyeOff,
                                    key: ValueKey<bool>(_isObscured),
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white10,
                              border: InputBorder.none,
                              hintStyle: const TextStyle(color: Colors.white60),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    Colors.blueGrey[900], // Updated color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
