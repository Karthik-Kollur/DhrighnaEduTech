import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileDetails extends ConsumerStatefulWidget {
  @override
  _StudentProfileDetailsState createState() => _StudentProfileDetailsState();
}

class _StudentProfileDetailsState extends ConsumerState<StudentProfileDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    prepareData();
  }

  Future<bool> isConnectingToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProfile = ref.watch(studentProfileProvider);
    final studentImage =
        "https://phpstack-1193026-4203367.cloudwaysapps.com/${studentProfile!.imgUrl}";
    final barcodeImage =
        "https://phpstack-1193026-4203367.cloudwaysapps.com${studentProfile.barcodeUrl}";

    print(studentImage);
    print(barcodeImage);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: studentProfile != null
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentProfile.name,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(studentProfile.classInfo),
                            Text("Adm. No.  " + studentProfile.admissionNo),
                            Text("Roll Number  " + studentProfile.rollNo),
                            CachedNetworkImage(
                              imageUrl: barcodeImage,
                              placeholder: (context, url) => Row(
                                children: [
                                  Text("Barcode"),
                                  // CircularProgressIndicator(),
                                ],
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: studentImage,
                            placeholder: (context, url) => CircleAvatar(
                              radius: 35,
                              child: Image.asset("assets/placeholder_user.png"),
                            ),
                            errorWidget: (context, url, error) =>
                                Image.asset(
                                'assets/placeholder_user.png',height: 55,width: 55,),
                            fit: BoxFit.cover,
                          ),
                          Text('Behaviour Score : ' +
                              (studentProfile.behaviourScore ?? 'N/A')),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  // automaticIndicatorColorAdjustment: true,
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'PERSONAL'),
                    Tab(text: 'PARENTS'),
                    Tab(text: 'OTHER'),
                  ],
                ),
                Expanded(
                    child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(
                      children: [
                        ListTile(
                          leading: Text("title"),
                          trailing: Text("value"),
                        ),

                        // Add more list items...
                      ],
                    ),
                    Center(child: Text("Parents Details")),
                    Center(child: Text("Other Details")),
                  ],
                ))
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  void prepareData() async {
    if (await isConnectingToInternet()) {
      final prefs = await SharedPreferences.getInstance();
      String apiUrl = prefs.getString("apiUrl") ?? "";
      final body = jsonEncode({
        "student_id": prefs.getString("studentId"),
      });
      ref
          .read(studentProfileProvider.notifier)
          .fetchStudentProfile(apiUrl, body);
    } else {
      print("No internet connection");
    }
  }
}
