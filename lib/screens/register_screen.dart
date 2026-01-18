import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Simulate registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Registro exitoso. Inicia sesión.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context); // Go back to login
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
                      'Únete a RutaPuma',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        shadows: [
                          Shadow(
                            color: AppColors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu cuenta universitaria',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Registration Card
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
                                    color: AppColors.shadowColor.withOpacity(
                                      0.2,
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
                            // Name Field
                            CustomTextField(
                              label: 'Nombre Completo',
                              hint: 'Ej. Juan Pérez',
                              prefixIcon: Icons.person_rounded,
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 20),

                            // Password Field
                            CustomTextField(
                              label: 'Crear Contraseña',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_rounded,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';
                                if (value.length < 6)
                                  return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            CustomTextField(
                              label: 'Confirmar Contraseña',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              controller: _confirmPasswordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';
                                if (value != _passwordController.text)
                                  return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // Register Button
                            CustomButton(
                              text: 'REGISTRARSE',
                              onPressed: _handleRegister,
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
                                  '¿Ya tienes cuenta? ',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? AppColors.white.withOpacity(0.7)
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
