import 'package:flutter/material.dart';

class StudentFees extends StatefulWidget {
  const StudentFees({super.key});

  @override
  State<StudentFees> createState() => _StudentFeesState();
}

class _StudentFeesState extends State<StudentFees> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Student fees"),
      ),
    );
  }
}
