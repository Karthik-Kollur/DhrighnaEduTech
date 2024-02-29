import 'dart:convert';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Ensure this matches your project structure

class TakeUrlScreen extends StatefulWidget {
  @override
  State<TakeUrlScreen> createState() => _TakeUrlScreenState();
}

class _TakeUrlScreenState extends State<TakeUrlScreen> {
  final TextEditingController _baseurl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _baseurl.dispose();
    super.dispose();
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

  Future<void> getDataFromApi(String domain, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    if (!domain.endsWith("/")) {
      domain += "/";
    }
    String url = domain + "app";
print("domain+app>>>>>>>>>>"+url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": Constants.contentType,
          "Client-Service": Constants
              .clientService, 
          "Auth-Key": Constants.authKey,
        },
      );

      final result = json.decode(response.body);
      print(result);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Save your response data to SharedPreferences as needed
        await prefs.setBool('isUrlTaken', true);
        await prefs.setString('apiUrl', result['url']);
        await prefs.setString('imagesUrl', result['site_url']);

        // Handling maintenance mode
        final isMaintenanceMode = result['maintenance_mode'] == "1";
        await prefs.setBool('maintenance_mode', isMaintenanceMode);

        // Handling locale
        final langCode = result['lang_code'] ??
            Constants.langCode; // Default to 'en' if null
        await prefs.setString('lang_code', langCode);

        if (isMaintenanceMode) {
          showMaintenanceMessage();
        } else {
          // Assuming you handle locale setting in your app initialization or on a specific screen
           setState(() {
      _isLoading = false;
    });

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginPage())); // Or LocaleScreen() based on your app flow
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid Domain.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
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
                child: SingleChildScrollView(
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
                              prefixIcon:
                                  Icon(Icons.public, color: Colors.black),
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
                              onPressed: () async {
                                getDataFromApi(_baseurl.text.trim(), context);
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    Constants.appDomain, _baseurl.text.trim());
                              },
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
                                backgroundColor:
                                    const Color.fromARGB(255, 141, 127, 10),
                                foregroundColor: Colors.white,
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
