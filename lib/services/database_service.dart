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

            // Only include active buses updated in the last 5 minutes
            final timeDiff = DateTime.now().difference(bus.timestamp);
            debugPrint(
              '   🚌 $busId - Activo: ${bus.isActive}, Tiempo: ${timeDiff.inMinutes} min',
            );

            if (bus.isActive && timeDiff.inMinutes < 5) {
              buses.add(bus);
              debugPrint('      ✅ Bus agregado a la lista');
            } else {
              debugPrint('      ❌ Bus filtrado (inactivo o muy antiguo)');
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
}
