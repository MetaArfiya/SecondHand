import 'package:flutter/material.dart';
import 'api_service.dart';
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
      home: const AppStartupPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MainNavigation(),
        '/admin': (_) => const AdminDashboardPage(),
      },
    );
  }
}

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({super.key});

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  late final Future<bool> _session = ApiService.restoreSession();

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _session,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snapshot.data == true
          ? const MainNavigation()
          : const OnboardingPage();
    },
  );
}
