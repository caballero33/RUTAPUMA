import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'database_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  String? _currentDriverId;
  String? _currentRouteName;

  bool get isTracking => _isTracking;

  // Start location tracking for driver
  Future<void> startTracking({
    required String driverId,
    required String routeName,
  }) async {
    if (_isTracking) {
      debugPrint('⚠️ Location tracking already active');
      return;
    }

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permisos de ubicación denegados permanentemente. '
          'Por favor habilítalos en configuración.',
        );
      }

      _currentDriverId = driverId;
      _currentRouteName = routeName;
      _isTracking = true;

      debugPrint('🚀 Starting location tracking for driver: $driverId');

      // Configure location settings for background tracking
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 5), // Update at least every 5 seconds
      );

      // Start listening to position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _updateLocation(position);
        },
        onError: (error) {
          debugPrint('❌ Location stream error: $error');
        },
      );

      debugPrint('✅ Location tracking started successfully');
    } catch (e) {
      _isTracking = false;
      debugPrint('❌ Error starting location tracking: $e');
      rethrow;
    }
  }

  // Update location in Firebase
  Future<void> _updateLocation(Position position) async {
    if (!_isTracking || _currentDriverId == null || _currentRouteName == null) {
      return;
    }

    try {
      final location = LatLng(position.latitude, position.longitude);
      final speed = position.speed; // meters per second
      final heading = position.heading; // degrees

      await _databaseService.updateBusLocation(
        busId: _currentDriverId!,
        driverId: _currentDriverId!,
        routeName: _currentRouteName!,
        location: location,
        speed: speed,
        heading: heading,
      );

      debugPrint(
        '📍 Location updated: ${position.latitude}, ${position.longitude} | '
        'Speed: ${speed.toStringAsFixed(1)} m/s | '
        'Heading: ${heading.toStringAsFixed(0)}°',
      );
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
    }
  }

  // Stop location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      debugPrint('⚠️ Location tracking not active');
      return;
    }

    try {
      debugPrint('🛑 Stopping location tracking for driver: $_currentDriverId');

      // Cancel position stream subscription
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // Mark bus as inactive in Firebase
      if (_currentDriverId != null) {
        await _databaseService.setBusInactive(_currentDriverId!);
      }

      _isTracking = false;
      _currentDriverId = null;
      _currentRouteName = null;

      debugPrint('✅ Location tracking stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping location tracking: $e');
      rethrow;
    }
  }

  // Get current tracking status
  Map<String, dynamic> getTrackingStatus() {
    return {
      'isTracking': _isTracking,
      'driverId': _currentDriverId,
      'routeName': _currentRouteName,
    };
  }

  // Dispose resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
  }
}
