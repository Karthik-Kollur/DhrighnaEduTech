import 'dart:convert';
import 'dart:math';
import 'package:drighna_ed_tech/screens/forgot_password_screen.dart';
import 'package:drighna_ed_tech/screens/student_fees.dart';
import 'package:drighna_ed_tech/screens/students/dashboard.dart';
import 'package:drighna_ed_tech/screens/take_url_screen.dart';
import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
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

  String _appLogoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAppLogo();
  }

  Future<void> _loadAppLogo() async {
    final prefs = await SharedPreferences.getInstance();
    String baseLogoUrl = prefs.getString(Constants.appLogo) ?? '';
    setState(() {
      // Append a random query parameter to the URL to avoid caching
      _appLogoUrl = '$baseLogoUrl?${Random().nextInt(100)}';
    });
    print("App Logo url is >>>>>>>>>>>>>>>>>" + _appLogoUrl);
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username and password cannot be empty');
      return;
    }
    setState(() => _isLoading = true);
    String dToken =
        "fxj9AGhzrYg:APA91bGdKnxmiKeK2woXsDqTLtUyL-NxqUOYqVNb383zn44fc5rEjeUqke3bGmGZqbt3k7drI0rqfxv6rJMhbIBc0T8X2iVmeyEA2UN5FJPsDwoGF9KdPkgvmPHENs3ex701R3I21EFx";
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiUrl = prefs.getString("apiUrl") ?? "";
      if (apiUrl.isEmpty) {
        _showSnackBar("API URL is not set in SharedPreferences.");
        return;
      }
      final fullApiUrl = Uri.parse(apiUrl + Constants.loginUrl);
      final response = await http.post(
        fullApiUrl,
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': Constants.contentType,
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'deviceToken': dToken,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          await _saveUserInfo(data);
          if (data['role'] == 'parent') {
            await _handleParentRole(data['record'], data['message']);
          } else if (data['role'] == 'student') {
            _handleStudentRole(data['record'], data['message']);

            _showSnackBar(data['message'] + "Student");
          }
          // else{
          //   await prefs.setBool(Constants.isLoggegIn, false);
          // }
        } else {
          _showSnackBar("No data from the API status = 0");
        }
      } else {
        _showSnackBar('Failed to fetch data from API');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.loginType, data['role']);
    Map<String, dynamic> recordData = data['record'];
    await prefs.setString(Constants.userId, data['id']);
    await prefs.setString('accessToken', data['token']);
    await prefs.setString('schoolName', recordData['sch_name']);
    await prefs.setString(Constants.userName, recordData['username']);
    await prefs.setString(
        Constants.currency_short_name, recordData['currency_short_name']);

    await prefs.setString('startWeek', recordData['start_week']);

    await prefs.setString(Constants.currency, recordData['currency_symbol']);
    await prefs.setString(
        Constants.superadmin_restriction, recordData['superadmin_restriction']);

    String dateFormat = recordData["date_format"] ?? "";
    // Convert the date format from API response to Dart's DateFormat
    dateFormat = dateFormat
        .replaceAll("Y", "yyyy")
        .replaceAll("m", "MM")
        .replaceAll("d", "dd");

    // Saving the date format
    await prefs.setString("dateFormat", dateFormat);

    // Creating and saving the datetime format
    String datetimeFormat =
        "$dateFormat HH:mm:ss"; // Assuming you want to append time in HH:mm:ss format

    await prefs.setString("datetimeFormat", datetimeFormat);

    await prefs.setString(
        Constants.langCode, recordData['language']['short_code']);

    String imageUrl =
        prefs.getString("imagesUrl") ?? "" + (recordData['image'] ?? "");

    await prefs.setString(Constants.userImage, imageUrl);

    await prefs.setString(Constants.userName, recordData['username']);

    print("Role from API: ${data['role']}");

    // Save other user info as needed.
  }

  Future<void> _handleParentRole(
      Map<String, dynamic> recordData, String data) async {
    final prefs = await SharedPreferences.getInstance();
    print(">>>>>>>>>>>>>>>>>>>>>>>>>" + "Inside of parent role");

    await prefs.setString(Constants.parentsId, recordData['id']);

    // Handling parent role
    final children = recordData['parent_childs'];

    print(children);
    print(children.length);

    if (children.length == 1) {
      print(">>>>>>>>>>>>>in one child section>>>>>>>>>>>>" +
          children.toString());
      await prefs.setBool(Constants.isLoggegIn, true);
      await prefs.setBool('hasMultipleChild', false);
      await prefs.setString(Constants.classSection,
          children[0]['class'] + " - " + children[0]['section']);

      await prefs.setString(Constants.studentId, children[0]['student_id']);
      await prefs.setString("studentName", children[0]['name']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data + "parent with one child")),
      );

      // Logic for single child, directly set child info and navigate
      // await prefs.setString('selectedChild', jsonEncode(children[0]));
      await _navigateToDashboard();
    } else {
      setState(() {
        _isLoading = false;
      });
      //if parent has multiple children
      print(">>>>>>>>>>>>>in multiple child section>>>>>>>>>>>>" +
          children.toString());
      await prefs.setBool('hasMultipleChild', true);
      childNameList.clear();
      childIdList.clear();
      childImageList.clear();
      childClassList.clear();

      print(children.length.toString());

      for (int i = 0; i <children.length; i++) {
        childNameList.add(children[i]['name'].toString());
        childIdList.add(children[i]['student_id'].toString());
        childImageList.add(children[i]['image'].toString());
        childClassList.add(
            children[i]['class'] + " - " + children[i]["section"].toString());
      }


      print(childNameList.toString());


      // print(childImageList.toString());
//show child list method run here
      showChildList(context);
    }
    // Handle parent role logic and save necessary info.
    // Example: await prefs.setString('parentRoleData', recordData['someParentData']);
    // Navigate to dashboard or show child list based on the role.
    // await _navigateToDashboard();
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
                // color:Color(0xFF9E9E9E),
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
                                  return const Icon(Icons.person);
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Successfully loged in parent with one of his child")),
                          );
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

  void _handleStudentRole(Map<String, dynamic> recordData, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isLoggegIn, true);
    await prefs.setString(Constants.classSection,
        recordData['class'] + " (" + recordData['section'] + ")");
    await prefs.setString(Constants.studentId, recordData['student_id']);
    await prefs.setString(Constants.admission_no, recordData['admission_no']);
    String studId = prefs.getString(Constants.studentId) ?? '';
    getCurrencyDataFromApi(studId);

    isProfileLock(context, studId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data + "Student")),
    );
  }

  Future<void> getCurrencyDataFromApi(String stdId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString("apiUrl") ?? "";
    final userId = prefs.getString("userId") ?? "";
    final accessToken = prefs.getString("accessToken") ?? "";
    final url = "$apiUrl${Constants.getStudentCurrencyUrl}";

    // Prepare headers and body
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": Constants.contentType,
      "User-ID": userId,
      "Authorization": accessToken,
    };

    final body = jsonEncode({
      "student_id": stdId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      print(">>>>>>>>>>>>>>>>>>>>" + stdId);
      print(">>>>>>>>>>>>>>>>>>>>" + response.body);
      print(">>>>>>>>>>>>>>>>>>>>" + url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // final data = result['result'];

        // Save the fetched currency data to SharedPreferences
        await prefs.setString(Constants.currency_price, result['base_price']);
        await prefs.setString(Constants.currency_short_name, result['name']);
        await prefs.setString(Constants.currency, result['symbol']);
      } else {
        print('Failed to fetch data from API');
        // Handle HTTP error
      }
    } catch (e) {
      print('An error occurred: $e');
      // Handle exceptions
    }
  }

  Future<void> isProfileLock(BuildContext context, stdId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl = prefs.getString('apiUrl') ?? '';
    final String url = apiUrl + Constants.lock_student_panelUrl;
    final body = jsonEncode({
      "student_id": stdId,
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': Constants.contentType,
          'User-ID': prefs.getString('userId') ?? '',
          'Authorization': prefs.getString('accessToken') ?? '',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final object = json.decode(response.body);
        final isLock = object['is_lock'].toString();
        print('is_lock: $isLock');

        await prefs.setBool('isLock', isLock == '0' ? false : true);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              isLock == '0' ? DashboardScreen() : const StudentFees(),
        ));
      } else {
        // Handle the case where the server returns a non-200 status code.
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request.
      print('HTTP request error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _navigateToDashboard() async {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
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
      _showSnackBar('Could not launch $domain');
    }
  }

  void changeUrl(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggegIn", false);
    prefs.setBool("isUrlTaken", false);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => TakeUrlScreen())); //
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img_login_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Image.asset('assets/splash_logo.png',
                //     width: 150.0, height: 50.0),
                _appLogoUrl.isEmpty
                    ? const CircularProgressIndicator() // Show loading indicator while fetching the logo
                    : Image.network(
                        _appLogoUrl,
                        width: 100, // Set your desired width
                        height: 100, // And height
                        color: Colors.black,
                        fit: BoxFit.contain,
                      ),
                const SizedBox(height: 3),
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
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
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
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.key, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 141, 127, 10),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          shape: MaterialStateProperty.all(
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
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.white),
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
                        builder: (context) => SharedPreferencesDetailsScreen(),
                      ),
                    );
                  },
                  child: const Text("go to shared prefs"),
                ),
              ],
            ),
          ),
        ),

        //  Positioned(
        //           top: 200, // Adjust the position as needed
        //           left: MediaQuery.of(context).size.width / 2 - 50, // Center the logo
        //           child: _appLogoUrl.isEmpty
        //               ? CircularProgressIndicator() // Show loading indicator while fetching the logo
        //               : Image.network(
        //                   _appLogoUrl,
        //                   width: 200, // Set your desired width
        //                   height: 100, // And height
        //                   color: Colors.black,
        //                 ),
        //         ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _launchInBrowser,
                  child: const Text('Privacy Policy',
                      style: TextStyle(color: Colors.black)),
                ),
                IconButton(
                    onPressed: () {
                      changeUrl(context);
                    },
                    icon: const Icon(Icons.public)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
