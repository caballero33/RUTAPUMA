import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme provider
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Avisos',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightGrey,
                shape: BoxShape.circle,
                boxShadow:
                    isDark
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.shadowColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 80,
                color:
                    isDark ? AppColors.white.withOpacity(0.2) : AppColors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tiene notificaciones',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.darkBlue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Te avisaremos cuando haya novedades\nimportantes sobre tu ruta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.white.withOpacity(0.6)
                        : AppColors.darkGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
