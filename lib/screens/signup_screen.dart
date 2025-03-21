import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo or Icon
              Icon(Icons.travel_explore, size: 80, color: Colors.deepPurple),
              SizedBox(height: 10),

              Text(
                "Triplit",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 30),

              // Username Field
              _buildTextField(icon: Icons.person, hintText: "Username"),
              SizedBox(height: 15),

              // Email Field
              _buildTextField(icon: Icons.email, hintText: "Email"),
              SizedBox(height: 15),

              // Password Field
              _buildTextField(icon: Icons.lock, hintText: "Password", isPassword: true),
              SizedBox(height: 15),

              // Confirm Password Field
              _buildTextField(icon: Icons.lock, hintText: "Confirm Password", isPassword: true),
              SizedBox(height: 25),

              // Sign Up Button
              _buildSignupButton(),

              SizedBox(height: 20),

              // Already have an account? Log in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    child: Text("Log in", style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField({required IconData icon, required String hintText, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Custom Sign Up Button
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.deepPurple,
        ),
        child: Text(
          "Sign Up",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
