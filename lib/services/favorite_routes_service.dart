import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

/// Service to manage favorite routes
/// Syncs with Firebase and maintains local cache for offline access
class FavoriteRoutesService {
  static final FavoriteRoutesService _instance =
      FavoriteRoutesService._internal();
  factory FavoriteRoutesService() => _instance;
  FavoriteRoutesService._internal();

  final DatabaseService _databaseService = DatabaseService();
  static const String _favoritesKey = 'favorite_routes';

  // Local cache
  List<String> _cachedFavorites = [];
  bool _isInitialized = false;

  /// Initialize the service and load favorites from Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _syncFromFirebase(user.uid);
    } else {
      // Load from local cache if not logged in
      await _loadFromLocalCache();
    }

    _isInitialized = true;
    debugPrint(
      '✅ FavoriteRoutesService initialized with ${_cachedFavorites.length} favorites',
    );
  }

  /// Sync favorites from Firebase to local cache
  Future<void> _syncFromFirebase(String userId) async {
    try {
      final favorites = await _databaseService.getFavoriteRoutesFromFirebase(
        userId,
      );
      _cachedFavorites = favorites;
      await _saveToLocalCache(favorites);
      debugPrint('✅ Synced ${favorites.length} favorites from Firebase');
    } catch (e) {
      debugPrint('❌ Error syncing from Firebase: $e');
      // Fallback to local cache
      await _loadFromLocalCache();
    }
  }

  /// Load favorites from local cache
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      _cachedFavorites = favoritesJson;
      debugPrint(
        '✅ Loaded ${_cachedFavorites.length} favorites from local cache',
      );
    } catch (e) {
      debugPrint('❌ Error loading from local cache: $e');
      _cachedFavorites = [];
    }
  }

  /// Save favorites to local cache
  Future<void> _saveToLocalCache(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      debugPrint('❌ Error saving to local cache: $e');
    }
  }

  /// Add a route to favorites
  Future<void> addFavoriteRoute(String routeName) async {
    if (_cachedFavorites.contains(routeName)) {
      debugPrint('⚠️ Route $routeName is already a favorite');
      return;
    }

    // Add to local cache immediately
    _cachedFavorites.add(routeName);
    await _saveToLocalCache(_cachedFavorites);

    // Sync to Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _databaseService.saveFavoriteRoute(user.uid, routeName);
        debugPrint('✅ Added $routeName to favorites (synced to Firebase)');
      } catch (e) {
        debugPrint('❌ Error syncing to Firebase: $e');
        // Keep in local cache anyway
      }
    } else {
      debugPrint(
        '✅ Added $routeName to favorites (local only - not logged in)',
      );
    }
  }

  /// Remove a route from favorites
  Future<void> removeFavoriteRoute(String routeName) async {
    if (!_cachedFavorites.contains(routeName)) {
      debugPrint('⚠️ Route $routeName is not in favorites');
      return;
    }

    // Remove from local cache immediately
    _cachedFavorites.remove(routeName);
    await _saveToLocalCache(_cachedFavorites);

    // Sync to Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _databaseService.removeFavoriteRoute(user.uid, routeName);
        debugPrint('✅ Removed $routeName from favorites (synced to Firebase)');
      } catch (e) {
        debugPrint('❌ Error syncing to Firebase: $e');
        // Keep removed from local cache anyway
      }
    } else {
      debugPrint(
        '✅ Removed $routeName from favorites (local only - not logged in)',
      );
    }
  }

  /// Check if a route is a favorite
  bool isFavorite(String routeName) {
    return _cachedFavorites.contains(routeName);
  }

  /// Get all favorite routes
  Future<List<String>> getFavoriteRoutes() async {
    if (!_isInitialized) {
      await initialize();
    }
    return List.from(_cachedFavorites);
  }

  /// Get favorite routes count
  int getFavoriteCount() {
    return _cachedFavorites.length;
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _cachedFavorites.clear();
    await _saveToLocalCache([]);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Remove all from Firebase
      final favorites = await _databaseService.getFavoriteRoutesFromFirebase(
        user.uid,
      );
      for (final routeName in favorites) {
        await _databaseService.removeFavoriteRoute(user.uid, routeName);
      }
    }

    debugPrint('✅ Cleared all favorites');
  }

  /// Force sync from Firebase (useful after login)
  Future<void> forceSync() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _syncFromFirebase(user.uid);
    }
  }
}
