import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      // Logic handled by backend later
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Se ha enviado un correo de recuperación.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context); // Return to login
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for toggling
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Use Theme.of(context) for visual properties to ensure sync with MaterialApp
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background (Identical to Login)
          Container(
            color: isDark ? AppColors.darkBackground : AppColors.primaryYellow,
          ),

          // Main Content Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                100,
              ), // Extra bottom padding
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Floating above text
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/rutapuma_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Text
                    Text(
                      'Recuperar Contraseña',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        shadows: [
                          Shadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa tu correo institucional',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        border:
                            isDark
                                ? Border.all(
                                  color: AppColors.darkBorder,
                                  width: 1.5,
                                )
                                : null,
                        boxShadow:
                            isDark
                                ? null
                                : [
                                  BoxShadow(
                                    color: AppColors.shadowColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            CustomTextField(
                              label: 'Correo Institucional',
                              hint: 'estudiante@unah.hn',
                              prefixIcon: Icons.email_rounded,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';
                                if (!value.contains('@'))
                                  return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Send Button
                            CustomButton(
                              text: 'ENVIAR',
                              onPressed: _handleSend,
                              gradient: isDark ? AppColors.blueGradient : null,
                              color: isDark ? null : AppColors.primaryBlue,
                              textColor: AppColors.white,
                            ),

                            const SizedBox(height: 20),

                            // Back to Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Recordaste tu contraseña? ',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? AppColors.white.withValues(
                                              alpha: 0.7,
                                            )
                                            : AppColors.darkGrey,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      color: AppColors.primaryYellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Theme Toggle
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppColors.primaryYellow : AppColors.white,
                size: 30,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
