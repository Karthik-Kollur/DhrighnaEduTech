import 'dart:convert';

import 'package:drighna_ed_tech/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Change ProfileScreen to extend ConsumerStatefulWidget
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

// Create a ConsumerState class for ProfileScreen
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the student profile when the widget is initialized
    fetchData();
  }

  fetchData() async {
    final prefs = await SharedPreferences.getInstance();
String apiUrl=prefs.getString("apiUrl")??"";
    final body = jsonEncode({
     "student_id": prefs.getString("studentId"),
    });
    ref.read(studentProfileProvider.notifier).fetchStudentProfile(
        apiUrl, body);
  }

  @override
  Widget build(BuildContext context) {
    final studentProfile = ref.watch(studentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Student Profile')),
      body: studentProfile != null
          ? ListView(
              // Your ListView content goes here
              children: [
                Text('Name: ${studentProfile.name}'),
                 Text('class: ${studentProfile.classInfo}'),
                  Text('roll no: ${studentProfile.rollNo}'),
                   Text('admission no: ${studentProfile.admissionNo}'),
                    Text('bar code: ${studentProfile.barcodeUrl}'),
                     Text('behaviour score: ${studentProfile.behaviourScore}'),
                      Text('admission date: ${studentProfile.admissionDate}'),
                       Text('dob: ${studentProfile.dob}'),
                // More widgets displaying profile data...
              ],
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show loading spinner while fetching data
    );
  }
}
