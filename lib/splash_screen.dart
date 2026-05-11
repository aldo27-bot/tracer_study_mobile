import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rive/rive.dart';

import 'main.dart';
import 'screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      // Delay untuk animation
      await Future.delayed(const Duration(seconds: 3));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // cek login
      bool isLogin = prefs.getBool('isLogin') ?? false;
      print("[SPLASH] IS_LOGIN: $isLogin");

      if (!mounted) return; // Check jika widget masih ada

      if (isLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e, stackTrace) {
      print("[SPLASH ERROR] $e");
      print(stackTrace);
      
      if (!mounted) return;
      
      // Navigate ke LoginPage jika ada error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2D3F),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: RiveAnimation.asset(
                "assets/animations/education.riv",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Tracer Study Alumni",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Politeknik Negeri Jember PSDKU Nganjuk",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
