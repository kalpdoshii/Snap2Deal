import 'package:flutter/material.dart';
import 'package:snap2deal_app/screens/home/home_screen_red.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen_v2.dart';
import 'screens/splash/splash_screen.dart';



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
      home: const HomeScreenRed(),
    );
  }
}
