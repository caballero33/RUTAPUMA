import 'package:firebase_database/firebase_database.dart';
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

  // Listen to all active buses (for users)
  Stream<List<BusModel>> getActiveBuses() {
    return _database.child('buses').onValue.map((event) {
      final List<BusModel> buses = [];

      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        data.forEach((busId, busData) {
          final bus = BusModel.fromJson(
            busId,
            Map<String, dynamic>.from(busData as Map),
          );

          // Only include active buses updated in the last 5 minutes
          final timeDiff = DateTime.now().difference(bus.timestamp);
          if (bus.isActive && timeDiff.inMinutes < 5) {
            buses.add(bus);
          }
        });
      }

      return buses;
    });
  }

  // Listen to a specific bus
  Stream<BusModel?> getBusById(String busId) {
    return _database.child('buses').child(busId).onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
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
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);

            data.forEach((busId, busData) {
              final bus = BusModel.fromJson(
                busId,
                Map<String, dynamic>.from(busData as Map),
              );

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
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        data.forEach((routeId, routeData) {
          routes.add({
            'routeId': routeId,
            ...Map<String, dynamic>.from(routeData as Map),
          });
        });
      }

      return routes;
    } catch (e) {
      throw Exception('Error al obtener rutas: ${e.toString()}');
    }
  }
}
