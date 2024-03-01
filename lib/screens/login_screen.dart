import 'dart:convert';

import 'package:drighna_ed_tech/screens/dashboard.dart';
import 'package:drighna_ed_tech/screens/forgot_password_screen.dart';
import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<String> childNameList = [];
  List<String> childIdList = [];
  List<String> childImageList = [];
  List<String> childClassList = [];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showChildList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context)
                    .secondaryHeaderColor, // Change this to your secondary color
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Child List',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // set text style as per your design
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: childNameList
                      .length, // Assume childNameList is a list of strings
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Colors.white,
                      elevation: 10,
                      child: ListTile(
                        leading: childImageList[index] != null
                            ? Image.network(
                                childImageList[index],
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  // If the image fails to load, you can return an error image or icon
                                  return const Icon(Icons.error);
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height:
                                        30, // Match the Image.network height
                                    width: 30, // Match the Image.network width
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              )

                            // Replace with the appropriate image provider
                            : const CircleAvatar(
                                child: Text("not set"),
                              ), // Default image
                        title: Text(
                          childNameList[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(childClassList[index]),
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool(Constants.isLoggegIn, true);

                          await prefs.setString(
                              Constants.classSection, childClassList[index]);

                          await prefs.setString(
                              Constants.studentId, childIdList[index]);
                          await prefs.setString(
                              "studentName", childNameList[index]);
                          // await prefs.setString('selectedChild', jsonEncode(children[0]));
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DashboardScreen())); // Adjust as needed
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getDataFromApi(
      BuildContext context, String username, String password) async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Username and password cannot be empty")));
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    String dToken =
        "fxj9AGhzrYg:APA91bGdKnxmiKeK2woXsDqTLtUyL-NxqUOYqVNb383zn44fc5rEjeUqke3bGmGZqbt3k7drI0rqfxv6rJMhbIBc0T8X2iVmeyEA2UN5FJPsDwoGF9KdPkgvmPHENs3ex701R3I21EFx";

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? apiUrl = prefs.getString("apiUrl") ?? "";
      print(apiUrl);
      if (apiUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("API URL is not set in SharedPreferences.")));
        return;
      }
      apiUrl += Constants.loginUrl;

      print(apiUrl);

      final requestBody = jsonEncode({
        'username': username.trim(),
        'password': password,
        'deviceToken': dToken,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': Constants.contentType,
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 1) {
          await prefs.setString(Constants.loginType, data['role']);

          Map<String, dynamic> recordData = data['record'];
          print(">>>>>>>>>>>>>>>>>>>>>>>>>" + data['role']);

          await prefs.setString(Constants.userId, data['id']);
          await prefs.setString('accessToken', data['token']);
          await prefs.setString('schoolName', recordData['sch_name']);
          await prefs.setString(Constants.userName, recordData['username']);
          await prefs.setString(
              Constants.currency_short_name, recordData['currency_short_name']);

          await prefs.setString('startWeek', recordData['start_week']);

          await prefs.setString(
              Constants.currency, recordData['currency_symbol']);
          await prefs.setString(Constants.superadmin_restriction,
              recordData['superadmin_restriction']);

          await prefs.setString(
              Constants.langCode, recordData['language']['short_code']);

          String imageUrl =
              prefs.getString("imagesUrl") ?? "" + (recordData['image'] ?? "");

          await prefs.setString(Constants.userImage, imageUrl);

          await prefs.setString(Constants.userName, recordData['username']);

          print("Role from API: ${data['role']}");

          if (data['role'] == 'parent') {
            print(">>>>>>>>>>>>>>>>>>>>>>>>>" + "Inside of parent role");

            await prefs.setString(Constants.parentsId, recordData['id']);

            print(recordData['parent_childs'].runtimeType);
            // Handling parent role
            final children = recordData['parent_childs'].map((child) {
              return {
                'student_id': child['student_id'],
                'class': child['class'],
                'section': child['section'],
                'class_id': child['class_id'],
                'section_id': child['section_id'],
                'name': child['name'],
                'image': child['image'] ??
                    'default_image_path', // Provide a default image path if null
              };
            }).toList();

            print(children);
            print(children.length);
            print(children.length > 1);
            // childNameList.add(children[0]['name']);

            // print(childNameList);

            if (children.length == 1) {
              print(">>>>>>>>>>>>>in one child section>>>>>>>>>>>>" +
                  children.toString());
              await prefs.setBool(Constants.isLoggegIn, true);
              await prefs.setBool('hasMultipleChild', false);
              await prefs.setString(Constants.classSection,
                  children[0]['class'] + " - " + children[0]['section']);

              await prefs.setString(
                  Constants.studentId, children[0]['student_id']);
              await prefs.setString("studentName", children[0]['name']);

              // Logic for single child, directly set child info and navigate
              // await prefs.setString('selectedChild', jsonEncode(children[0]));
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => DashboardScreen())); // Adjust as needed
            } else {
              //if parent has multiple children
              print(">>>>>>>>>>>>>in multiple child section>>>>>>>>>>>>" +
                  children.toString());
              await prefs.setBool('hasMultipleChild', true);
              childNameList.clear();
              childIdList.clear();
              childImageList.clear();
              childClassList.clear();

              for (int i = 0; i < children.length; i++) {
                childNameList.add(children[i]['name']);
                childIdList.add(children[i]['student_id']);
                childImageList.add(children[i]['image']);
                childClassList.add(children[i]['class'] +
                    " - " +
                    children[i]["section"].toString());
              }

              showChildList(context);
//show child list method run here
            }
          } else if (data['role'] == 'student') {
            await prefs.setBool(Constants.isLoggegIn, true);
            await prefs.setString(Constants.classSection,
                recordData['class'] + " (" + recordData['section'] + ")");
            await prefs.setString(
                Constants.studentId, recordData['student_id']);
            await prefs.setString(
                Constants.admission_no, recordData['admission_no']);
          } else {
            await prefs.setBool(Constants.isLoggegIn, false);
          }

          setState(() {
            _isLoading = false;
          });

          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (context) => DashboardScreen()),
          //   (Route<dynamic> route) => false,
          // );
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data from API')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  Future<void> _launchInBrowser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString(Constants.appDomain) ?? "";

    if (!domain.endsWith("/")) {
      domain += "/";
    }
    domain += Constants.privacyPolicyUrl;

    if (!await launchUrl(
      Uri.parse(domain),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $domain'; // Corrected $url to $domain
    }
  }

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage(
                  'assets/img_login_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/splash_logo.png',
                      width: 150.0, height: 50.0),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.person),
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText:
                        !_isPasswordVisible, // Use the _isPasswordVisible flag here
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Change the icon based on visibility state
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()));
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.key,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ))
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            getDataFromApi(context, _usernameController.text,
                                _passwordController.text);
                            setState(() {
                              _isLoading = false; // Stop loading
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 141, 127, 10)),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SharedPreferencesDetailsScreen()));
                    },
                    child: const Text("go to shared prefs"),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0, // Positions the child widget at the bottom of the Stack
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _launchInBrowser();
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.public))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
