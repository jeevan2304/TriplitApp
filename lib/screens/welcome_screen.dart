import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final String email;

  const WelcomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Welcome, $email!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
