import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// import '../models/user_role.dart'; // Unused import

class MyRouteScreen extends StatefulWidget {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  // Mock data for routes
  final List<String> _allRoutes = List.generate(
    14,
    (index) => 'Ruta ${index + 1}',
  );

  // Set to store selected routes
  final Set<String> _selectedRoutes = {};
  bool _isLoading = true;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedRoutes();
  }

  Future<void> _loadSelectedRoutes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. Ensure we have a user - Recovery logic
    if (authProvider.currentUser == null) {
      debugPrint('⚠️ [MyRouteScreen] User is null, attempting checkSession...');
      await authProvider.checkSession();
    }

    final user = authProvider.currentUser;
    debugPrint('🔍 [MyRouteScreen] User: ${user?.uid}, Role: ${user?.role}');

    // 2. Check if user is driver (Robust check)
    // Accept 'DRIVER' or 'driver' or any case
    if (user != null && user.role.toUpperCase() == 'DRIVER') {
      debugPrint('✅ [MyRouteScreen] Driver detected!');
      _isDriver = true;
      // Clean assigned route name from user profile or ID
      String? assignedRoute = user.assignedRoute;

      // Fallback parsing (same logic as other screens)
      if (assignedRoute == null && user.uid.startsWith('BUS')) {
        try {
          if (user.uid.length >= 5) {
            final routeNum = int.parse(user.uid.substring(3, 5));
            assignedRoute = 'Ruta $routeNum';
          }
        } catch (_) {}
      }

      if (assignedRoute != null) {
        debugPrint('🔒 [MyRouteScreen] Locking route to: $assignedRoute');
        if (mounted) {
          setState(() {
            _selectedRoutes.clear();
            _selectedRoutes.add(assignedRoute!);
            _isLoading = false;
            _isDriver = true; // Ensure state is updated visually
          });
        }
        // Also force save to persist for other screens
        _saveSelectedRoutes();
        return;
      }
    } else {
      debugPrint('👤 [MyRouteScreen] Normal user or unknown role');
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedRoutes = prefs.getStringList('favorite_routes');
    if (savedRoutes != null) {
      setState(() {
        _selectedRoutes.addAll(savedRoutes);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_routes', _selectedRoutes.toList());
  }

  void _toggleRoute(String route) {
    // Prevent drivers from changing selection
    if (_isDriver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Tu ruta está asignada automáticamente.'),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedRoutes.contains(route)) {
        _selectedRoutes.remove(route);
      } else {
        _selectedRoutes.add(route);
      }
      _saveSelectedRoutes();
    });
  }

  void _toggleAll(bool? value) {
    if (_isDriver) return; // Disable for drivers

    setState(() {
      if (value == true) {
        _selectedRoutes.addAll(_allRoutes);
      } else {
        _selectedRoutes.clear();
      }
      _saveSelectedRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final areAllSelected = _selectedRoutes.length == _allRoutes.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.white : AppColors.darkBlue,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ruta Favorita',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color:
                      isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
                ),
              )
              : Column(
                children: [
                  // Info Banner
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          _isDriver
                              ? (isDark
                                  ? AppColors.darkAccent
                                  : Colors.orange.withValues(alpha: 0.1))
                              : (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primaryBlue.withValues(
                                    alpha: 0.1,
                                  )),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isDriver
                                ? Colors.orange
                                : (isDark
                                    ? AppColors.primaryYellow
                                    : AppColors.primaryBlue),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isDriver
                              ? Icons.lock_clock_rounded
                              : Icons.info_outline_rounded,
                          color:
                              _isDriver
                                  ? Colors.orange
                                  : (isDark
                                      ? AppColors.primaryYellow
                                      : AppColors.primaryBlue),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isDriver
                                ? 'Tu ruta está fijada por tu unidad asignada.'
                                : 'La ruta que elijas recibirá notificaciones acerca de ella en avisos.',
                            style: TextStyle(
                              color:
                                  isDark ? AppColors.white : AppColors.darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Select All Checkbox - HIDDEN FOR DRIVERS
                  if (!_isDriver)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: areAllSelected,
                              onChanged: _toggleAll,
                              fillColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return isDark
                                      ? AppColors.primaryYellow
                                      : AppColors.primaryBlue;
                                }
                                return null;
                              }),
                              side: BorderSide(
                                color:
                                    isDark
                                        ? AppColors.white.withValues(alpha: 0.5)
                                        : AppColors.grey,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Seleccionar todas',
                            style: TextStyle(
                              color:
                                  isDark ? AppColors.white : AppColors.darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Divider(height: 1),

                  // Route List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: _allRoutes.length,
                      itemBuilder: (context, index) {
                        final route = _allRoutes[index];
                        final isSelected = _selectedRoutes.contains(route);

                        // Interaction logic for List Tile
                        final isInteractive = !_isDriver;

                        return Opacity(
                          // Dim unselected items for drivers
                          opacity: (_isDriver && !isSelected) ? 0.5 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppColors.darkSurface
                                      : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isDark
                                      ? Border.all(color: AppColors.darkBorder)
                                      : null,
                              boxShadow:
                                  isDark
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: AppColors.shadowColor
                                              .withValues(alpha: 0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? AppColors.darkAccent
                                          : AppColors.lightGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.directions_bus_rounded,
                                  color:
                                      isDark
                                          ? AppColors.primaryYellow
                                          : AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                route,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.darkGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isSelected
                                      ? Icons.favorite_rounded
                                      : (_isDriver
                                          ? Icons.lock_outline
                                          : Icons.favorite_border_rounded),
                                  color:
                                      isSelected
                                          ? (isDark
                                              ? AppColors.primaryYellow
                                              : AppColors.red)
                                          : (isDark
                                              ? AppColors.white.withValues(
                                                alpha: 0.5,
                                              )
                                              : AppColors.grey),
                                  size: 28,
                                ),
                                onPressed:
                                    isInteractive
                                        ? () => _toggleRoute(route)
                                        : null,
                              ),
                              onTap:
                                  isInteractive
                                      ? () => _toggleRoute(route)
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
