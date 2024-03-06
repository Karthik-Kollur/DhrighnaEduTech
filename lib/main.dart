

import 'package:drighna_ed_tech/screens/about_screen.dart';
import 'package:drighna_ed_tech/screens/home_screen.dart';
import 'package:drighna_ed_tech/screens/profile_screen.dart';
import 'package:drighna_ed_tech/screens/settings_screen.dart';
import 'package:drighna_ed_tech/screens/splash_screen.dart';
import 'package:drighna_ed_tech/screens/students/dashboard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



void main() {
  runApp( ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashScreen(), // Define the SplashScreen route
        '/home': (context) => DashboardScreen(),
        '/profile': (context) => ProfileScreen(),
        '/about': (context) => AboutScreen(),
        '/settings': (context) => SettingsScreen(),
        // Add other routes as needed
      },
      
    );
  }
}
