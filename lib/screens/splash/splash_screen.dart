import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {

    final prefs = await SharedPreferences.getInstance();

    bool completed =
        prefs.getBool("profileCompleted") ?? false;

    // Show splash screen for 2 seconds
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    if (completed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: SweepGradient(
            center: Alignment.center,
            startAngle: 0.0,
            endAngle: 6.28319,
            colors: [
              Color(0xFFFF5FA2),
              Color(0xFFFF8CC8),
              Color(0xFFD63384),
              Color(0xFFFF5FA2),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.fact_check_rounded,
              size: 100,
              color: Colors.white,
            ),

            SizedBox(height: 25),

            Text(
              "DIGITAL ATTENDANCE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Smart Attendance System",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 45),

            SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),

            SizedBox(height: 50),

            Text(
              "Version 1.0",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

          ],
        ),
      ),
    );
  }
}