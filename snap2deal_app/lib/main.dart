import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const Snap2DealApp());
}

class Snap2DealApp extends StatelessWidget {
  const Snap2DealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap2Deal',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
