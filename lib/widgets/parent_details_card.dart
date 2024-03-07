import 'package:flutter/material.dart';

class ParentDetailCard extends StatelessWidget {
  final String title;
  final String name;
  final String contact;
  final String occupation;
  final String imagePath;

  const ParentDetailCard({
    Key? key,
    required this.title,
    required this.name,
    required this.contact,
    required this.occupation,
    required this.imagePath,
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
                  backgroundImage: NetworkImage(imagePath),//has to be concatinated with domain url
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
                      Icon(Icons.person),
                      SizedBox(width: 5,),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                 Row(
                   children: [
                        Icon(Icons.phone),
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
                       Text(
                        occupation,
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
