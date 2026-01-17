import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';

class MapScreen extends StatefulWidget {
  final UserRole userRole;

  const MapScreen({Key? key, required this.userRole}) : super(key: key);

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          _buildMapPlaceholder(),
          // Top Bar
          _buildTopBar(),
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

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, AppColors.lightGrey.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: AppColors.primaryBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Mapa de UNAH Campus Cortés',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.darkGrey.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Google Maps se integrará aquí',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 15,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.white),
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                });
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RUTAPUMA',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.userRole.displayName,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.userRole == UserRole.user
                    ? Icons.person
                    : Icons.drive_eta,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRoute,
            isExpanded: true,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primaryBlue,
            ),
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            items:
                _routes.map((String route) {
                  return DropdownMenuItem<String>(
                    value: route,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.route,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
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
          ),
        ),
      ),
    );
  }

  Widget _buildDriverControls() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Compartir Ubicación',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDriverButton(
                  icon: Icons.play_arrow,
                  label: 'Iniciar',
                  color: AppColors.primaryYellow,
                ),
                _buildDriverButton(
                  icon: Icons.pause,
                  label: 'Pausar',
                  color: AppColors.white,
                ),
                _buildDriverButton(
                  icon: Icons.stop,
                  label: 'Detener',
                  color: Colors.red,
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color:
                color == AppColors.white
                    ? AppColors.primaryBlue
                    : AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSideMenu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isMenuOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.3), blurRadius: 20),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.yellowGradient,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.userRole == UserRole.user
                              ? Icons.person
                              : Icons.drive_eta,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Usuario UNAH',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.userRole.displayName,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.white, thickness: 0.5),
              // Menu Items
              _buildMenuItem(Icons.home, 'Inicio'),
              _buildMenuItem(Icons.route, 'Mis Rutas'),
              _buildMenuItem(Icons.history, 'Historial'),
              _buildMenuItem(Icons.notifications, 'Notificaciones'),
              _buildMenuItem(Icons.settings, 'Configuración'),
              _buildMenuItem(Icons.help_outline, 'Ayuda'),
              const Spacer(),
              _buildMenuItem(Icons.logout, 'Cerrar Sesión'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        if (title == 'Cerrar Sesión') {
          Navigator.pop(context);
        }
        setState(() {
          _isMenuOpen = false;
        });
      },
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'location',
          onPressed: () {
            // TODO: Center map on user location
          },
          backgroundColor: AppColors.white,
          child: const Icon(Icons.my_location, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'refresh',
          onPressed: () {
            // TODO: Refresh bus locations
          },
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.refresh, color: AppColors.white),
        ),
      ],
    );
  }
}
