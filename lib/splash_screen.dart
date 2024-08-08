import 'package:flutter/material.dart';
import 'get_started_page.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetStartedPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark grey background
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
              'C:/Users/VINEETH/Desktop/internship project/5234602.png'),
        ),
      ),
    );
  }
}
