import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'my_route_screen.dart';
import 'send_message_screen.dart';
import 'help_screen.dart';

class MapScreen extends StatefulWidget {
  final UserRole userRole;

  const MapScreen({super.key, required this.userRole});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isMenuOpen = false;
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
  Widget build(BuildContext context) {
    // Consume theme to rebuild on toggle
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Map Placeholder
          _buildMapPlaceholder(themeProvider.isDarkMode),
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

  Widget _buildMapPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/rutapuma_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mapa de RutaPuma',
              style: TextStyle(
                fontSize: 22,
                color: isDark ? AppColors.white : AppColors.darkGrey,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            color: AppColors.shadowColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
              ),
              child: Text(
                'Google Maps se integrará aquí',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
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
                      color: AppColors.shadowColor.withOpacity(0.3),
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
                      color: AppColors.white.withOpacity(0.9),
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
                      color: AppColors.shadowColor.withOpacity(0.3),
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
                                    : AppColors.primaryBlue.withOpacity(0.1),
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
                      color: AppColors.shadowColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
        ),
        child: Column(
          children: [
            Text(
              'Estás en Ruta',
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
                  label: 'Iniciar',
                  color: AppColors.green,
                ),
                _buildDriverButton(
                  icon: Icons.pause_rounded,
                  label: 'Pausar',
                  color: AppColors.primaryYellow,
                ),
                _buildDriverButton(
                  icon: Icons.stop_rounded,
                  label: 'Fin',
                  color: AppColors.red,
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
  }) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
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
            color: isDark ? AppColors.grey : AppColors.darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
                      color: AppColors.shadowColor.withOpacity(0.5),
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
                          : AppColors.primaryBlue.withOpacity(0.1),
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
                      _buildMenuItem(Icons.map_rounded, 'Mis Rutas'),
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
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
                    backgroundColor: AppColors.red.withOpacity(0.1),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRouteScreen()),
            );
          });
        }

        if (title == 'Enviar Mensaje') {
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendMessageScreen(),
              ),
            );
          });
        }

        if (title == 'Ayuda') {
          Future.delayed(const Duration(milliseconds: 300), () {
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
          heroTag: 'gps',
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
