import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'login_screen.dart';
import 'student_fees.dart';
import 'take_url_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initialization() async {
    checkInternetConnection();
  }

  void checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    backgroundColor: Colors.transparent, // Set background to transparent
    content: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircularProgressIndicator(),
        Text(
          'No internet connection! Waiting for connection...',
          style: TextStyle(color: Colors.black), // Set text color to black
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating, // Use floating behavior for better appearance with transparent background
    elevation: 0, // Remove shadow
  ),
);

      // Retry checking for internet connection every 5 seconds
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        checkInternetConnection();
      });
    } else {
      // If there is an internet connection, cancel the timer and proceed
      _timer?.cancel();
      checkInitialScreen();
    }
  }

  Future<void> checkInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUrlTaken = prefs.getBool('isUrlTaken') ?? false;
    bool isLoggedin = prefs.getBool(Constants.isLoggegIn) ?? false;
    bool isLock = prefs.getBool(Constants.isLock) ?? false;
    String apiUrl = prefs.getString(Constants.apiUrl) ?? Constants.domain + "/api/";

    if (isUrlTaken) {
      checkMaintenanceMode(apiUrl, isLoggedin, isLock);
    } else {
      navigateToTakeUrlScreen();
    }
  }

  void checkMaintenanceMode(String apiUrl, bool isLoggedin, bool isLock) async {
    final response = await http.post(
      Uri.parse("$apiUrl" + Constants.getMaintenanceModeStatusUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      bool maintenanceMode = result['maintenance_mode'] == '1';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('maintenance_mode', maintenanceMode);

      if (!maintenanceMode) {
        navigateBasedOnLoginStatus(isLoggedin, isLock);
      } else {
        showMaintenanceMessage();
      }
    } else {
      print("Error checking maintenance mode");
    }
  }

  void navigateBasedOnLoginStatus(bool isLoggedin, bool isLock) {
    if (isLoggedin) {
      if (isLock) {
        navigateToStudentFees();
      } else {
        navigateToNewDashboard();
      }
    } else {
      navigateToLoginScreen();
    }
  }

  void navigateToTakeUrlScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TakeUrlScreen()));
  }

  void navigateToNewDashboard() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
  }

  void navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void navigateToStudentFees() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentFees()));
  }

  void showMaintenanceMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Maintenance"),
          content: const Text("The app is currently under maintenance."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img_login_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _timer == null ? Image.asset("assets/logo_small.png", width: 150.0, height: 100.0) : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
