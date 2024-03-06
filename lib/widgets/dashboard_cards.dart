
import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final String title;
  final List listOfDataSets;

  CardSection({required this.title, required this.listOfDataSets});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 200, // Set a fixed height for the inner content
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  childAspectRatio: 1.0, // Aspect ratio of each item
                  crossAxisSpacing: 4.0, // Spacing between items horizontally
                  mainAxisSpacing: 4.0, // Spacing between items vertically
                ),
                itemCount:
                    listOfDataSets.length, // Number of items in your list
                itemBuilder: (context, index) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          listOfDataSets[index].thumbnail,
                          height: 35,
                          width: 35,
                        ),
                        Text(
                          listOfDataSets[index].name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}