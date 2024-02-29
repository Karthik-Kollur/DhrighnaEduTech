import 'package:drighna_ed_tech/screens/temp/shared_pref.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = Constants.userName;
  String admissionNumber=Constants.admission_no;
  String userImage=Constants.userImage;
  // String classId=Constants.classId;
  String classSection=Constants.classSection;

  @override
  void initState() {
    super.initState();
    getStringData(); // Call getStringData() here
  }

  Future<void> getStringData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString(Constants.userName) ??
          'No username saved locally'; // Use a fallback value
admissionNumber=prefs.getString(Constants.admission_no)??Constants.admission_no;
userImage=prefs.getString(Constants.userImage) ?? 'No userImage saved locally';
classSection=prefs.getString(Constants.classSection)?? 'No classsection saved locally';
// classId=prefs.getString(Constants.classId)?? ' No classsection saved locally';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: const [Icon(Icons.notifications)],
      ),
      drawer: const Drawer(),
      body: ListView(
        children: [
          Container(
            color: const Color(0xFFE1EDE9),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                      
                        backgroundImage: NetworkImage(userImage.toString()),
                      ),
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                      Text('Admission No. $admissionNumber  $classSection'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>SharedPreferencesDetailsScreen()));}, child: const Text("View shared")),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: DashboardSectionCard(title: 'E-Learning')), // Custom widget for section title
          // Repeat DashboardSectionCard for each section
        ],
      ),
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  final String title;

  DashboardSectionCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
     color:Colors.white,
      elevation: 10.0, // Adjust the elevation for desired shadow intensity
      margin: const EdgeInsets.symmetric(horizontal: 15.0), // Margin around the card
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          DashboardGrid(), // Custom widget for the grid of icons
        ],
      ),
    );
  }
}




class DashboardGrid extends StatelessWidget {

List<IconDataItem> iconDataItems = [
  IconDataItem(icon: Icons.school, label: 'Homework'),
  IconDataItem(icon: Icons.book, label: 'Daily\nAssigne'),
  IconDataItem(icon: Icons.computer, label: 'Lesson Plan'),
IconDataItem(icon: Icons.science, label: 'online Examination'),
IconDataItem(icon: Icons.calculate, label: 'Download Center'),
IconDataItem(icon: Icons.history_edu, label: 'Online Course'),
IconDataItem(icon: Icons.sports_cricket, label: 'Zoom Live Classes'),
IconDataItem(icon: Icons.palette, label: 'Gmeet Live classes'),

 
];



  @override
  Widget build(BuildContext context) {
    // Assuming 4 icons per row
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
      itemCount: iconDataItems.length, // Number of icons
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return  IconTile(
          iconData: iconDataItems[index].icon,
          label: iconDataItems[index].label,
        ); // Custom widget for each icon tile
      },
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData iconData;
  final String label;

  IconTile({required this.iconData, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle your onTap here
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(iconData), // Use the icon data passed in
          Text(label), // Use the label passed in
        ],
      ),
    );
  }
}


class IconDataItem {
  final IconData icon;
  final String label;

  IconDataItem({required this.icon, required this.label});
}

