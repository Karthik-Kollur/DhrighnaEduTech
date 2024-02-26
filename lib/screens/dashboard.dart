import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userName = "";

  @override
  void initState() {
    super.initState();
    getStringData(); // Call getStringData() here
  }

  Future<void> getStringData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString(Constants.userName) ?? 'Default User'; // Use a fallback value
      print(userName); // Print the retrieved string value
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu),
          actions: const [Icon(Icons.notifications)],
        ),
        drawer: const Drawer(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: const Color(0xFFE1EDE9),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 40.0,
                        backgroundImage: AssetImage('assets/placeholder_user.png'), // Handle your image
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      const Text(
                        'Admission No. 1800 Class 1-A',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SharedPreferencesDetailsScreen()),
                          );
                        },
                        child: const Text("go to shared prefs"),
                      ),
                    ],
                  ),
                ),
              ),
              CardSection(), // Assuming CardSection doesn't have an Expanded that causes issues
            ],
          ),
        ),
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text(
          'Recently Used',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
        // Add more widgets as per your need
      ),
    );
  }
}
