import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth state listener
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Firebase User (Student)
        _currentUser = await _authService.getUserData(user.uid);
      } else {
        // Check for local driver session
        await checkSession();
      }
      notifyListeners();
    });
  }

  // Explicitly check and load session from storage
  Future<void> checkSession() async {
    try {
      final session = await _storageService.getSession();
      if (session != null && session['role'] == UserRole.driver) {
        final driverId = session['driverId'] as String;
        _currentUser = _createDriverUser(driverId);
        debugPrint('✅ Driver session restored: $driverId');
      } else {
        // Only set to null if we don't have a firebase user either
        // (This part is tricky if called from stream listener, but safe if called directly)
        if (_authService.currentUser == null) {
          _currentUser = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error checking session: $e');
    }
  }

  // Create a local UserModel for a driver
  UserModel _createDriverUser(String driverId) {
    final routeName = _parseRouteFromDriverId(driverId);
    return UserModel(
      uid: driverId,
      email: '$driverId@rutapuma.local', // Placeholder
      displayName: 'Conductor $driverId',
      role: 'DRIVER',
      createdAt: DateTime.now(),
      assignedRoute: routeName,
    );
  }

  // Helper to parse route from BUSxxYY
  String _parseRouteFromDriverId(String driverId) {
    // Format: BUS0101 -> Ruta 01
    // Format: BUS1402 -> Ruta 14
    try {
      if (driverId.length >= 5 && driverId.startsWith('BUS')) {
        final routeNum = int.parse(driverId.substring(3, 5));
        return 'Ruta $routeNum';
      }
    } catch (_) {}
    return 'Ruta Desconocida';
  }

  // Login for Drivers
  Future<bool> loginDriver(String driverId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate credentials against hardcoded pattern
      // Check 14 routes, 2 IDs each
      bool authenticated = false;
      for (int r = 1; r <= 14; r++) {
        final rStr = r.toString().padLeft(2, '0');
        for (int i = 1; i <= 2; i++) {
          final iStr = i.toString().padLeft(2, '0');
          final id = 'BUS$rStr$iStr';
          final key = 'ruta$rStr$iStr';

          if (driverId.toUpperCase() == id && password == key) {
            authenticated = true;
            break;
          }
        }
        if (authenticated) break;
      }

      if (!authenticated) {
        throw Exception('ID o Llave del bus incorrecta');
      }

      // Create and set user
      _currentUser = _createDriverUser(driverId.toUpperCase());

      // Save session
      await _storageService.saveSession(
        email: driverId.toUpperCase(),
        role: UserRole.driver,
        driverId: driverId.toUpperCase(),
        userId: driverId.toUpperCase(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in (Firebase)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    // ... existing implementation ...
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      // Save session for persistent login
      if (_currentUser != null) {
        await _storageService.saveSession(
          email: email,
          role: _currentUser!.role == 'USER' ? UserRole.user : UserRole.driver,
          userId: _currentUser!.uid,
        );
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );

      // Note: We don't auto-save session on registration
      // User needs to login after registration

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await _storageService.clearSession(); // Clear saved session
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
