import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/configuration/config_service.dart';
import '../../models/user_model.dart';

class ControllerScreen extends ConsumerWidget {
  const ControllerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Controller'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manager Titles', icon: Icon(LucideIcons.shield)),
              Tab(text: 'Sections', icon: Icon(LucideIcons.layoutGrid)),
            ],
          ),
          actions: [],
        ),
        body: const TabBarView(
          children: [
            _ConfigList(type: ConfigType.role),
            _ConfigList(type: ConfigType.section),
          ],
        ),
      ),
    );
  }
}

enum ConfigType { role, section }

class _ConfigList extends ConsumerWidget {
  final ConfigType type;

  const _ConfigList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(configServiceProvider.notifier);
    final stream = type == ConfigType.role
        ? notifier.getRoles()
        : notifier.getSections();

    return StreamBuilder<List<String>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data ?? [];

        if (type == ConfigType.role) {
          items = items
              .where(
                (role) =>
                    role != AppRoles.superAdmin &&
                    role != AppRoles.sectionHead &&
                    role != AppRoles.staff &&
                    role != AppRoles.management &&
                    role !=
                        AppRoles.hr, // Exclude HR from generic managers list
              )
              .toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(LucideIcons.plus),
                label: Text(
                  'Add New ${type == ConfigType.role ? 'Manager Title' : 'Section'}',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items found'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 100,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.toUpperCase()),
                            trailing: item == AppRoles.hr
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      LucideIcons.trash2,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, ref, item),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add ${type == ConfigType.role ? 'Manager Title' : 'Section'}',
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Value',
              hintText: 'e.g. manager',
              border: OutlineInputBorder(),
            ),
            enabled: !isSubmitting,
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final value = controller.text.trim();
                      if (value.isNotEmpty) {
                        setState(() => isSubmitting = true);
                        try {
                          if (type == ConfigType.role) {
                            await ref
                                .read(configServiceProvider.notifier)
                                .addRole(value);
                          } else {
                            await ref
                                .read(configServiceProvider.notifier)
                                .addSection(value);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "$value" successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding item: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted &&
                              Navigator.canPop(context) == false) {
                            // If dialog is still open (error case w/o pop? no we pop on success)
                            setState(() => isSubmitting = false);
                          }
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove "$item"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (type == ConfigType.role) {
                ref.read(configServiceProvider.notifier).removeRole(item);
              } else {
                ref.read(configServiceProvider.notifier).removeSection(item);
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
