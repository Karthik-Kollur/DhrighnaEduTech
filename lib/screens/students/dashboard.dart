import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/album1.dart';
import 'package:drighna_ed_tech/screens/login_screen.dart';
import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/screens/temp/test_profileScreen.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/dashboard_cards.dart';
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
  List<String> childAdmissionNo = [];

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
        List<String> covers = [
          'assets/ic_dashboard_homework.png',
          'assets/ic_assignment.png',
          'assets/ic_lessonplan.png',
          'assets/ic_onlineexam.png',
          'assets/ic_downloadcenter.png',
          'assets/ic_onlinecourse.png',
          'assets/ic_videocam.png',
          'assets/ic_videocam.png',
        ];

        // Clear the list before adding new items to avoid duplication
        elearningAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[i],
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

        List<String> covers = [
          'assets/ic_notice.png',
          'assets/ic_notification.png',
        ];
        // Clear the list before adding new items to avoid duplication
        communicateAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[i], // Adjust indexing for covers
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
                   

                      loginOutApi(context,logoutParams);
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
                const CircularProgressIndicator(),
                const Text("Loading"),
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

        List<String> covers = [
          'assets/ic_nav_fees.png',
          'assets/ic_leave.png',
          'assets/ic_visitors.png',
          'assets/ic_nav_transport.png',
          'assets/ic_nav_hostel.png',
          'assets/ic_dashboard_pandingtask.png',
          'assets/ic_library.png',
          'assets/ic_teacher.png',
        ];

        // Clear the list before adding new items to avoid duplication
        otherAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["short_code"],
              value: module["status"],
              thumbnail: covers[i], // Example handling for covers
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
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": Constants.contentType,
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

  void showChildList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
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
                          prefs.setString(
                              Constants.admission_no, childAdmissionNo[index]);
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
                                    "Successfully loged in parent with one of his children")),
                          );
                          ref.invalidate(
                              decoratorProvider); //trigger the provider
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (_) =>
                                  const DashboardScreen())); // Adjust as needed
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
            userDataAsyncValue.when(
              data: (Map<String, String> userData) {
                if (userData['studentName'] != "") {
                  userName = userData['userName']!;
                } else {
                  userName = userData['userName']!;
                }

                return DrawerHeader(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
        imageUrl: userData['userImage']!,
        placeholder: (context, url) =>  Image.asset(
                                'assets/placeholder_user.png',height: 55,width: 55,),
        errorWidget: (context, url, error) =>  Image.asset(
                                'assets/placeholder_user.png',height: 55,width: 55,),
        fit: BoxFit.cover,
      ),
                           SizedBox(
                              width: 20), // Space between the avatar and text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName, // Replace with your dynamic value
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color, // Use theme for color
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .fontSize, // Use theme for text size
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  userData['loginType'] == 'parent'
                                      ? Text(
                                          "Child-${userData['studentName']}", // Replace with your dynamic value
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .color, // Adjust as needed
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .fontSize, // Adjust as needed
                                          ),
                                        )
                                      : SizedBox(),
                                  Text(
                                    "${userData['classSection']}",
                                  )
                                ],
                              ),
                              // Add more Text widgets as needed for other details
                            ],
                          ),
                        ],
                      ),
                      userData['loginType'] == 'parent'
                          ? Row(
                              children: [
                                const SizedBox(
                                    width: 60 + 20), // Avatar size + margin
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Switch child", // Dynamic value or localized string
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .fontSize, // Adjust as needed
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .color, // Adjust as needed
                                          ),
                                        ),
                                        const SizedBox(width: 5),

                                        IconButton(
                                          onPressed: () async {
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            String userId =
                                                prefs.getString("userId") ?? "";

                                            // if (userId == null) {
                                            //   print("User ID is null");
                                            //   return;
                                            // }

                                            Map<String, dynamic> params = {
                                              "parent_id": userId,
                                            };

                                            // Convert params to JSON string
                                            String bodyParams =
                                                json.encode(params);
                                            print("params: $bodyParams");

                                            // Now call your function with the JSON string
                                            getStudentsListFromApi(
                                                context, bodyParams);
                                          },
                                          icon: Icon(
                                            Icons.swap_horiz, // Example icon
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color, // Use theme for icon color
                                            size: Theme.of(context)
                                                .iconTheme
                                                .size, // Use theme for icon size
                                          ),
                                        )

                                        // Space between text and icon
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox()
                      // Add more widgets as needed
                    ],
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE1EDE9),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
               leading: Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
               leading: Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx)=>ProfileScreen()));
                // Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
               leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
               leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Perform logout logic, then:

                bool isConnected = await isConnectingToInternet();
                if (isConnected) {
                  // Perform your API logout call
                  Map<String, dynamic> logoutParams = {
    "deviceToken": device_token,
  };
                  

                  // Call the Logout function with the required deviceToken
                  await loginOutApi(context, logoutParams);
                 
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
                            child:  CachedNetworkImage(
        imageUrl: userData['userImage']!,
        placeholder: (context, url) =>  Image.asset(
                                'assets/placeholder_user.png',height: 55,width: 55,),
        errorWidget: (context, url, error) =>  Image.asset(
                                'assets/placeholder_user.png',height: 55,width: 55,),
        fit: BoxFit.cover,
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
                      title: "E-Learning",
                      listOfDataSets: elearningAlbumList,
                    ),
                    CardSection(
                        title: "Academics", listOfDataSets: academicAlbumList),
                    CardSection(
                        title: "Communicate",
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

  
  Future<void> loginOutApi(BuildContext context,  logoutParams) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiUrl = prefs.getString("apiUrl") ?? "";
  String logoutUrl = apiUrl + Constants.logoutUrl; // Your logout endpoint
  Map<String, String> headers = {
    "Client-Service": Constants.clientService,
    "Auth-Key": Constants.authKey,
    "Content-Type": "application/json",
    "User-ID": prefs.getString("userId") ?? "",
    "Authorization": prefs.getString("accessToken") ?? "",
  };
  
 

  // Log the logout details as a JSON string
  print("Logout Details==${jsonEncode(logoutParams)}");

  // Step 2: Perform the logout request
  try {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: headers,
      body: jsonEncode(logoutParams),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["status"] == "1") {
        await prefs.setBool("isLoggedIn", false);
      
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to the LoginScreen
          (Route<dynamic> route) => false,
        );
      } else {
       _showSnackBar("status is 0");
      }
    } else {
      _showSnackBar("status code is not 200");
    }
  } catch (e) {
    _showSnackBar("Error occured $e");
  }
}

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
        List<String> covers = [
          'assets/ic_calender_cross.png',
          'assets/ic_lessonplan.png',
          'assets/ic_nav_attendance.png',
          'assets/ic_nav_reportcard.png',
          'assets/ic_nav_timeline.png',
          'assets/ic_documents_certificate.png',
          'assets/ic_dashboard_homework.png',
          'assets/ic_nav_reportcard.png', // Repeated if it's intentional
        ];

        // Clear the list before adding new items to avoid duplication
        academicAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[
                  i], // Make sure covers list has enough elements or handle this differently
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

  Future<void> getStudentsListFromApi(
      BuildContext context, String bodyParams) async {
    print("**********>>>>>>>>>Inside getStudentsListFromApi");
    childIdList.clear();
    childNameList.clear();
    childClassList.clear();
    childImageList.clear();
    childAdmissionNo.clear();

    // Fetch URL and headers from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? "";
    String parentsStudentsList = Constants.parent_getStudentList;
    String userId = prefs.getString('userId') ?? "";
    String accessToken = prefs.getString('accessToken') ?? "";

    // Assuming Constants are replaced with actual constants values
    String url = apiUrl + parentsStudentsList;

    print("***************>>>>>>>>>>" + url);

    Map<String, String> headers = {
      "Client-Service": Constants.clientService, // Adjust accordingly
      "Auth-Key": Constants.authKey, // Adjust accordingly
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": accessToken,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      // Navigator.pop(context); // Dismiss the loading dialog

      if (response.statusCode == 200) {
        // Parse the JSON data
        final result = json.decode(response.body);

        print("*******list of children>>>>>" + result.toString());

        List<dynamic> dataList = result['childs'];

        print("******************>>>>>>>" + dataList.toString());

        if (dataList.length != 0) {
          for (var data in dataList) {
            childIdList.add(data["id"]);
            childNameList.add("${data["firstname"]} ${data["lastname"]}");
            childClassList.add("${data["class"]}-${data["section"]}");
            childImageList.add(data["image"]);
            childAdmissionNo.add(data["admission_no"]);
          }

          print(
              "*************************>>>>>>>>>>" + childNameList.toString());

          showChildList(context);
        } else {
          _showSnackBar(result['errorMsg']);
        }
      } else {
        // Handle error
        print('Server error: ${response.body}');
      }
    } catch (e) {
      Navigator.pop(
          context); // Ensure loading dialog is dismissed in case of error
      print(e.toString());
      // Handle error
    }
  }
}


