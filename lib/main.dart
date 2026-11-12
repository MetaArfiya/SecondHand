import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'users/login_page.dart';
import 'main_navigation.dart';
import 'onboarding_page.dart';
import 'admin/admin_dashboard_page.dart';

void main() {
  runApp(const SecondHandApp());
}

class SecondHandApp extends StatelessWidget {
  const SecondHandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecondHand Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MainNavigation(),
        '/admin': (_) => const AdminDashboardPage(),
      },
    );
  }
}
