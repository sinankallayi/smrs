import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_service.g.dart';

@riverpod
Stream<List<String>> roles(RolesRef ref) {
  return ref.watch(configServiceProvider.notifier).getRoles();
}

@riverpod
Stream<List<String>> sections(SectionsRef ref) {
  return ref.watch(configServiceProvider.notifier).getSections();
}

@riverpod
class ConfigService extends _$ConfigService {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _settingsColl =>
      FirebaseFirestore.instance.collection('settings');

  Stream<List<String>> getRoles() {
    return _settingsColl.doc('roles').snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data();
      if (data == null || !data.containsKey('values')) return [];
      return List<String>.from(data['values']);
    });
  }

  Stream<List<String>> getSections() {
    return _settingsColl.doc('sections').snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data();
      if (data == null || !data.containsKey('values')) return [];
      return List<String>.from(data['values']);
    });
  }

  Future<void> addRole(String role) async {
    final docRef = _settingsColl.doc('roles');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'values': [role],
        });
      } else {
        final currentList = List<String>.from(snapshot.data()!['values'] ?? []);
        if (!currentList.contains(role)) {
          currentList.add(role);
          transaction.update(docRef, {'values': currentList});
        }
      }
    });
  }

  Future<void> removeRole(String role) async {
    final docRef = _settingsColl.doc('roles');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final currentList = List<String>.from(snapshot.data()!['values'] ?? []);
        if (currentList.contains(role)) {
          currentList.remove(role);
          transaction.update(docRef, {'values': currentList});
        }
      }
    });
  }

  Future<void> addSection(String section) async {
    final docRef = _settingsColl.doc('sections');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'values': [section],
        });
      } else {
        final currentList = List<String>.from(snapshot.data()!['values'] ?? []);
        if (!currentList.contains(section)) {
          currentList.add(section);
          transaction.update(docRef, {'values': currentList});
        }
      }
    });
  }

  Future<void> removeSection(String section) async {
    final docRef = _settingsColl.doc('sections');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final currentList = List<String>.from(snapshot.data()!['values'] ?? []);
        if (currentList.contains(section)) {
          currentList.remove(section);
          transaction.update(docRef, {'values': currentList});
        }
      }
    });
  }

  // Initialize defaults if empty
  Future<void> initializeDefaults() async {
    final rolesSnapshot = await _settingsColl.doc('roles').get();
    if (!rolesSnapshot.exists) {
      await _settingsColl.doc('roles').set({
        'values': ['superAdmin', 'md', 'exd', 'hr', 'sectionHead', 'staff'],
      });
    }

    final sectionsSnapshot = await _settingsColl.doc('sections').get();
    if (!sectionsSnapshot.exists) {
      await _settingsColl.doc('sections').set({
        'values': ['bakery', 'fancy', 'vegetable'],
      });
    }
  }
}
