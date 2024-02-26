import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Make sure this import path matches your file structure

class TakeUrlScreen extends StatefulWidget {
  @override
  State<TakeUrlScreen> createState() => _TakeUrlScreenState();
}

class _TakeUrlScreenState extends State<TakeUrlScreen> {
  TextEditingController _baseurl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _baseurl.dispose();
    super.dispose();
  }

  Future<void> getDataFromApi(String domain, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    if (!domain.endsWith("/")) {
      domain += "/";
    }
    String url = domain + "app";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Client-Service": "your_client_service_value_here", // Update these constants as per your configuration
          "Auth-Key": "your_auth_key_value_here",
        },
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Save your response data to SharedPreferences as needed
        await prefs.setBool('isUrlTaken', true);
        await prefs.setString('apiUrl', result['url']);
        await prefs.setString('imagesUrl', result['site_url']);
        // Continue saving other needed preferences...

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); // Use pushReplacement to avoid back navigation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Domain.'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img_login_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView( // Added to ensure view is scrollable when keyboard appears
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo_small.png',
                        width: 150,
                        height: 50,
                      ),
                      const SizedBox(height: 30),
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _baseurl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your school url',
                              prefixIcon: Icon(Icons.public, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => getDataFromApi(_baseurl.text.trim(), context),
                              child: const Row(
                              
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('SUBMIT'),
                                   Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:  const Color.fromARGB(255, 141, 127, 10),
                                foregroundColor:  Colors.white,
                                // primary: Color.fromARGB(255, 141, 127, 10), // Button color
                                // onPrimary: Colors.white, // Text color
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
