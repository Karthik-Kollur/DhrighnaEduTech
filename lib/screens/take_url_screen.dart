import 'dart:convert';
import 'package:drighna_ed_tech/screens/login_screen.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TakeUrlScreen extends StatefulWidget {
  @override
  State<TakeUrlScreen> createState() => _TakeUrlScreenState();
}

class _TakeUrlScreenState extends State<TakeUrlScreen> {
  final TextEditingController _baseurl = TextEditingController();
  bool _isLoading = false;
  String langCode = "";

  @override
  void dispose() {
    _baseurl.dispose();
    super.dispose();
  }

  Future<void> getDataFromApi(String domain) async {
    if (!domain.endsWith("/")) {
      domain += "/";
    }
    String url = domain + "app";
    print("domain+app>>>>>>>>>>" + url);
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": Constants.contentType,
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        await _processResponse(result);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid Domain.')));
      }
    } catch (e) {
      langCode = "";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processResponse(Map<String, dynamic> result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUrlTaken', true);
    await prefs.setString('apiUrl', result['url']);
    await prefs.setString('imagesUrl', result['site_url']);

    await prefs.setString(Constants.app_ver, result["app_ver"]);
    String appLogo = result["site_url"] +
        "uploads/school_content/logo/app_logo/" +
        result["app_logo"];
    await prefs.setString(Constants.appLogo, appLogo);

    String secColour = result["app_secondary_color_code"];
    String primaryColour = result["app_primary_color_code"];
    if (secColour.length == 7 && primaryColour.length == 7) {
      await prefs.setString(Constants.secondaryColour, secColour);
      await prefs.setString(Constants.primaryColour, primaryColour);
    } else {
      await prefs.setString(
          Constants.secondaryColour, Constants.defaultSecondaryColour);
      await prefs.setString(
          Constants.primaryColour, Constants.defaultPrimaryColour);
    }

    langCode = result["lang_code"];
    await prefs.setString(Constants.langCode, langCode);

    if (!langCode.isEmpty) {
      //  setLocale(langCode);
    }

    final isMaintenanceMode = result['maintenance_mode'] == "1";
    await prefs.setBool('maintenance_mode', isMaintenanceMode);

    if (isMaintenanceMode) {
      showMaintenanceMessage();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading ? const CircularProgressIndicator() : buildForm(context),
      ),
    );
  }

  Widget buildForm(context) {
    return Container(
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
                      onPressed: () async {
                        if (_baseurl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please Enter URL')));
                        } else {
                          getDataFromApi(_baseurl.text.trim());
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString(
                              Constants.appDomain, _baseurl.text.trim());
                        }
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
    );
  }
}
