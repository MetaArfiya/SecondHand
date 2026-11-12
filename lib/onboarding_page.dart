import 'dart:async';

import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Timer? _redirectTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 4), _openLogin);
  }

  void _openLogin() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _redirectTimer?.cancel();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openLogin,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Image.asset(
                  'assets/images/logo_secondHand.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
