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
      staffId:
          null, // Register is usually for self-register, maybe we don't expose staffId here or make it optional? Assuming null for now or need to add it to params.
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
    String? staffId,
  }) async {
    if (staffId != null) {
      final isUnique = await checkStaffIdUnique(staffId);
      if (!isUnique) throw Exception('Staff ID already exists');
    }
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
        staffId: staffId,
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
    String? staffId,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (role != null) data['role'] = role;
    if (staffId != null) {
      // Check uniqueness only if it's different from current?
      // Ideally we should check if it's being changed.
      // For simplicity, we check if it exists and current user isn't the owner.
      // But here we might not have the old value easily without fetching.
      // Let's assume the caller handles this check or we check it blindly.
      // Better: check if unique. If not unique, we need to know if it belongs to THIS user.
      final isUnique = await checkStaffIdUnique(staffId, excludeUid: uid);
      if (!isUnique) throw Exception('Staff ID already exists');
      data['staffId'] = staffId;
    }
    if (section != null) {
      data['section'] = section;
    } else if (role != AppRoles.sectionHead && role != null) {
      // If role changed to non-sectionHead, remove section
      data['section'] = FieldValue.delete();
    }

    if (role != null && role != AppRoles.staff) {
      data['staffId'] = FieldValue.delete();
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

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<bool> checkStaffIdUnique(String staffId, {String? excludeUid}) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('staffId', isEqualTo: staffId)
        .get();

    if (query.docs.isEmpty) return true;

    if (excludeUid != null) {
      // If we found a doc, check if it's the same user
      return query.docs.first.id == excludeUid;
    }

    return false;
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
