import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Navigate to map screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(userRole: _selectedRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryYellow,
              AppColors.primaryYellow,
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo and Title
                    _buildHeader(),
                    const SizedBox(height: 50),
                    // Login Form
                    _buildLoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo placeholder - you can replace with actual logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus,
            size: 60,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'RUTAPUMA',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: AppColors.primaryBlue,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'UNAH Campus Cortés',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
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
            const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Role Selection
            _buildRoleSelector(),
            const SizedBox(height: 24),
            // Email Field
            CustomTextField(
              label: 'Correo Electrónico',
              hint: 'estudiante@unah.hn',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                if (!value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password Field
            CustomTextField(
              label: 'Contraseña',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Login Button
            CustomButton(
              text: 'Ingresar',
              onPressed: _handleLogin,
              gradient: AppColors.primaryGradient,
            ),
            const SizedBox(height: 16),
            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta? ',
                  style: TextStyle(color: AppColors.darkGrey),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to register screen
                  },
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Usuario',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleOption(UserRole.user)),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleOption(UserRole.driver)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption(UserRole role) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.blueGradient : null,
          color: isSelected ? null : AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              role == UserRole.user ? Icons.person : Icons.drive_eta,
              color: isSelected ? AppColors.white : AppColors.primaryBlue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              role.displayName,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.darkGrey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              role.description,
              style: TextStyle(
                color:
                    isSelected
                        ? AppColors.white.withOpacity(0.9)
                        : AppColors.grey,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
