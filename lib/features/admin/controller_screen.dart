import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../configuration/config_service.dart';
import '../../shared/models/user_model.dart';

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
              Tab(text: 'Roles', icon: Icon(LucideIcons.shield)),
              Tab(text: 'Sections', icon: Icon(LucideIcons.layoutGrid)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCcw),
              tooltip: 'Initialize Defaults',
              onPressed: () {
                ref.read(configServiceProvider.notifier).initializeDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Defaults initialized')),
                );
              },
            ),
          ],
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
                    role != AppRoles.staff,
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
                  'Add New ${type == ConfigType.role ? 'Role' : 'Section'}',
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
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.toUpperCase()),
                            trailing: IconButton(
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${type == ConfigType.role ? 'Role' : 'Section'}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Value',
            hintText: 'e.g. manager',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                if (type == ConfigType.role) {
                  ref.read(configServiceProvider.notifier).addRole(value);
                } else {
                  ref.read(configServiceProvider.notifier).addSection(value);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
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
