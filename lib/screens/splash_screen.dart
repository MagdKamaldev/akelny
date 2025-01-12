import 'package:flutter/material.dart';
import 'dart:async';

import 'package:graduation/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (token == null || token == "") {
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        Navigator.pushReplacementNamed(context,'/mainNavigation');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B5E20), // Darker, elegant green background
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the app logo
              Image.asset(
                'assets/logo.png', // Path to your logo
                width: 150, // Adjust the size as needed
              ),
              const SizedBox(height: 20),
              // Display the slogan under the logo
              Text(
                'Discover. Cook. Enjoy',
                style: TextStyle(
                  fontFamily:
                      'Lato', // Make sure Lato is added to your pubspec.yaml
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors
                      .white, // White color to contrast with the dark background
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFAED581)), // Light green for loading indicator
              ),
            ],
          ),
        ),
      ),
    );
  }
}
