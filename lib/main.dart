import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'constants/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const RutaPumaApp());
}

class RutaPumaApp extends StatelessWidget {
  const RutaPumaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUTAPUMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryYellow,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.primaryBlue),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
