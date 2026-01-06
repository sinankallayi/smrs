import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/models/user_model.dart';
import '../../features/admin/create_user_dialog.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';

class ManageStaffScreen extends ConsumerStatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  ConsumerState<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends ConsumerState<ManageStaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showInactive = false;
  String? _selectedSection;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Access current user to fully act on restrictions
    final currentUser = ref.watch(userProfileProvider).valueOrNull;
    final canManage =
        currentUser != null &&
        (currentUser.role == AppRoles.superAdmin ||
            currentUser.role == AppRoles.hr);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff'), centerTitle: true),
      // Move StreamBuilder to the top to access data for filters
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'staff')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: GlassContainer(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert docs to models
          final allUsers = snapshot.data!.docs.map((doc) {
            return UserModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          // Extract Unique Sections dynamically
          final Set<String> uniqueSections = {};
          for (var user in allUsers) {
            if (user.section != null && user.section!.isNotEmpty) {
              uniqueSections.add(user.section!);
            }
          }
          final List<String> availableSections = uniqueSections.toList()
            ..sort();

          // Filter Logic
          final filteredUsers = allUsers.where((user) {
            if (!_showInactive && !user.isActive) return false;

            if (_selectedSection != null && user.section != _selectedSection) {
              return false;
            }

            if (_searchQuery.isEmpty) return true;

            return user.name.toLowerCase().contains(_searchQuery) ||
                user.email.toLowerCase().contains(_searchQuery) ||
                (user.employeeId?.toLowerCase().contains(_searchQuery) ??
                    false);
          }).toList();

          return Column(
            children: [
              // Search and Filter Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: AppTheme.glassDecoration(
                        context: context,
                        opacity: 0.15,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search by Name, Email, or ID...',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(LucideIcons.x, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips & Dynamic Dropdown
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Show Inactive'),
                            selected: _showInactive,
                            onSelected: (val) =>
                                setState(() => _showInactive = val),
                            backgroundColor: Colors.transparent,
                            selectedColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            side: BorderSide(
                              color: _showInactive
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dynamic Section Filter Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedSection != null
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: _selectedSection != null
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSection,
                                hint: Text(
                                  'All Sections',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  size: 16,
                                ),
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSection = newValue;
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Sections'),
                                  ),
                                  ...availableSections.map((String section) {
                                    return DropdownMenuItem<String>(
                                      value: section,
                                      child: Text(_toTitleCase(section)),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Staff List
              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 64,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No staff members found.',
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassContainer(
                              padding: EdgeInsets
                                  .zero, // ListTile internal padding handles it
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user.employeeId != null &&
                                        user.employeeId!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4.0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'ID: ${user.employeeId}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Text(
                                      '${_toTitleCase(user.name)}${!user.isActive ? " (DISABLED)" : ""}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: !user.isActive
                                            ? Colors.red
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.mail,
                                            size: 12,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user.email,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.briefcase,
                                            size: 12,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Section: ${user.section != null ? _toTitleCase(user.section!) : "None"}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: canManage
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              LucideIcons.edit,
                                              size: 18,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                            ),
                                            onPressed: () =>
                                                _showEditStaffDialog(user),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: canManage
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: _showAddStaffDialog,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text(
                    'Add Staff',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          const CreateUserDialog(allowedRoles: [AppRoles.staff]),
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
