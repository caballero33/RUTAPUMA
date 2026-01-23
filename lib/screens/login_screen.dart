import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'map_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
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
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        if (_selectedRole == UserRole.driver) {
          // Driver Authentication Logic - Keep hardcoded for now
          bool authenticated = false;
          // Check 14 routes, 2 IDs each
          for (int r = 1; r <= 14; r++) {
            final rStr = r.toString().padLeft(2, '0');
            for (int i = 1; i <= 2; i++) {
              final iStr = i.toString().padLeft(2, '0');
              final id = 'BUS$rStr$iStr';
              final key = 'ruta$rStr$iStr';
              if (email.toUpperCase() == id && password == key) {
                authenticated = true;
                break;
              }
            }
            if (authenticated) break;
          }

          // Close loading dialog
          if (mounted) Navigator.of(context).pop();

          if (!authenticated) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID o Llave del bus incorrecta'),
                  backgroundColor: AppColors.red,
                ),
              );
            }
            return;
          }
        } else {
          // User Authentication with Firebase
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final success = await authProvider.signIn(email, password);

          // Close loading dialog
          if (mounted) Navigator.of(context).pop();

          if (!success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    authProvider.errorMessage ??
                        'Error al iniciar sesión. Verifica tus credenciales.',
                  ),
                  backgroundColor: AppColors.red,
                ),
              );
            }
            return;
          }
        }

        // Navigate to map screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MapScreen(
                    userRole: _selectedRole,
                    driverId:
                        _selectedRole == UserRole.driver
                            ? email.toUpperCase()
                            : null,
                  ),
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
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
          // Background Gradient
          // Solid Background
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
                        color: Colors.transparent, // Removed white background
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

                    // Welcome Text
                    Text(
                      'Bienvenido a RutaPuma',
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
                      'Tu transporte universitario seguro',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Login Card
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
                            // Role Selection
                            _buildRoleSelectorWithContext(context, isDark),
                            const SizedBox(height: 24),

                            // Fields
                            CustomTextField(
                              label:
                                  _selectedRole == UserRole.driver
                                      ? 'ID del Bus'
                                      : 'Correo Institucional',
                              hint:
                                  _selectedRole == UserRole.driver
                                      ? '********'
                                      : 'estudiante@unah.hn',
                              prefixIcon:
                                  _selectedRole == UserRole.driver
                                      ? Icons.numbers_rounded
                                      : Icons.email_rounded,
                              controller: _emailController,
                              keyboardType:
                                  _selectedRole == UserRole.driver
                                      ? TextInputType.text
                                      : TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';

                                if (_selectedRole == UserRole.user &&
                                    !value.contains('@')) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label:
                                  _selectedRole == UserRole.driver
                                      ? 'Llave del Bus'
                                      : 'Contraseña',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_rounded,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Requerido';
                                if (value.length < 4)
                                  return 'Mínimo 4 caracteres';
                                return null;
                              },
                            ),

                            // Remember & Forgot Row
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: true,
                                          onChanged: (v) {},
                                          activeColor:
                                              isDark
                                                  ? AppColors.primaryYellow
                                                  : AppColors.primaryBlue,
                                          side: BorderSide(
                                            color:
                                                isDark
                                                    ? AppColors.white
                                                        .withOpacity(0.5)
                                                    : AppColors.grey,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recordarme',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? AppColors.white.withOpacity(
                                                    0.7,
                                                  )
                                                  : AppColors.darkGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_selectedRole == UserRole.user)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '¿Olvidaste contraseña?',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? AppColors.primaryYellow
                                                  : AppColors.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Login Button
                            CustomButton(
                              text: 'INICIAR SESIÓN',
                              onPressed: _handleLogin,
                              gradient: isDark ? AppColors.blueGradient : null,
                              color:
                                  isDark
                                      ? null
                                      : AppColors
                                          .primaryBlue, // Dark blue button on white card
                              textColor: AppColors.white,
                            ),

                            const SizedBox(height: 20),

                            if (_selectedRole == UserRole.user)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿No tienes cuenta? ',
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Regístrate aquí',
                                      style: TextStyle(
                                        color:
                                            AppColors
                                                .primaryYellow, // Accent color
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

          // Theme Toggle (Moved to end for Z-order)
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

  // Refactored Role Selector to be cleaner
  Widget _buildRoleSelectorWithContext(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black.withOpacity(0.2) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildRoleChip(UserRole.user, 'Estudiante', isDark)),
          Expanded(child: _buildRoleChip(UserRole.driver, 'Conductor', isDark)),
        ],
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, String label, bool isDark) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDark ? AppColors.primaryBlue : AppColors.white)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected && !isDark
                  ? [
                    BoxShadow(
                      color: AppColors.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                isSelected
                    ? (isDark ? AppColors.white : AppColors.primaryBlue)
                    : (isDark
                        ? AppColors.white.withOpacity(0.5)
                        : AppColors.darkGrey),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
