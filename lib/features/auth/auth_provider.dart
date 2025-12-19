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
    required String role,
    String? section,
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
    required String role,
    String? section,
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

      if (userCredential.user == null) {
        throw Exception("Failed to create user: Firebase returned null");
      }

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
    String? role,
    String? section,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (role != null) data['role'] = role;
    if (section != null) {
      data['section'] = section;
    } else if (role != AppRoles.sectionHead && role != null) {
      // If role changed to non-sectionHead, remove section
      data['section'] = FieldValue.delete();
    }

    if (isActive != null) {
      data['isActive'] = isActive;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
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
