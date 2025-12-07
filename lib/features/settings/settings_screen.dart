import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/glass_container.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              GlassContainer(
                child: Column(
                  children: [
                    _buildSectionHeader('Appearance'),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: themeState?.themeMode == ThemeMode.dark,
                      onChanged: (val) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .updateThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                    const ListTile(title: Text('Accent Color')),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ColorOption(
                          color: Colors.blue,
                          selected: themeState?.seedColor == Colors.blue,
                        ),
                        _ColorOption(
                          color: Colors.purple,
                          selected: themeState?.seedColor == Colors.purple,
                        ),
                        _ColorOption(
                          color: Colors.green,
                          selected: themeState?.seedColor == Colors.green,
                        ),
                        _ColorOption(
                          color: Colors.orange,
                          selected: themeState?.seedColor == Colors.orange,
                        ),
                        _ColorOption(
                          color: Colors.red,
                          selected: themeState?.seedColor == Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GlassContainer(
                child: ListTile(
                  leading: const Icon(LucideIcons.logOut, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends ConsumerWidget {
  final Color color;
  final bool selected;

  const _ColorOption({required this.color, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(themeControllerProvider.notifier).updateColor(color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
