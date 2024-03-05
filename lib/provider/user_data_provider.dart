import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final decoratorProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  // Create a map and populate it with user data from SharedPreferences
  return {
    'userName': prefs.getString(Constants.userName) ?? "",
    'admissionNo': prefs.getString(Constants.admission_no) ?? "",
    'userImage': prefs.getString(Constants.userImage) ?? "",
    'classSection': prefs.getString(Constants.classSection) ?? "",
    'studentName': prefs.getString("studentName") ??
         
        "",
    'primaryColor': prefs.getString(Constants.primaryColour) ?? "",
    'secondaryColor': prefs.getString(Constants.secondaryColour) ?? "",
     

  };
  
});
