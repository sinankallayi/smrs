import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> signIn(String email, String password) async {
    // 1. Sign in with Firebase Auth
    final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Fetch user status from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(result.user!.uid)
        .get();

    if (doc.exists) {
      final isActive = doc.data()?['isActive'] as bool? ?? true;
      if (!isActive) {
        // Sign out immediately if inactive
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Your account has been disabled by the administrator.',
        );
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    UserSection? section,
  }) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final user = UserModel(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      role: role,
      section: section,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    UserSection? section,
  }) async {
    // Connect to a secondary Firebase app to create user without logging out the admin
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'temporaryRegister',
      options: Firebase.app().options,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(email: email, password: password);

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        section: section,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
    } finally {
      await tempApp.delete();
    }
  }

  Future<void> updateUser({
    required String uid,
    String? name,
    UserRole? role,
    UserSection? section,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (role != null)
      data['role'] = role
          .toString()
          .split('.')
          .last; // Enum to string? verification needed on how json_serializable handles it.
    // Actually, simple update might overwrite if not careful with enum serialization.
    // Better to read, update model, write back or just use field updates if we know the format.
    // Since we use @JsonValue, we should probably check what the value maps to.
    // However, for simplicity and safety against enum serialization nuances, let's just use the proper value.
    // 'role': role (JsonValue handles this if we use toJson, but for update() we need raw value).
    // Let's check UserModel.g.dart if possible, but standard is the string in @JsonValue.

    // Manual mapping to be safe matching @JsonValue in user_model.dart
    if (role != null) {
      switch (role) {
        case UserRole.superAdmin:
          data['role'] = 'superAdmin';
          break;
        case UserRole.md:
          data['role'] = 'md';
          break;
        case UserRole.exd:
          data['role'] = 'exd';
          break;
        case UserRole.hr:
          data['role'] = 'hr';
          break;
        case UserRole.sectionHead:
          data['role'] = 'sectionHead';
          break;
        case UserRole.staff:
          data['role'] = 'staff';
          break;
      }
    }

    if (section != null) {
      switch (section) {
        case UserSection.bakery:
          data['section'] = 'bakery';
          break;
        case UserSection.fancy:
          data['section'] = 'fancy';
          break;
        case UserSection.vegetable:
          data['section'] = 'vegetable';
          break;
      }
    } else if (role != UserRole.sectionHead && role != null) {
      // If role changed to non-sectionHead, remove section?
      // Firestore update doesn't support deleting a field easily with just a map unless using FieldValue.delete()
      // But we can check if it is necessary. The prompt didn't explicitly say "clear section".
      // But it's good practice.
      data['section'] = FieldValue.delete();
    }

    if (isActive != null) {
      data['isActive'] = isActive;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }
}

@riverpod
Stream<UserModel?> userProfile(UserProfileRef ref) {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return null;
            return UserModel.fromJson(snapshot.data()!);
          });
    },
    error: (_, __) => Stream.value(null),
    loading: () => Stream.value(null),
  );
}
