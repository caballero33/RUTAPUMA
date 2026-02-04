import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user info
        // Get current user info
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        var user = authProvider.currentUser;

        // Recovery: If user is null, try to reload session
        if (user == null) {
          debugPrint('⚠️ User is null, attempting to restore session...');
          await authProvider.checkSession();
          user = authProvider.currentUser;
        }

        if (user == null)
          throw Exception('Usuario no autenticado (Sesión perdida)');

        // 1. Try to get route from user profile (fastest/static)
        String? targetRouteName = user.assignedRoute;

        // 1.5. Fail-safe: If not in profile, try to parse from ID locally (Handle stale sessions)
        if (targetRouteName == null && user.uid.startsWith('BUS')) {
          try {
            if (user.uid.length >= 5) {
              final routeNumStr = user.uid.substring(3, 5);
              targetRouteName = 'Ruta $routeNumStr';
              debugPrint('⚠️ Route parsed locally from ID: $targetRouteName');
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing route locally: $e');
          }
        }

        // 2. If not in profile, try to find from assigned bus (fallback)
        if (targetRouteName == null) {
          final databaseService = DatabaseService();
          final assignedBus = await databaseService.getBusByDriverId(
            user.uid,
            requireActive: false,
          );

          if (assignedBus != null) {
            targetRouteName = assignedBus.routeName;

            // Self-healing: Save this route to user profile for future
            await DatabaseService().updateUserRoute(user.uid, targetRouteName);
          }
        }

        if (targetRouteName == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No detectamos tu ruta (${user.uid}). Cierra sesión e intenta de nuevo.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // Send announcement
        await DatabaseService().saveAnnouncement(
          driverId: user.uid,
          driverName: user.displayName,
          routeName: targetRouteName,
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aviso enviado a usuarios de $targetRouteName'),
              backgroundColor: AppColors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
          'Enviar Mensaje',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.primaryYellow
                            : AppColors.primaryBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      color:
                          isDark
                              ? AppColors.primaryYellow
                              : AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este mensaje se enviará a los usuarios suscritos a tu ruta.',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subject Field
              CustomTextField(
                label: 'Asunto',
                hint: 'Ej. Retraso por tráfico',
                prefixIcon: Icons.title_rounded,
                controller: _subjectController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El asunto es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Message Field
              // CustomTextField layout but adapted for multiline if needed
              // or just use CustomTextField if it supports it nicely.
              // CustomTextField as implemented has fixed height implicitly via layout but
              // TextInputType.multiline usually helps.
              // Let's us CustomTextField but we might need maxLines or minLines support
              // which our current CustomTextField doesn't explicitly expose for customization
              // aside from keyboardType.
              // For a message body, it's better to have more lines.
              // Since CustomTextField is rigid, I will build a custom layout here for the message area
              // to make it look like a "text area".
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 8),
                    child: Text(
                      'Mensaje',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.white.withValues(alpha: 0.8)
                                : AppColors.darkGrey,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El mensaje es requerido';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.darkBlue,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje aquí...',
                      hintStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.white.withValues(alpha: 0.3)
                                : AppColors.grey.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkAccent : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            isDark
                                ? const BorderSide(
                                  color: AppColors.darkBorder,
                                  width: 1,
                                )
                                : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.primaryYellow
                                  : AppColors.primaryBlue,
                          width: 3,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Send Button
              CustomButton(
                text: 'ENVIAR AVISO',
                onPressed: _sendMessage,
                gradient: isDark ? AppColors.blueGradient : null,
                color: isDark ? null : AppColors.primaryBlue,
                textColor: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
