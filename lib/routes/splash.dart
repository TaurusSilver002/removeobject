import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the first time opening the app
    final bool isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    // Add a small delay for splash effect (optional)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    if (isFirstTime) {
      // First time - show onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // Not first time - go directly to gallery
      Navigator.pushReplacementNamed(context, '/gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo here
            Icon(
              Icons.photo_library,
              size: 80,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'ObjectRemove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
