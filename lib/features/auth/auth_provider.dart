import 'package:firebase_auth/firebase_auth.dart';
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
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final user = UserModel(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      role: role,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
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
