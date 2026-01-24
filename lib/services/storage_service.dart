import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _keyEmail = 'user_email';
  static const String _keyRole = 'user_role';
  static const String _keyDriverId = 'driver_id';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';

  // Save user session
  Future<void> saveSession({
    required String email,
    required UserRole role,
    String? driverId,
    String? userId,
  }) async {
    try {
      await _secureStorage.write(key: _keyEmail, value: email);
      await _secureStorage.write(
        key: _keyRole,
        value: role == UserRole.driver ? 'driver' : 'user',
      );

      if (driverId != null) {
        await _secureStorage.write(key: _keyDriverId, value: driverId);
      }

      if (userId != null) {
        await _secureStorage.write(key: _keyUserId, value: userId);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      throw Exception('Error al guardar sesión: ${e.toString()}');
    }
  }

  // Get stored session
  Future<Map<String, dynamic>?> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (!isLoggedIn) return null;

      final email = await _secureStorage.read(key: _keyEmail);
      final roleStr = await _secureStorage.read(key: _keyRole);
      final driverId = await _secureStorage.read(key: _keyDriverId);
      final userId = await _secureStorage.read(key: _keyUserId);

      if (email == null || roleStr == null) return null;

      final role = roleStr == 'driver' ? UserRole.driver : UserRole.user;

      return {
        'email': email,
        'role': role,
        'driverId': driverId,
        'userId': userId,
      };
    } catch (e) {
      return null;
    }
  }

  // Check if user has active session
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Clear session (logout)
  Future<void> clearSession() async {
    try {
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Get specific session data
  Future<String?> getEmail() async {
    return await _secureStorage.read(key: _keyEmail);
  }

  Future<UserRole?> getRole() async {
    final roleStr = await _secureStorage.read(key: _keyRole);
    if (roleStr == null) return null;
    return roleStr == 'driver' ? UserRole.driver : UserRole.user;
  }

  Future<String?> getDriverId() async {
    return await _secureStorage.read(key: _keyDriverId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }
}
