import 'dart:convert';

import 'package:drighna_ed_tech/screens/dashboard.dart';
import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Add this line for loading state
bool _isPasswordVisible = false; // This will track the visibility state

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> getDataFromApi(BuildContext context, String username, String password) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String dToken = "fxj9AGhzrYg:APA91bGdKnxmiKeK2woXsDqTLtUyL-NxqUOYqVNb383zn44fc5rEjeUqke3bGmGZqbt3k7drI0rqfxv6rJMhbIBc0T8X2iVmeyEA2UN5FJPsDwoGF9KdPkgvmPHENs3ex701R3I21EFx";

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final apiUrl = (await prefs.getString("apiUrl"))! + Constants.loginUrl;

      final requestBody = jsonEncode({
        'username': username,
        'password': password,
        'deviceToken': dToken,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Client-Service': 'smartschool',
          'Auth-Key': 'schoolAdmin@',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 1) {
          await prefs.setString("userId", data['id']);
          await prefs.setString('accessToken', data['token']);
          await prefs.setString('schoolName', data['record']['sch_name']);
          await prefs.setString(Constants.userName, data['record']['username']);
          await prefs.setBool(Constants.isLoggegIn, true);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data from API')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, show loading dialog
    if (_isLoading) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false, // User must tap button to close dialog
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Logging in..."),
                  ],
                ),
              ),
            );
          },
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img_login_background.png',),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/splash_logo.png', width: 150.0, height: 50.0),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.person),
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                 TextField(
  controller: _passwordController,
  obscureText: !_isPasswordVisible, // Use the _isPasswordVisible flag here
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    prefixIcon: const Icon(Icons.lock),
    suffixIcon: IconButton(
      icon: Icon(
        // Change the icon based on visibility state
        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        // Toggle the password visibility state
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    ),
    hintText: 'Password',
  ),
),

                  const SizedBox(height: 20.0),
                
Row(
 mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: ElevatedButton(
        
        onPressed: () {
           getDataFromApi(context, _usernameController.text, _passwordController.text);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 141, 127, 10)),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'SUBMIT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ),
  ],
),



                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SharedPreferencesDetailsScreen()));
                    },
                    child: const Text("go to shared prefs"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
