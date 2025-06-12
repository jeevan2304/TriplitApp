import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen>{
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _signup() async{
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if(username.isEmpty || email.isEmpty || password.isEmpty){
      _showMessage("Please fill all fields.");
      return;
    }
    if(password!= confirmPassword){
      _showMessage("Passwords do not match");
      return;
    }

    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email:email,
        password:password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email':email,
        'uid':userCredential.user!.uid,
        'createdAt':FieldValue.serverTimestamp(),


      });
      _showMessage("Signup Successful!");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()),);
    }on FirebaseAuthException catch(e){
      _showMessage(e.message??"Signup Failed");
    }
  }

  void _showMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)),);
  }

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
              Icon(Icons.travel_explore, size: 80, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text("Triplit", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),

              _buildTextField(controller: _usernameController, icon: Icons.person, hintText: "Username"),
              SizedBox(height: 15),
              _buildTextField(controller: _emailController, icon: Icons.email, hintText: "Email"),
              SizedBox(height: 15),
              _buildTextField(controller: _passwordController, icon: Icons.lock, hintText: "Password", isPassword: true),
              SizedBox(height: 15),
              _buildTextField(controller: _confirmPasswordController, icon: Icons.lock, hintText: "Confirm Password", isPassword: true),
              SizedBox(height: 25),

              _buildSignupButton(),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
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

  // Custom TextField
  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String hintText, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // Sign Up Button
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _signup,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.deepPurple,
        ),
        child: Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}