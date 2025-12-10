import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/user_model.dart';
import '../../features/admin/create_user_dialog.dart'; // Import reusable dialog

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage Staff')),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'staff') // String 'staff'
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            if (docs.isEmpty)
              return const Center(child: Text('No staff members found.'));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final user = UserModel.fromJson(data);
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(LucideIcons.user)),
                    title: Text(
                      '${user.name}${!user.isActive ? " (DISABLED)" : ""}',
                    ),
                    subtitle: Text(
                      '${user.email}\nSection: ${user.section ?? "None"}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!user.isActive)
                          const Icon(
                            LucideIcons.ban,
                            color: Colors.red,
                            size: 16,
                          ),
                        IconButton(
                          icon: const Icon(LucideIcons.edit, size: 20),
                          onPressed: () => _showEditStaffDialog(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddStaffDialog,
          child: const Icon(LucideIcons.plus),
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateUserDialog(
        allowedRoles: [AppRoles.staff], // Restrict to Staff only
      ),
    );
  }

  void _showEditStaffDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        userToEdit: user,
        allowedRoles: const [AppRoles.staff],
      ),
    );
  }
}
