import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  String _firestoreMessage = 'No data yet';

  Future<void> writeTestData() async{
    await FirebaseFirestore.instance
        .collection('testCollection')
        .doc('testdoc')
        .set({'message': 'Hello from triplit app!'});


  }

  Future<void> readTestData() async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('testCollection')
        .doc('testdoc')
        .get();

    if(snapshot.exists){
      setState(() {
        _firestoreMessage=snapshot.get('message');
      });
    }else{
      setState(() {
        _firestoreMessage='No document found!';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Triplit App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Firestore Test')),
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_firestoreMessage),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () async{
                await writeTestData();
                await readTestData();
              },
                  child: const Text('Write and read firestore'),
              ),
            ],
          ),
        ),
      ),
      // home: SignupScreen(), // Set SignupScreen as the first screen
    );
  }
}
