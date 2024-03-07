import 'package:flutter/material.dart';

class GuardianDetailCard extends StatelessWidget {
  final String title;
  final String name;
  final String contact;
  final String occupation;
  final String imagePath;
  final String relation;
  final String email;
  final String address;

  const GuardianDetailCard({
    Key? key,
    required this.title,
    required this.name,
    required this.contact,
    required this.occupation,
    required this.imagePath,
    required this.relation,
    required this.email,
    required this.address

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
     margin: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Column(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(imagePath),
                ),
                Text(title)
              ],
            ),
            SizedBox(width: 56.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      
                      SizedBox(width: 5.0),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 5.0),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 5.0),
                      Text(
                        contact,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.work),
                      SizedBox(width: 5.0),
                      Text(
                        occupation,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.supervisor_account),
                      SizedBox(width: 5.0),
                      Text(
                        relation,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    
                    ],
                  ),
                    Row(
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 5.0),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    
                    ],
                  ),
                    Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 5.0),
                      Text(
                        address,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
