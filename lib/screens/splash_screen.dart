import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:david_advmobprog/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    getIsLogin();
    _logAssetPresence();
    super.initState();
  }

  Future<void> _logAssetPresence() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final found = manifest.contains('assets/images/login_logo.png');
      debugPrint('[Splash] AssetManifest contains login_logo.png: $found');
    } catch (e) {
      debugPrint('[Splash] Failed to read AssetManifest.json: $e');
    }
  }

  Future<void> getIsLogin() async {
    final userData = await UserService().getUserData();

    if (userData['token'] != null && userData['token'] != '') {
      // User is logged in
      Timer(
        const Duration(seconds: 4),
        () => Navigator.popAndPushNamed(context, '/home'),
      );
    } else {
      // User is not logged in
      Timer(
        const Duration(seconds: 4),
        () => Navigator.popAndPushNamed(context, '/login'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/login_logo.png',
              height: 120,
              errorBuilder: (context, error, stack) =>
                  const SizedBox(height: 120),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
