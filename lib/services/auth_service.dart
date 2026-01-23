import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return await getUserData(result.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user data in Realtime Database
        final userData = UserModel(
          uid: result.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
        );

        await _database
            .child('users')
            .child(result.user!.uid)
            .set(userData.toJson());

        // Update display name in Firebase Auth
        await result.user!.updateDisplayName(displayName);

        return userData;
      }
      return null;
    } catch (e) {
      throw Exception('Error al registrarse: ${e.toString()}');
    }
  }

  // Get user data from database
  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _database.child('users').child(uid).get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(
        'Error al enviar correo de recuperación: ${e.toString()}',
      );
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _database.child('users').child(uid).update({'role': newRole});
    } catch (e) {
      throw Exception('Error al actualizar rol: ${e.toString()}');
    }
  }
}
