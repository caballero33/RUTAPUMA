import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'constants/colors.dart';
import 'models/user_role.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/route_monitor_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize route monitoring service
  final routeMonitor = RouteMonitorService();
  await routeMonitor.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const RutaPumaApp(),
    ),
  );
}

class RutaPumaApp extends StatelessWidget {
  const RutaPumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        // Set status bar theme dynamically
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        return MaterialApp(
          title: 'RUTAPUMA',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const AuthChecker(), // Check for existing session
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = AppColors.primaryBlue;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightGrey;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.darkBlue;

    return ThemeData(
      primaryColor: baseColor,
      scaffoldBackgroundColor: backgroundColor,
      brightness: brightness,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
        primary: baseColor,
        secondary: AppColors.primaryYellow,
        surface: surfaceColor,
        background: backgroundColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: isDark ? 0 : 4,
          shadowColor: isDark ? Colors.transparent : AppColors.shadowColor,
          side:
              isDark
                  ? const BorderSide(color: AppColors.darkBorder, width: 1)
                  : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? AppColors.primaryYellow : AppColors.white,
        foregroundColor: isDark ? AppColors.darkBlue : AppColors.primaryBlue,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: baseColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      useMaterial3: true,
    );
  }
}

// AuthChecker widget to handle auto-login
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final storageService = StorageService();
    final session = await storageService.getSession();

    if (!mounted) return;

    if (session != null) {
      // User has active session, navigate to MapScreen
      final role = session['role'] as UserRole;
      final driverId = session['driverId'] as String?;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(userRole: role, driverId: driverId),
        ),
      );
    } else {
      // No session, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking session
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
