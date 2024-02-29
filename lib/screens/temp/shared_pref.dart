import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDetailsScreen extends StatefulWidget {
  @override
  _SharedPreferencesDetailsScreenState createState() => _SharedPreferencesDetailsScreenState();
}

class _SharedPreferencesDetailsScreenState extends State<SharedPreferencesDetailsScreen> {
  Map<String, dynamic> _sharedPrefsData = {};

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesData();
  }

  Future<void> _loadSharedPreferencesData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    for (String key in keys) {
      data[key] = prefs.get(key); // Use the get method to retrieve value by key
    }

    setState(() {
      _sharedPrefsData = data;
    });
  }

  Future<void> clearSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // This clears all the data in shared preferences.
  setState(() {
    _loadSharedPreferencesData();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SharedPreferences Data'),
        actions: [
          IconButton(onPressed: (){
            
            
              clearSharedPreferences();
            
           
          }, icon: Icon(Icons.clear))
        ],
      ),
      body: ListView(
        children: _sharedPrefsData.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
          );
        }).toList(),
      ),
    );
  }
}
