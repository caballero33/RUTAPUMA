import 'package:latlong2/latlong.dart';

class BusModel {
  final String busId;
  final String driverId;
  final String routeName;
  final LatLng currentLocation;
  final DateTime timestamp;
  final bool isActive;
  final double speed; // km/h
  final double heading; // degrees (0-360)

  BusModel({
    required this.busId,
    required this.driverId,
    required this.routeName,
    required this.currentLocation,
    required this.timestamp,
    required this.isActive,
    this.speed = 0.0,
    this.heading = 0.0,
  });

  // Convert BusModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'driverId': driverId,
      'routeName': routeName,
      'location': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'timestamp': timestamp.toIso8601String(),
      'isActive': isActive,
      'speed': speed,
      'heading': heading,
    };
  }

  // Create BusModel from JSON
  factory BusModel.fromJson(String busId, Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return BusModel(
      busId: busId,
      driverId: json['driverId'] as String,
      routeName: json['routeName'] as String,
      currentLocation: LatLng(
        location['latitude'] as double,
        location['longitude'] as double,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isActive: json['isActive'] as bool,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Create a copy with modified fields
  BusModel copyWith({
    String? busId,
    String? driverId,
    String? routeName,
    LatLng? currentLocation,
    DateTime? timestamp,
    bool? isActive,
    double? speed,
    double? heading,
  }) {
    return BusModel(
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      routeName: routeName ?? this.routeName,
      currentLocation: currentLocation ?? this.currentLocation,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
    );
  }
}
