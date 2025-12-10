import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/glass_container.dart';
import 'auth_provider.dart';
import 'widgets/login_mascot.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isObscured = true;
  bool _isPasswordFocused = false;
  double _textPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    _emailController.addListener(() {
      // Calculate cursor position factor (0.0 to 1.0)
      // Assuming 30 characters is max width "look"
      final length = _emailController.text.length;
      setState(() {
        _textPosition = (length / 30.0).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

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
          // Background - Mesh Gradient Placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginMascot(
                    isPasswordFocused: _isPasswordFocused,
                    textPosition: _textPosition,
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    width: 400,
                    opacity: 0.2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'SMRS Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
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
                            focusNode: _passwordFocusNode,
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
                                foregroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Sign In'),
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
