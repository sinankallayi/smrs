import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> signIn(String identifier, String password) async {
    String email = identifier;

    // 1. Check if identifier is an email
    if (!identifier.contains('@')) {
      // It's likely an Employee ID, look up the email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('employeeId', isEqualTo: identifier)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        email = querySnapshot.docs.first.data()['email'] as String;
      } else {
        // Fallback: Check legacy staffId just in case
        final legacyQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('staffId', isEqualTo: identifier)
            .limit(1)
            .get();

        if (legacyQuery.docs.isNotEmpty) {
          email = legacyQuery.docs.first.data()['email'] as String;
        } else {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this Employee ID.',
          );
        }
      }
    }

    // 2. Sign in with Firebase Auth
    final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 3. Fetch user status from Firestore
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
      employeeId:
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
    String? employeeId,
  }) async {
    if (employeeId != null) {
      final isUnique = await checkEmployeeIdUnique(employeeId);
      if (!isUnique) throw Exception('Employee ID already exists');
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
        employeeId: employeeId,
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
    String? employeeId,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (role != null) data['role'] = role;
    if (employeeId != null) {
      final isUnique = await checkEmployeeIdUnique(employeeId, excludeUid: uid);
      if (!isUnique) throw Exception('Employee ID already exists');
      data['employeeId'] = employeeId;
      // Also update or set staffId for backward compatibility?
      // User asked to CHANGE staffId into employeeId.
      // We can just write employeeId. Old staffId fields remain as legacy.
    }
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

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<bool> checkEmployeeIdUnique(
    String employeeId, {
    String? excludeUid,
  }) async {
    // Check against 'employeeId' field
    final query1 = await FirebaseFirestore.instance
        .collection('users')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    if (query1.docs.isNotEmpty) {
      if (excludeUid != null && query1.docs.first.id == excludeUid) {
        // Same user, ignore
      } else {
        return false;
      }
    }

    // Check against 'staffId' field (legacy)
    final query2 = await FirebaseFirestore.instance
        .collection('users')
        .where('staffId', isEqualTo: employeeId)
        .get();

    if (query2.docs.isNotEmpty) {
      if (excludeUid != null && query2.docs.first.id == excludeUid) {
        // Same user, ignore
      } else {
        return false;
      }
    }

    return true;
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
