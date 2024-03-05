import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/album1.dart';
import 'package:drighna_ed_tech/screens/login_screen.dart';
import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../provider/user_data_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  //decoration
  String userName = '';
  String admissionNo = '';
  String userImage = '';
  String classSection = '';
  String studentName = '';
  String primaryColor = '';
  String secondaryColor = '';

  String device_token =
      "fxj9AGhzrYg:APA91bGdKnxmiKeK2woXsDqTLtUyL-NxqUOYqVNb383zn44fc5rEjeUqke3bGmGZqbt3k7drI0rqfxv6rJMhbIBc0T8X2iVmeyEA2UN5FJPsDwoGF9KdPkgvmPHENs3ex701R3I21EFx";

  List<String> childIdList = [];
  List<String> childNameList = [];
  List<String> childClassList = [];
  List<String> childImageList = [];

  List<Album1> communicateAlbumList = [];
  List<Album1> elearningAlbumList = [];
  List<Album1> academicAlbumList = [];
  List<Album1> otherAlbumList = [];

  @override
  void initState() {
    super.initState();

    getDatasFromApi();

    checkLoginType();
    prepareNavList();
    setUpPermissions();
    fetchStudentCurrency();
  }

  Future<void> getElearningFromApi(bodyparams) async {
    print("*************Inside Elearning method*******");
    print(bodyparams.toString());
    final prefs = await SharedPreferences.getInstance();
    // Add your headers
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getELearningUrl = Constants.getELearningUrl;
    String url = "$apiUrl$getELearningUrl";

    print("E learning url*********" + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyparams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Process your result here
        print("Modules Result for elearning****************:" +
            result.toString());

        final modulesJson = result["module_list"] as List;
        print("Modules length: ${modulesJson.length}");

        // Assuming you have a predefined list of covers like in your Android code
        List<int> covers = [
          // Add your drawable resource IDs as integers here. You'll need to use AssetImage or similar in Flutter.
          1
        ];

        // Clear the list before adding new items to avoid duplication
        elearningAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: 1,
              // For thumbnail, use AssetImage or NetworkImage based on your actual use case
            );
            elearningAlbumList.add(album);
          }
        }

        print("**********elearningList*************>>>>>>>>>>" +
            elearningAlbumList.toString());

        // Update the UI
        setState(() {});
      } else {
        // Handle server error
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching eLearning data: $e");
      // Handle network error
    }
  }

  Future<void> getCommunicateFromApi(bodyParams) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getCommunicateUrl = Constants.getCommunicateUrl;
    String url = "$apiUrl$getCommunicateUrl";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final modulesJson = result["module_list"] as List;

        List<int> covers = [
          // Adjust these according to your Flutter app's assets
          1, // For example purposes, replace with actual indices or asset references
        ];

        // Clear the list before adding new items to avoid duplication
        communicateAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail:
                  covers[i % covers.length], // Adjust indexing for covers
            );
            communicateAlbumList.add(album);
          }
        }

        setState(() {}); // Update UI
      } else {
        // Handle server error
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching communication data: $e");
      // Handle network error
    }
  }

  Future<void> fetchStudentCurrency() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> params = {
        "student_id": prefs.getString(Constants.studentId) ?? '',
      };
      print("params: ${json.encode(params)}");
      await getCurrencyDataFromApi(json.encode(params));
    } else {
      // Show toast or message indicating no internet connection
      print('No internet connection.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> isConnectingToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String?> getSharedPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void checkLoginType() async {
    bool isConnected = await isConnectingToInternet();
    if (isConnected) {
      String? loginType = await getSharedPreference(Constants.loginType);

      print("Login type>>>>>>>>>>>>>>>" + loginType.toString());

      if (loginType == "parent") {
        String? studentId = await getSharedPreference("studentId");
        String? userId = await getSharedPreference("userId");
        // Assuming getDateOfMonth is implemented and returns String

        String getDateOfMonth(DateTime date, String index) {
          DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
          DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

          if (index == "first") {
            return "${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}";
          } else {
            return "${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2, '0')}-${lastDayOfMonth.day.toString().padLeft(2, '0')}";
          }
        }

        String dateFrom = getDateOfMonth(DateTime.now(), "first");
        String dateTo = getDateOfMonth(DateTime.now(), "last");

        Map<String, String> obj = {
          "student_id": studentId ?? "",
          "date_from": dateFrom,
          "date_to": dateTo,
          "role": loginType ?? "",
          "user_id": userId ?? "",
        };

        getDataFromApi(obj);
      } else {
        //for Student
        String? studentId = await getSharedPreference("studentId");
        // String? userId = await getSharedPreference("userId");

        String getDateOfMonth(DateTime date, String index) {
          DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
          DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

          if (index == "first") {
            return "${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}";
          } else {
            return "${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2, '0')}-${lastDayOfMonth.day.toString().padLeft(2, '0')}";
          }
        }

        String dateFrom = getDateOfMonth(DateTime.now(), "first");

        String dateTo = getDateOfMonth(DateTime.now(), "last");

        Map<String, String> obj = {
          "student_id": studentId ?? "",
          "date_from": dateFrom,
          "date_to": dateTo,
          "role": loginType ?? "",
        };

        // Convert Map to String using jsonEncode and pass to getDataFromApi
        getDataFromApi(obj);
      }
    } else {
      _showSnackBar("not connected to internet");
    }
  }

  Future<void> getDatasFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the site_url from shared preferences
    String siteUrl = prefs.getString('imagesUrl') ??
        ''; // Default to empty string if not found

    Map<String, dynamic> params = {
      "site_url": siteUrl,
    };
    String bodyParams = json.encode(params); // Convert map to a JSON string

    String url = "https://sstrace.qdocs.in/postlic/verifyappjsonv2";
    final Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accesstoken") ?? ""
    };
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print("result of getDatas from Api==$result");
        if (result['status'] == "1") {
          prefs.setBool(Constants.isLoggegIn, false);
          // Your logic here
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Title"),
                content: Text(result['msg']),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Map<String, dynamic> logoutParams = {
                        "deviceToken": device_token,
                        // Add other logout parameters here as needed
                      };
                      String bodyParams = json
                          .encode(logoutParams); // Convert map to JSON string

                      loginOutApi(bodyParams);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          final prefs = await SharedPreferences.getInstance();
          String loginType = prefs.getString(Constants.loginType) ?? '';
          String id = prefs.getString("studentId") ?? '';

          if (loginType == "student") {
            Map<String, dynamic> params = {
              "id": id,
              "user_type": loginType,
            };
            checkStudentStatus(json.encode(params));
          } else {
            id = prefs.getString(Constants.parentsId) ?? "";
            Map<String, dynamic> params = {
              "id": id,
              "user_type": loginType,
            };

            checkStudentStatus(json.encode(params));
          }
        }
      } else {
        // Handle server error
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      // Handle network error
    }
  }

  Future<void> getDataFromApi(Map<String, dynamic> params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiUrl = prefs.getString('apiUrl');
    String? userId = prefs.getString('userId');
    String? accessToken = prefs.getString('accessToken');

    // Construct the full URL
    String url = "$apiUrl${Constants.getDashboardUrl}";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          "User-ID": userId ?? "",
          "Authorization": accessToken ?? "",
        },
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response if needed or handle it as a raw string
        var result = json.decode(response.body);

        // Do something with the response data
        print('Response data: $result');

        // Update shared preferences with new data
        await prefs.setString(Constants.classId, result['class_id']);
        await prefs.setString(Constants.sectionId, result['section_id']);
      } else {
        // Handle error response
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error making the request: $e');
    }
  }

  Future<void> prepareNavList() async {
    var isConnected =
        await (Connectivity().checkConnectivity()) != ConnectivityResult.none;
    if (isConnected) {
      final prefs = await SharedPreferences.getInstance();
      String? loginType = prefs.getString(Constants.loginType);
      if (loginType != null) {
        print(loginType.toString());
        var params = {'user': loginType};

        getElearningFromApi(jsonEncode(params));
        getCommunicateFromApi(jsonEncode(params));
        getAcademicsFromApi(jsonEncode(params));
        getOthersFromApi(jsonEncode(params));
      }
    } else {
      _showSnackBar("No internet connection");
    }
  }

  Future<void> getOthersFromApi(bodyParams) async {
    print("Fetching Others Modules...");
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getOthersUrl = Constants.getOthersUrl;
    String url = "$apiUrl$getOthersUrl";

    try {
      // Showing loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Text("Loading"),
              ],
            ),
          );
        },
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      // Dismiss the loading indicator
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Modules Result for others: $result");

        final modulesJson = result["module_list"] as List;
        print("Modules length: ${modulesJson.length}");

        List<int> covers = [
          1
          // Add your drawable resource IDs as integers here.
          // In Flutter, use AssetImage or similar.
        ];

        // Clear the list before adding new items to avoid duplication
        otherAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["short_code"],
              value: module["status"],
              thumbnail:
                  covers[i % covers.length], // Example handling for covers
            );
            otherAlbumList.add(album);
          }
        }

        print("Other Modules List Updated");
        setState(() {});
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      // Dismiss the loading indicator in case of an error too
      Navigator.pop(context);
      print("Error fetching other modules: $e");
    }
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
      print(">>>>>>>>>>>>>>>>>>>>" + stdId.toString());
      print(">>>>>>>>>>>>>>>>>>>>" + response.body.toString());
      print(">>>>>>>>>>>>>>>>>>>>" + url.toString());

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // final data = result['result'];

        // Save the fetched currency data to SharedPreferences
        await prefs.setString(
            Constants.currency_price, result['result']['base_price']);
        await prefs.setString(
            Constants.currency_short_name, result['result']['name']);
        await prefs.setString(Constants.currency, result['result']['symbol']);
      } else {
        print('Failed to fetch data from API');
        // Handle HTTP error
      }
    } catch (e) {
      print('An error occurred: $e');
      // Handle exceptions
    }
  }

  Future<void> setUpPermissions() async {
    // Request multiple permissions at once, now including Permission.phone.
    Map<Permission, PermissionStatus> statuses = await [
      Permission
          .storage, // Maps to Manifest.permission.READ_EXTERNAL_STORAGE and Manifest.permission.WRITE_EXTERNAL_STORAGE
      Permission.camera, // Maps to Manifest.permission.CAMERA
      Permission.microphone, // Maps to Manifest.permission.RECORD_AUDIO
      Permission.phone, // Maps to Manifest.permission.CALL_PHONE on Android
      // Add other permissions if needed.
    ].request();

    // Check if all permissions are granted.
    final isAllPermissionsGranted =
        statuses.values.every((status) => status.isGranted);

    if (!isAllPermissionsGranted) {
      // Handle the scenario when not all permissions are granted.
      print("Not all permissions granted.");
      // Implement your dialog or toast here.
    } else {
      print("All permissions granted.");
    }

    // Optionally, if you want to persist the permission status.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.permissionStatus, isAllPermissionsGranted);
  }

  Future<void> checkStudentStatus(String bodyParams) async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String checkStudentStatusUrl =
        prefs.getString('checkStudentStatusUrl') ?? '';
    String url = "$apiUrl$checkStudentStatusUrl";
    print("url==$url");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": "yourClientServiceValue",
          "Auth-Key": "yourAuthKeyValue",
          "Content-Type": "application/json",
          // Add other headers here
        },
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        String responseValue = result["response"];
        print("response=$responseValue");
        await prefs.setString("response", responseValue);

        if (prefs.getString("response") == "no") {
          await prefs.setBool("isLoggedIn", false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    const LoginScreen()), // Replace Login() with your login screen widget
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsyncValue = ref.watch(decoratorProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1EDE9),
        // leading: const Icon(Icons.menu),
        actions: const [Icon(Icons.notifications)],

        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text('Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/about');
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                // Perform logout logic, then:
                Navigator.of(context).pop(); // Close the drawer
                bool isConnected = await isConnectingToInternet();
                if (isConnected) {
                  // Perform your API logout call
                } else {
                  _showSnackBar("No internet connection");
                }
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFillRemaining(
              child: userDataAsyncValue.when(
            data: (Map<String, String> userData) {
              if (userData['studentName'] != "") {
                userName = userData['userName']!;
              } else {
                userName = userData['userName']!;
              }
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: const Color(0xFFE1EDE9),
                      height: 200,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) =>
                                          SharedPreferencesDetailsScreen()));
                            },
                            child: CircleAvatar(
                              backgroundImage: userData['userImage'] != null
                                  ? NetworkImage(userData['userImage']!)
                                  : Image.asset('assets/placeholder_user.png')
                                      as ImageProvider, // replace with your default image path
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Admission No. ${userData['admissionNo'] ?? ''} ${userData['classSection'] ?? ''}'),
                        ],
                      ),
                    ),
                    CardSection(
                      title: "eLearning",
                      listOfDataSets: elearningAlbumList,
                    ),
                    CardSection(
                        title: "Academic", listOfDataSets: academicAlbumList),
                    CardSection(
                        title: "Communication",
                        listOfDataSets: communicateAlbumList),
                    CardSection(
                        title: "Others", listOfDataSets: otherAlbumList),
                    // Add more sections as needed
                  ],
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          )),
        ],
      ),
    );
  }

  void loginOutApi(String bodyParams) {}

  Future<void> getAcademicsFromApi(bodyParams) async {
    print("Getting academics data...");
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the necessary data from shared preferences
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getAcademicsUrl =
        Constants.getAcademicsUrl; // Ensure this constant is defined
    String url = "$apiUrl$getAcademicsUrl";

    // Setup your headers
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    print("Academics URL: $url");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Modules Result for academics: $result");

        final modulesJson = result["module_list"] as List;
        print("Modules length: ${modulesJson.length}");

        // Assuming you have a predefined list of covers like in your Android code
        List<int> covers = [
          1
          // You will need to adjust this part to match your actual assets or use network images
        ];

        // Clear the list before adding new items to avoid duplication
        academicAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[i %
                  covers
                      .length], // Make sure covers list has enough elements or handle this differently
              // For thumbnail, use AssetImage, NetworkImage, or appropriate widget
            );
            academicAlbumList.add(album);
          }
        }

        print("Academic List Updated");
        setState(() {}); // Update your UI if necessary
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching academics data: $e");
    }
  }
}

class CardSection extends StatelessWidget {
  final String title;
  final List listOfDataSets;

  CardSection({required this.title, required this.listOfDataSets});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 200, // Set a fixed height for the inner content
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  childAspectRatio: 1.0, // Aspect ratio of each item
                  crossAxisSpacing: 4.0, // Spacing between items horizontally
                  mainAxisSpacing: 4.0, // Spacing between items vertically
                ),
                itemCount:
                    listOfDataSets.length, // Number of items in your list
                itemBuilder: (context, index) {
                  return Card(
                    child: Center(
                      child: Text(listOfDataSets[index].name),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}
