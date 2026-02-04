import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  final String supportEmail = 'soporte@rutapuma.unah.edu.hn';

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Correo copiado al portapapeles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Ayuda y Soporte',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Hero Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.darkAccent
                        : AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 80,
                color: isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 40),

            // Title
            Text(
              '¿Necesitas Ayuda?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.white : AppColors.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Si encuentras algún error o tienes problemas con la aplicación, por favor contacta a nuestro equipo de soporte técnico.',
              style: TextStyle(
                fontSize: 16,
                color:
                    isDark
                        ? AppColors.white.withValues(alpha: 0.7)
                        : AppColors.darkGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Contact Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                boxShadow:
                    isDark
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
              ),
              child: Column(
                children: [
                  Text(
                    'Correo de Soporte',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark
                              ? AppColors.white.withValues(alpha: 0.5)
                              : AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_rounded,
                          color:
                              isDark
                                  ? AppColors.primaryYellow
                                  : AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            supportEmail,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? AppColors.primaryYellow
                                      : AppColors.primaryBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('COPIAR CORREO'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? AppColors.white : AppColors.primaryBlue,
                        backgroundColor:
                            isDark
                                ? AppColors.darkAccent
                                : AppColors.primaryBlue.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),

            // Footer Version
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkBorder
                        : AppColors.grey.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
