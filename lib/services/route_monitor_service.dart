import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/bus_model.dart';
import 'database_service.dart';
import 'favorite_routes_service.dart';

/// Service to monitor favorite routes and send notifications when they become active
/// Works when app is open or in background
class RouteMonitorService {
  static final RouteMonitorService _instance = RouteMonitorService._internal();
  factory RouteMonitorService() => _instance;
  RouteMonitorService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final FavoriteRoutesService _favoritesService = FavoriteRoutesService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<List<BusModel>>? _busesSubscription;
  final Set<String> _notifiedRoutes =
      {}; // Track which routes we've notified about
  bool _isMonitoring = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    debugPrint('✅ Route monitor notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to the specific route when notification is tapped
  }

  /// Start monitoring favorite routes for the current user
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      debugPrint('⚠️ Route monitoring already active');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('⚠️ No user logged in, cannot start monitoring');
      return;
    }

    debugPrint('🔍 Starting route monitoring for user: ${user.uid}');
    _isMonitoring = true;
    _notifiedRoutes.clear();

    // Initialize favorites service
    await _favoritesService.initialize();

    // Listen to all active buses
    _busesSubscription = _databaseService.getActiveBuses().listen((
      buses,
    ) async {
      await _checkFavoriteRoutes(buses);
    });
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    debugPrint('🛑 Stopping route monitoring');
    _isMonitoring = false;
    await _busesSubscription?.cancel();
    _busesSubscription = null;
    _notifiedRoutes.clear();
  }

  /// Check if any favorite routes are active
  Future<void> _checkFavoriteRoutes(List<BusModel> activeBuses) async {
    final favoriteRoutes = await _favoritesService.getFavoriteRoutes();

    if (favoriteRoutes.isEmpty) {
      return;
    }

    for (final bus in activeBuses) {
      // Check if this bus's route is in favorites
      if (favoriteRoutes.contains(bus.routeName)) {
        // Only notify once per route per session
        if (!_notifiedRoutes.contains(bus.routeName)) {
          await _sendNotification(bus);
          _notifiedRoutes.add(bus.routeName);
        }
      }
    }

    // Remove routes from notified set if they're no longer active
    final activeRouteNames = activeBuses.map((b) => b.routeName).toSet();
    _notifiedRoutes.removeWhere((route) => !activeRouteNames.contains(route));
  }

  /// Send notification for active favorite route
  Future<void> _sendNotification(BusModel bus) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'favorite_routes_channel',
        'Rutas Favoritas',
        channelDescription: 'Notificaciones de rutas favoritas activas',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF003DA5), // UNAH Blue
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        bus.routeName.hashCode, // Unique ID per route
        '🚌 ${bus.routeName} en Movimiento',
        'Tu ruta favorita acaba de comenzar su recorrido',
        notificationDetails,
        payload: bus.routeName,
      );

      debugPrint('📬 Notification sent for ${bus.routeName}');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  /// Get monitoring status
  bool get isMonitoring => _isMonitoring;

  /// Get notified routes
  Set<String> get notifiedRoutes => Set.from(_notifiedRoutes);
}
