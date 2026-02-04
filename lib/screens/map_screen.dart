import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';
import '../models/bus_model.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/route_monitor_service.dart';
import '../services/favorite_routes_service.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'my_route_screen.dart';
import 'send_message_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class MapScreen extends StatefulWidget {
  final UserRole userRole;
  final String? driverId;

  const MapScreen({super.key, required this.userRole, this.driverId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Map Controller
  final MapController _mapController = MapController();

  // Firebase Database Service
  final DatabaseService _databaseService = DatabaseService();

  // Storage Service for session management
  final StorageService _storageService = StorageService();

  // Location Service for driver tracking
  final LocationService _locationService = LocationService();

  // Route Monitor Service for favorite routes notifications
  final RouteMonitorService _routeMonitor = RouteMonitorService();
  final FavoriteRoutesService _favoritesService = FavoriteRoutesService();

  // Initial Position: UNAH Campus Cortés (UNAH-VS)
  static const LatLng _unahVsLocation = LatLng(15.52974, -88.03742);

  // State for user location
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;

  // State for buses from Firebase
  List<BusModel> _activeBuses = [];
  StreamSubscription<List<BusModel>>? _busesStream;

  // Pause state for drivers
  bool _isRoutePaused = false;

  // Markers
  List<Marker> get _allMarkers {
    final markers = <Marker>[
      // University Marker (Home)
      Marker(
        point: _unahVsLocation,
        width: 80,
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: AppColors.primaryBlue,
            size: 25,
          ),
        ),
      ),
    ];

    // Add markers for all active buses from Firebase (for users)
    if (widget.userRole == UserRole.user) {
      // Use default zoom if map controller is not ready
      double zoom = 16.0;
      try {
        zoom = _mapController.camera.zoom;
      } catch (_) {
        // Map controller not ready yet, use default
      }
      final scale = (zoom / 16.0).clamp(0.6, 1.2);

      for (final bus in _activeBuses) {
        // Filter by selected route if not "Todas las rutas"
        if (_selectedRoute != 'Todas las rutas' &&
            !bus.routeName.contains(_selectedRoute.replaceAll('Ruta ', ''))) {
          continue;
        }

        // Extract route number from busId (BUSXXYY -> XX)
        String routeNumber = '?';
        try {
          final routePart = bus.busId.substring(3, 5);
          routeNumber = int.parse(routePart).toString();
        } catch (_) {}

        final markerSize = 75.0 * scale;

        markers.add(
          Marker(
            point: bus.currentLocation,
            width: markerSize,
            height: markerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(4 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryYellow,
                      width: 2.5 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10 * scale,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        'assets/images/rutapuma_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Route Number Overlay
                Positioned(
                  top: 12 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.5 * scale,
                      ),
                    ),
                    child: Text(
                      routeNumber,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Add User Location Marker (for users) or Driver marker (for drivers)
    if (_userLocation != null) {
      final isDriverActive =
          widget.userRole == UserRole.driver && _isRouteActive;

      // Extract route number if driver
      String? routeNumber;
      if (isDriverActive && widget.driverId != null) {
        try {
          // Assuming format BUSXXYY, take XX
          final routePart = widget.driverId!.substring(3, 5);
          routeNumber = int.parse(routePart).toString();
        } catch (_) {
          routeNumber = '?';
        }
      }

      // Dynamic sizing based on zoom
      double zoom = 16.0;
      try {
        zoom = _mapController.camera.zoom;
      } catch (_) {
        // Map controller not ready yet, use default
      }
      final baseSize = isDriverActive ? 75.0 : 60.0;
      final scale = (zoom / 16.0).clamp(0.6, 1.2);
      final markerSize = baseSize * scale;

      markers.add(
        Marker(
          point: _userLocation!,
          width: markerSize,
          height: markerSize,
          child:
              isDriverActive
                  ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 2.5 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10 * scale,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              'assets/images/rutapuma_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // Route Number Overlay
                      Positioned(
                        top: 12 * scale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * scale,
                            vertical: 2 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10 * scale),
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5 * scale,
                            ),
                          ),
                          child: Text(
                            routeNumber ?? '',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Container(
                    decoration: BoxDecoration(
                      color: AppColors.softBlue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 18 * scale,
                        height: 18 * scale,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4 * scale,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      );
    }
    return markers;
  }

  bool _isMenuOpen = false;
  bool _isSatelliteMode = false;
  bool _isRouteActive = false;
  bool _hasCenteredOnUser = false;
  String _selectedRoute = 'Todas las rutas';
  final List<String> _routes = [
    'Todas las rutas',
    'Ruta 1',
    'Ruta 2',
    'Ruta 3',
    'Ruta 4',
    'Ruta 5',
    'Ruta 6',
    'Ruta 7',
    'Ruta 8',
    'Ruta 9',
    'Ruta 10',
    'Ruta 11',
    'Ruta 12',
    'Ruta 13',
    'Ruta 14',
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    // Start monitoring favorite routes for students AND drivers (so they get notifs)
    if (widget.userRole == UserRole.user ||
        widget.userRole == UserRole.driver) {
      _startFavoriteRoutesMonitoring();
    }

    // Auto-favorite route for drivers
    if (widget.userRole == UserRole.driver) {
      _checkAutoFavoriteRoute();
    }

    // Listen to active buses from Firebase (for users only)
    if (widget.userRole == UserRole.user) {
      debugPrint(
        '👨‍🎓 Usuario estudiante - Escuchando buses desde Firebase...',
      );
      _busesStream = _databaseService.getActiveBuses().listen((buses) {
        debugPrint('📡 Buses recibidos desde Firebase: ${buses.length}');
        for (var bus in buses) {
          debugPrint(
            '   🚌 ${bus.busId} - ${bus.routeName} - Activo: ${bus.isActive}',
          );
          debugPrint(
            '      📍 Lat: ${bus.currentLocation.latitude}, Lng: ${bus.currentLocation.longitude}',
          );
        }
        if (mounted) {
          setState(() {
            _activeBuses = buses;
          });
          debugPrint('✅ Estado actualizado con ${_activeBuses.length} buses');
        }
      });
    }
  }

  // Auto-subscribe drivers to their own route
  Future<void> _checkAutoFavoriteRoute() async {
    try {
      // 1. Get driver ID (e.g. BUS0701)
      final dId = widget.driverId;
      if (dId == null) return;

      // 2. Parse Route (e.g. Ruta 7)
      String? routeName;
      if (dId.startsWith('BUS') && dId.length >= 5) {
        final routeNum = dId.substring(3, 5);
        routeName =
            'Ruta ${int.parse(routeNum)}'; // Auto-remove leading zero via int parse
      }

      if (routeName != null) {
        // 3. Check if already favorite
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;

        // Need to know WHO is the user to save to firebase
        // If we are a local driver, our UID is the driverId
        final uid = user?.uid ?? dId;

        final favs = await _favoritesService.getFavoriteRoutes();
        if (!favs.contains(routeName)) {
          debugPrint('🤖 Auto-favoriting $routeName for Driver $dId');
          // Use service so it handles OneSignal tags!
          await _favoritesService.addFavoriteRoute(routeName);

          // 4. Force monitoring restart to pick up the new tag
          await _routeMonitor.startMonitoring();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🔔 Te hemos suscrito a avisos de $routeName'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error auto-favoriting driver route: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      _startLocationTracking();
    }
  }

  // Start monitoring favorite routes for notifications
  Future<void> _startFavoriteRoutesMonitoring() async {
    try {
      final favorites = await _favoritesService.getFavoriteRoutes();
      if (favorites.isNotEmpty) {
        await _routeMonitor.startMonitoring();
        debugPrint('✅ Monitoring ${favorites.length} favorite routes');
      } else {
        debugPrint('ℹ️ No favorite routes to monitor');
      }
    } catch (e) {
      debugPrint('❌ Error starting route monitoring: $e');
    }
  }

  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      if (mounted) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = newLocation;
        });

        // Auto-center on user for the first time
        if (!_hasCenteredOnUser) {
          _mapController.move(newLocation, 17.0);
          _hasCenteredOnUser = true;
        }

        // Update Firebase if driver is active and NOT paused
        if (widget.userRole == UserRole.driver &&
            _isRouteActive &&
            !_isRoutePaused &&
            widget.driverId != null) {
          try {
            // Extract route number from busId (BUSXXYY -> XX)
            String routeName = 'Ruta ';
            try {
              final routePart = widget.driverId!.substring(3, 5);
              routeName += int.parse(routePart).toString();
            } catch (_) {
              routeName += '?';
            }

            debugPrint('🚌 Actualizando ubicación de bus: ${widget.driverId}');
            debugPrint(
              '📍 Ubicación: ${newLocation.latitude}, ${newLocation.longitude}',
            );
            debugPrint('🛣️ Ruta: $routeName');

            await _databaseService.updateBusLocation(
              busId: widget.driverId!,
              driverId: widget.driverId!,
              routeName: routeName,
              location: newLocation,
              speed: position.speed * 3.6, // m/s to km/h
              heading: position.heading,
            );

            debugPrint('✅ Ubicación actualizada en Firebase');
          } catch (e) {
            debugPrint('❌ Error updating bus location: $e');
          }
        } else {
          // Debug why it's not updating
          if (widget.userRole == UserRole.driver) {
            debugPrint('⚠️ No se actualiza Firebase:');
            debugPrint(
              '   - Es conductor: ${widget.userRole == UserRole.driver}',
            );
            debugPrint('   - Ruta activa: $_isRouteActive');
            debugPrint('   - Ruta pausada: $_isRoutePaused');
            debugPrint('   - Tiene ID: ${widget.driverId != null}');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _busesStream?.cancel();

    // Set bus as inactive when driver closes the app
    if (widget.userRole == UserRole.driver &&
        _isRouteActive &&
        widget.driverId != null) {
      _databaseService.setBusInactive(widget.driverId!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consume theme to rebuild on toggle
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Map
          _buildMap(themeProvider.isDarkMode),
          // Top Bar
          _buildTopBar(themeProvider),
          // Route Selector (for users)
          if (widget.userRole == UserRole.user) _buildRouteSelector(),
          // Driver Controls (for drivers)
          if (widget.userRole == UserRole.driver) _buildDriverControls(),
          // Side Menu
          _buildSideMenu(),
        ],
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildMap(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _unahVsLocation,
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onPositionChanged: (position, hasGesture) {
          // Rebuild to update marker scale based on zoom
          if (mounted) setState(() {});
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              _isSatelliteMode
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : (isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          userAgentPackageName: 'com.unah.rutapuma.rutapuma',
          tileDisplay: const TileDisplay.fadeIn(),
          retinaMode: true,
        ),
        MarkerLayer(markers: _allMarkers),
      ],
    );
  }

  Widget _buildTopBar(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          border:
              isDark
                  ? const Border(
                    bottom: BorderSide(color: AppColors.darkBorder, width: 1.5),
                  )
                  : null,
          boxShadow:
              isDark
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.shadowColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  _isMenuOpen = true;
                });
              },
            ),
            Column(
              children: [
                const Text(
                  'RUTAPUMA',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                if (widget.userRole != UserRole.user)
                  Text(
                    widget.userRole.displayName,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: AppColors.white,
                size: 30,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.white,
            width: 4,
          ),
          boxShadow:
              isDark
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.shadowColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRoute,
            isExpanded: true,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkAccent : AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
                size: 24,
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.darkBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            items:
                _routes.map((String route) {
                  return DropdownMenuItem<String>(
                    value: route,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_bus_rounded,
                            color:
                                isDark
                                    ? AppColors.primaryYellow
                                    : AppColors.primaryBlue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(route),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRoute = newValue!;
              });
            },
            dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverControls() {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border:
              isDark
                  ? Border.all(color: AppColors.darkBorder, width: 1.5)
                  : null,
          boxShadow:
              isDark
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.shadowColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
        ),
        child: Column(
          children: [
            Text(
              _isRouteActive ? 'Ruta en Curso 🚌' : '¿Listo para iniciar?',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.darkBlue,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDriverButton(
                  icon: Icons.play_arrow_rounded,
                  label: _isRoutePaused ? 'Reanudar' : 'Iniciar',
                  color:
                      (_isRouteActive && !_isRoutePaused)
                          ? AppColors.grey
                          : AppColors.green,
                  onTap:
                      (_isRouteActive && !_isRoutePaused)
                          ? null
                          : () async {
                            if (_isRoutePaused) {
                              // RESUME logic
                              debugPrint('🟢 Botón REANUDAR presionado');

                              setState(() => _isRoutePaused = false);

                              // Update Firebase to set bus as active
                              if (widget.driverId != null &&
                                  _userLocation != null) {
                                try {
                                  String routeName = 'Ruta ';
                                  try {
                                    final routePart = widget.driverId!
                                        .substring(3, 5);
                                    routeName +=
                                        int.parse(routePart).toString();
                                  } catch (_) {
                                    routeName += '?';
                                  }

                                  await _databaseService.updateBusLocation(
                                    busId: widget.driverId!,
                                    driverId: widget.driverId!,
                                    routeName: routeName,
                                    location: _userLocation!,
                                    speed: 0,
                                    heading: 0,
                                  );
                                  debugPrint('✅ Bus reactivado en Firebase');
                                } catch (e) {
                                  debugPrint('❌ Error reactivando bus: $e');
                                }
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🟢 Ruta Reanudada'),
                                    backgroundColor: AppColors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else {
                              // START logic
                              debugPrint('🟢 Botón INICIAR presionado');

                              // Start location service for driver
                              if (widget.driverId != null) {
                                try {
                                  // Extract route name from driver ID
                                  String routeName = 'Ruta ';
                                  try {
                                    final routePart = widget.driverId!
                                        .substring(3, 5);
                                    routeName +=
                                        int.parse(routePart).toString();
                                  } catch (_) {
                                    routeName += '?';
                                  }

                                  await _locationService.startTracking(
                                    driverId: widget.driverId!,
                                    routeName: routeName,
                                  );
                                  debugPrint('✅ Location service started');
                                } catch (e) {
                                  debugPrint(
                                    '❌ Error starting location service: $e',
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al iniciar rastreo: $e',
                                        ),
                                        backgroundColor: AppColors.red,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }

                              setState(() => _isRouteActive = true);
                              debugPrint(
                                '✅ Estado cambiado: _isRouteActive = $_isRouteActive',
                              );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ruta Iniciada. ¡Buen viaje!',
                                    ),
                                    backgroundColor: AppColors.green,
                                  ),
                                );
                              }
                            }
                          },
                ),
                _buildDriverButton(
                  icon: Icons.pause_rounded,
                  label: 'Pausar',
                  color:
                      (!_isRouteActive || _isRoutePaused)
                          ? AppColors.grey
                          : AppColors.primaryYellow,
                  onTap:
                      (!_isRouteActive || _isRoutePaused)
                          ? null
                          : () async {
                            debugPrint('🟡 Botón PAUSAR presionado');

                            setState(() => _isRoutePaused = true);

                            // Set bus as inactive in Firebase (temporarily)
                            if (widget.driverId != null) {
                              try {
                                await _databaseService.setBusInactive(
                                  widget.driverId!,
                                );
                                debugPrint(
                                  '✅ Bus marcado como inactivo en Firebase',
                                );
                              } catch (e) {
                                debugPrint('❌ Error pausando bus: $e');
                              }
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⏸️ Ruta Pausada'),
                                  backgroundColor: AppColors.primaryYellow,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                ),
                _buildDriverButton(
                  icon: Icons.stop_rounded,
                  label: 'Fin',
                  color: !_isRouteActive ? AppColors.grey : AppColors.red,
                  onTap:
                      !_isRouteActive
                          ? null
                          : () async {
                            // Stop location service
                            try {
                              await _locationService.stopTracking();
                              debugPrint('✅ Location service stopped');
                            } catch (e) {
                              debugPrint(
                                '❌ Error stopping location service: $e',
                              );
                            }

                            setState(() => _isRouteActive = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ruta Finalizada'),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isDark ? AppColors.darkAccent : AppColors.white,
                width: 3,
              ),
            ),
            child: Icon(icon, color: AppColors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color:
                  color == AppColors.grey
                      ? AppColors.grey
                      : (isDark ? AppColors.grey : AppColors.darkGrey),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      left: _isMenuOpen ? 0 : -300,
      top: 0,
      bottom: 0,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(40),
          ),
          border:
              isDark
                  ? const Border(
                    right: BorderSide(color: AppColors.darkBorder, width: 1.5),
                  )
                  : null,
          boxShadow:
              isDark
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.shadowColor.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(5, 0),
                    ),
                  ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 16),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.white : AppColors.darkGrey,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Profile Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.userRole == UserRole.user
                            ? Icons.person_rounded
                            : Icons.directions_bus_rounded,
                        size: 30,
                        color:
                            isDark
                                ? AppColors.primaryYellow
                                : AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usuario',
                            style: TextStyle(
                              color:
                                  isDark ? AppColors.white : AppColors.darkBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.userRole.displayName,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.home_rounded, 'Inicio'),
                      _buildMenuItem(Icons.star_rounded, 'Ruta Favorita'),
                      _buildMenuItem(Icons.notifications_rounded, 'Avisos'),
                      _buildMenuItem(Icons.settings_rounded, 'Configuración'),
                      if (widget.userRole == UserRole.driver)
                        _buildMenuItem(Icons.send_rounded, 'Enviar Mensaje'),
                      _buildMenuItem(Icons.help_outline_rounded, 'Ayuda'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton.icon(
                  onPressed: () async {
                    // Stop location tracking if driver
                    if (widget.userRole == UserRole.driver) {
                      try {
                        await _locationService.stopTracking();
                      } catch (e) {
                        debugPrint('Error stopping location service: $e');
                      }
                    }

                    // Clear session storage
                    await _storageService.clearSession();

                    // Navigate to login screen
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.red),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    backgroundColor: AppColors.red.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccent : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.white : AppColors.darkBlue,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: () {
        setState(() {
          _isMenuOpen = false;
        });

        // Handle specific menu actions
        if (title == 'Avisos') {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          });
        }

        if (title == 'Ruta Favorita') {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRouteScreen()),
            );
          });
        }

        if (title == 'Enviar Mensaje') {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendMessageScreen(),
              ),
            );
          });
        }

        if (title == 'Configuración') {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(userRole: widget.userRole),
              ),
            );
          });
        }

        if (title == 'Ayuda') {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          });
        }
      },
    );
  }

  Widget _buildFloatingButtons() {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'layers',
          onPressed: () {
            setState(() {
              _isSatelliteMode = !_isSatelliteMode;
            });
          },
          backgroundColor:
              _isSatelliteMode
                  ? AppColors.primaryBlue
                  : AppColors.primaryYellow,
          elevation: isDark ? 0 : 6,
          shape:
              isDark
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.darkBorder,
                      width: 1.5,
                    ),
                  )
                  : null,
          child: Icon(
            _isSatelliteMode ? Icons.map_rounded : Icons.layers_outlined,
            color: _isSatelliteMode ? Colors.white : AppColors.darkBlue,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'gps',
          onPressed: () {
            if (_userLocation != null) {
              _mapController.move(_userLocation!, 17.0);
            } else {
              // Fallback to University if location unknown
              _mapController.move(_unahVsLocation, 16.0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Obteniendo tu ubicación...'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          backgroundColor: AppColors.primaryYellow,
          elevation: isDark ? 0 : 6,
          shape:
              isDark
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.darkBorder,
                      width: 1.5,
                    ),
                  )
                  : null,
          child: Icon(
            Icons.my_location_rounded,
            color: AppColors.darkBlue,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'refresh',
          onPressed: () {},
          backgroundColor: AppColors.primaryYellow,
          elevation: isDark ? 0 : 6,
          shape:
              isDark
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.darkBorder,
                      width: 1.5,
                    ),
                  )
                  : null,
          child: Icon(
            Icons.refresh_rounded,
            color: AppColors.darkBlue,
            size: 30,
          ),
        ),
      ],
    );
  }
}
