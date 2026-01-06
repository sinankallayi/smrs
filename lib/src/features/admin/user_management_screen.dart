import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/user_model.dart';
import 'create_user_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  final List<String>? allowedRoles;
  final String title;

  const UserManagementScreen({
    super.key,
    this.allowedRoles,
    this.title = 'User Management',
  });

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name, Role or Email',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs
                    .map((doc) {
                      return UserModel.fromJson(
                        doc.data() as Map<String, dynamic>,
                      );
                    })
                    // Filter out superAdmin
                    .where((user) => user.role != AppRoles.superAdmin)
                    // Filter by allowed roles if provided
                    .where((user) {
                      if (widget.allowedRoles == null) return true;
                      return widget.allowedRoles!.contains(user.role);
                    })
                    .where((user) {
                      final matches =
                          user.name.toLowerCase().contains(_searchQuery) ||
                          user.email.toLowerCase().contains(_searchQuery) ||
                          user.role.toLowerCase().contains(_searchQuery);
                      return matches;
                    })
                    .toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name[0].toUpperCase()),
                      ),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.role == AppRoles.manager
                                ? '${user.email} • ${user.designation?.toUpperCase() ?? user.role.toUpperCase()}'
                                : user.role == AppRoles.sectionHead
                                ? '${user.email} • ${user.section?.toUpperCase() ?? "NO SECTION"}'
                                : '${user.email} • ${user.role.toUpperCase()}',
                          ),
                          if (user.employeeId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Emp ID: ${user.employeeId}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.red),
                        onPressed: () {
                          // Implement delete functionality
                          _confirmDelete(context, user);
                        },
                      ),
                      onTap: () {
                        // Implement edit functionality
                        // If we are in a restrictive mode, ensure we pass the allowed roles
                        // so they can't change a SectionHead to an MD for example
                        showDialog(
                          context: context,
                          builder: (_) => CreateUserDialog(
                            userToEdit: user,
                            allowedRoles: widget.allowedRoles,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateUserDialog(allowedRoles: widget.allowedRoles),
          );
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .delete();
              // Note: This only deletes from Firestore.
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
