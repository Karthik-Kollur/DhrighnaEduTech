import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/provider/user_data_provider.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/gaurdian_details.dart';
import 'package:drighna_ed_tech/widgets/parent_details_card.dart';
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
  String userName = "";
  String domainUrl = "";

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

    final studentImage = "$domainUrl${studentProfile?.imgUrl}";
    final barcodeImage = "$domainUrl${studentProfile?.barcodeUrl}";
    List<ListTile> studentPersonalDetails = [];
    List<ParentDetailCard> studentParentDetails = [];
   List<ListTile> studentOtherDetails = [];

    if (studentProfile != null) {
      studentPersonalDetails = [
        ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("Admission Date"),
          trailing: Text(studentProfile.admissionDate.toString()),
        ),
        ListTile(
          leading: Text("Date Of Birth"),
          trailing: Text(studentProfile.dob.toString()),
        ),
        ListTile(
          leading: Text("Gender"),
          trailing: Text(studentProfile.gender.toString()),
        ),
        ListTile(
          leading: Text("Category"),
          trailing: Text(studentProfile.category.toString()),
        ),
        ListTile(
          leading: Text("Mobile Number"),
          trailing: Text(studentProfile.mobileNo.toString()),
        ),
        ListTile(
          leading: Text("Caste"),
          trailing: Text(studentProfile.cast.toString()),
        ),
        ListTile(
          leading: Text("Religion"),
          trailing: Text(studentProfile.religion.toString()),
        ),
        ListTile(
          leading: Text("Email"),
          trailing: Text(studentProfile.email.toString()),
        ),
        ListTile(
          leading: Text("Current Address"),
          trailing: Text(studentProfile.currentAddress.toString()),
        ),
        ListTile(
          leading: Text("Permanent Address"),
          trailing: Text(studentProfile.permanentAddress.toString()),
        ),
        ListTile(
          leading: Text("Blood Group"),
          trailing: Text(studentProfile.bloodGroup.toString()),
        ),
        ListTile(
          leading: Text("Height"),
          trailing: Text(studentProfile.height.toString()),
        ),
        ListTile(
          leading: Text("Weight"),
          trailing: Text(studentProfile.weight.toString()),
        ),
        ListTile(
          leading: Text("Note"),
          trailing: Text(studentProfile.note.toString()),
        ),
        ListTile(
          leading: Text("Medical History"),
          trailing: Text(
              "Ear Infections"), // Assuming this is a static value as it's not present in your model
        ),
        // Add any other ListTiles you need for other attributes
      ];
      studentParentDetails = [
        ParentDetailCard(
          title: 'Father',
          name: studentProfile.fatherName.toString(),
          contact: studentProfile.fatherPhone.toString(),
          occupation: studentProfile.fatherOccupation.toString(),
          imagePath: studentProfile.fatherPic.toString(),
        ),
        ParentDetailCard(
          title: 'Mother',
          name: studentProfile.motherName.toString(),
          contact: studentProfile.motherPhone.toString(),
          occupation: studentProfile.motherOccupation.toString(),
          imagePath: studentProfile.motherPic.toString(),
        ),
      ];
   studentOtherDetails=[
      ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("Previous School"),
          trailing: Text(studentProfile.previousSchool.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("National ID Number"),
          trailing: Text(studentProfile.adharNo.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("Local ID Number"),
          trailing: Text(studentProfile.samagraId.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("Bank Account Number"),
          trailing: Text(studentProfile.bankAccountNo.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("Bank Name"),
          trailing: Text(studentProfile.bankName.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("IFSC Code"),
          trailing: Text(studentProfile.ifscCode.toString()),
        ),
         ListTile(
          dense: true, // makes the ListTile more compact

          leading: Text("RTE"),
          trailing: Text(studentProfile.rte.toString()),
        ),

   ];
   
    }
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
                            Text(userName,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(studentProfile.classInfo),
                            Text("Adm. No.  " + studentProfile.admissionNo),
                            Text("Roll Number  " + studentProfile.rollNo),
                            Row(
                              children: [
                                Text("Barcode"),
                                SizedBox(
                                  width: 5,
                                ),
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
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/placeholder_user.png',
                              height: 55,
                              width: 55,
                            ),
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
                      children: [...studentPersonalDetails],
                    ),
                    ListView(
                      children: [
                        ...studentParentDetails,
                        GuardianDetailCard(
                          title: 'Guardian',
                          name: studentProfile.guardianName.toString(),
                          contact: studentProfile.guardianPhone.toString(),
                          occupation:
                              studentProfile.guardianOccupation.toString(),
                          imagePath: studentProfile.guardianPic.toString(),
                          relation: studentProfile.guardianRelation.toString(),
                          email: studentProfile.guardianEmail.toString(),
                          address: studentProfile.guardianEmail.toString(),
                        ),
                      ],
                    ),
                      ListView(
                      children: [...studentOtherDetails],
                    ),
                    
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

      userName = prefs.getString(Constants.userName) ?? "";
      domainUrl = prefs.getString(Constants.appDomain) ?? "";
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
