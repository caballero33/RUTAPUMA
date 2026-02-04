import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Update bus location (for drivers)
  Future<void> updateBusLocation({
    required String busId,
    required String driverId,
    required String routeName,
    required LatLng location,
    required double speed,
    required double heading,
  }) async {
    try {
      final busData = BusModel(
        busId: busId,
        driverId: driverId,
        routeName: routeName,
        currentLocation: location,
        timestamp: DateTime.now(),
        isActive: true,
        speed: speed,
        heading: heading,
      );

      await _database.child('buses').child(busId).set(busData.toJson());
    } catch (e) {
      throw Exception('Error al actualizar ubicación del bus: ${e.toString()}');
    }
  }

  // Set bus as inactive
  Future<void> setBusInactive(String busId) async {
    try {
      await _database.child('buses').child(busId).update({
        'isActive': false,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al desactivar bus: ${e.toString()}');
    }
  }

  // Helper method to convert Firebase Map to Map<String, dynamic>
  Map<String, dynamic> _convertMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) {
          if (value is Map) {
            return MapEntry(key.toString(), _convertMap(value));
          }
          return MapEntry(key.toString(), value);
        }),
      );
    }
    return {};
  }

  // Listen to all active buses (for users)
  Stream<List<BusModel>> getActiveBuses() {
    return _database.child('buses').onValue.map((event) {
      debugPrint('🔥 Firebase onValue triggered');
      final List<BusModel> buses = [];

      if (event.snapshot.exists) {
        debugPrint('✅ Snapshot exists');
        final data = _convertMap(event.snapshot.value);
        debugPrint('📦 Datos crudos de Firebase: ${data.keys.length} buses');

        data.forEach((busId, busData) {
          try {
            final bus = BusModel.fromJson(busId, _convertMap(busData));

            // Calculate time difference
            final timeDiff = DateTime.now().difference(bus.timestamp);
            debugPrint(
              '   🚌 $busId - Activo: ${bus.isActive}, Tiempo: ${timeDiff.inMinutes} min',
            );

            // Only include buses that are currently active
            // Remove the strict time filter to allow buses to reappear after restart
            if (bus.isActive) {
              // Optional: Only filter out buses that haven't updated in a very long time (e.g., 1 hour)
              // This prevents showing stale data from buses that crashed or lost connection
              if (timeDiff.inHours < 1) {
                buses.add(bus);
                debugPrint('      ✅ Bus agregado a la lista');
              } else {
                debugPrint(
                  '      ⚠️ Bus muy antiguo (${timeDiff.inHours} horas)',
                );
              }
            } else {
              debugPrint('      ❌ Bus inactivo');
            }
          } catch (e) {
            debugPrint('   ❌ Error parseando bus $busId: $e');
          }
        });
      } else {
        debugPrint('❌ Snapshot NO exists - No hay buses en Firebase');
      }

      debugPrint('📊 Total buses activos para mostrar: ${buses.length}');
      return buses;
    });
  }

  // Listen to a specific bus
  Stream<BusModel?> getBusById(String busId) {
    return _database.child('buses').child(busId).onValue.map((event) {
      if (event.snapshot.exists) {
        final data = _convertMap(event.snapshot.value);
        return BusModel.fromJson(busId, data);
      }
      return null;
    });
  }

  // Get buses by route
  Stream<List<BusModel>> getBusesByRoute(String routeName) {
    return _database
        .child('buses')
        .orderByChild('routeName')
        .equalTo(routeName)
        .onValue
        .map((event) {
          final List<BusModel> buses = [];

          if (event.snapshot.exists) {
            final data = _convertMap(event.snapshot.value);

            data.forEach((busId, busData) {
              final bus = BusModel.fromJson(busId, _convertMap(busData));

              // Only include active buses
              final timeDiff = DateTime.now().difference(bus.timestamp);
              if (bus.isActive && timeDiff.inMinutes < 5) {
                buses.add(bus);
              }
            });
          }

          return buses;
        });
  }

  // Create or update route information
  Future<void> saveRoute({
    required String routeId,
    required String name,
    required String description,
    required List<Map<String, dynamic>> stops,
  }) async {
    try {
      await _database.child('routes').child(routeId).set({
        'name': name,
        'description': description,
        'stops': stops,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al guardar ruta: ${e.toString()}');
    }
  }

  // Get all routes
  Future<List<Map<String, dynamic>>> getAllRoutes() async {
    try {
      final snapshot = await _database.child('routes').get();
      final List<Map<String, dynamic>> routes = [];

      if (snapshot.exists) {
        final data = _convertMap(snapshot.value);

        data.forEach((routeId, routeData) {
          routes.add({'routeId': routeId, ..._convertMap(routeData)});
        });
      }

      return routes;
    } catch (e) {
      throw Exception('Error al obtener rutas: ${e.toString()}');
    }
  }

  // ==================== FAVORITE ROUTES METHODS ====================

  /// Save a favorite route for a user
  Future<void> saveFavoriteRoute(String userId, String routeName) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('favoriteRoutes')
          .child(routeName)
          .set(true);
      debugPrint('✅ Saved favorite route: $routeName for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving favorite route: $e');
      throw Exception('Error al guardar ruta favorita: ${e.toString()}');
    }
  }

  /// Remove a favorite route for a user
  Future<void> removeFavoriteRoute(String userId, String routeName) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('favoriteRoutes')
          .child(routeName)
          .remove();
      debugPrint('✅ Removed favorite route: $routeName for user: $userId');
    } catch (e) {
      debugPrint('❌ Error removing favorite route: $e');
      throw Exception('Error al eliminar ruta favorita: ${e.toString()}');
    }
  }

  /// Get all favorite routes for a user from Firebase
  Future<List<String>> getFavoriteRoutesFromFirebase(String userId) async {
    try {
      final snapshot =
          await _database
              .child('users')
              .child(userId)
              .child('favoriteRoutes')
              .get();

      if (!snapshot.exists) {
        return [];
      }

      final data = _convertMap(snapshot.value);
      final List<String> favoriteRoutes = [];

      data.forEach((routeName, isFavorite) {
        if (isFavorite == true) {
          favoriteRoutes.add(routeName.toString());
        }
      });

      debugPrint(
        '✅ Loaded ${favoriteRoutes.length} favorite routes for user: $userId',
      );
      return favoriteRoutes;
    } catch (e) {
      debugPrint('❌ Error getting favorite routes: $e');
      return [];
    }
  }

  /// Listen to favorite routes changes in real-time
  Stream<List<String>> watchFavoriteRoutes(String userId) {
    return _database
        .child('users')
        .child(userId)
        .child('favoriteRoutes')
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <String>[];
          }

          final data = _convertMap(event.snapshot.value);
          final List<String> favoriteRoutes = [];

          data.forEach((routeName, isFavorite) {
            if (isFavorite == true) {
              favoriteRoutes.add(routeName.toString());
            }
          });

          return favoriteRoutes;
        });
  }

  // ==================== FCM TOKEN METHODS ====================

  /// Update FCM token for a user
  Future<void> updateFcmToken(String userId, String fcmToken) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('fcmToken')
          .set(fcmToken);
      debugPrint('✅ Updated FCM token for user: $userId');
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
      throw Exception('Error al actualizar token FCM: ${e.toString()}');
    }
  }

  /// Save user profile data (for registration)
  Future<void> saveUserProfile({
    required String userId,
    required String email,
    required String name,
    required String role,
    String? fcmToken,
  }) async {
    try {
      final userData = {
        'email': email,
        'name': name,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (fcmToken != null) {
        userData['fcmToken'] = fcmToken;
      }

      debugPrint('✅ Saved user profile for: $userId');
    } catch (e) {
      debugPrint('❌ Error saving user profile: $e');
      throw Exception('Error al guardar perfil de usuario: ${e.toString()}');
    }
  }

  /// Update user's assigned route
  Future<void> updateUserRoute(String userId, String routeName) async {
    try {
      await _database.child('users').child(userId).update({
        'assignedRoute': routeName,
      });
      debugPrint('✅ Updated assigned route $routeName for user $userId');
    } catch (e) {
      debugPrint('❌ Error updating user route: $e');
      // Don't throw, just log
    }
  }

  // ==================== ANNOUNCEMENT METHODS ====================

  /// Save a new announcement
  Future<void> saveAnnouncement({
    required String driverId,
    required String driverName, // Optional: if we want to show who sent it
    required String routeName,
    required String subject,
    required String message,
  }) async {
    try {
      final announcementId = _database.child('announcements').push().key;

      await _database.child('announcements').child(announcementId!).set({
        'driverId': driverId,
        'driverName': driverName,
        'routeName': routeName,
        'subject': subject,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'route_update',
      });

      debugPrint('✅ Saved announcement: $subject');
    } catch (e) {
      debugPrint('❌ Error saving announcement: $e');
      throw Exception('Error al enviar aviso: ${e.toString()}');
    }
  }

  /// Get all announcements
  Stream<List<Map<String, dynamic>>> getAnnouncements() {
    return _database
        .child('announcements')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
          final List<Map<String, dynamic>> announcements = [];
          if (event.snapshot.exists) {
            final data = _convertMap(event.snapshot.value);
            data.forEach((key, value) {
              final map = _convertMap(value);
              map['id'] = key;
              announcements.add(map);
            });
            // Sort by timestamp (newest first)
            announcements.sort((a, b) {
              final tA =
                  DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
              final tB =
                  DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
              return tB.compareTo(tA);
            });
          }
          return announcements;
        });
  }

  /// Get bus for a specific driver (active or not)
  Future<BusModel?> getBusByDriverId(
    String driverId, {
    bool requireActive = true,
  }) async {
    try {
      final snapshot =
          await _database
              .child('buses')
              .orderByChild('driverId')
              .equalTo(driverId)
              .get();

      if (snapshot.exists) {
        final data = _convertMap(snapshot.value);
        BusModel? foundBus;

        // Find the bus entry
        data.forEach((busId, busData) {
          try {
            final bus = BusModel.fromJson(busId, _convertMap(busData));
            // If we require active, check it. If not, just take it (updating foundBus with latest)
            if (!requireActive || bus.isActive) {
              foundBus = bus;
            }
          } catch (e) {
            // ignore parsing errors for other buses
          }
        });

        return foundBus;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error finding bus for driver: $e');
      return null;
    }
  }
}
