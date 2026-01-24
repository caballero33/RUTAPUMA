import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final UserRole userRole;

  const SettingsScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.white : AppColors.darkBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow:
                    isDark
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Column(
                children: [
                  // Profile Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.darkAccent
                              : AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      userRole == UserRole.user
                          ? Icons.person_rounded
                          : Icons.directions_bus_rounded,
                      size: 50,
                      color:
                          isDark
                              ? AppColors.primaryYellow
                              : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User Role
                  Text(
                    userRole.displayName,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.darkBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User Email
                  if (user?.email != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkAccent : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 18,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              user!.email!,
                              style: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.darkGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // App Settings Section
            Text(
              'Apariencia',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),

            // Dark Mode Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow:
                    isDark
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkAccent : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
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
                          'Modo Oscuro',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.white : AppColors.darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isDark ? 'Activado' : 'Desactivado',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppColors.primaryYellow,
                    activeTrackColor: AppColors.primaryYellow.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Account Info Section
            Text(
              'Información de la Cuenta',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),

            // User ID
            if (user?.uid != null)
              _buildInfoTile(
                icon: Icons.fingerprint_rounded,
                title: 'ID de Usuario',
                subtitle: user!.uid.substring(0, 12) + '...',
                isDark: isDark,
              ),

            const SizedBox(height: 12),

            // Account Created
            if (user?.metadata.creationTime != null)
              _buildInfoTile(
                icon: Icons.calendar_today_rounded,
                title: 'Cuenta Creada',
                subtitle: _formatDate(user!.metadata.creationTime!),
                isDark: isDark,
              ),

            const SizedBox(height: 30),

            // App Info Section
            Text(
              'Sobre la App',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),

            _buildInfoTile(
              icon: Icons.info_outline_rounded,
              title: 'Versión',
              subtitle: '1.0.0',
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            _buildInfoTile(
              icon: Icons.school_rounded,
              title: 'Universidad',
              subtitle: 'UNAH - Universidad Nacional Autónoma de Honduras',
              isDark: isDark,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkAccent : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}
