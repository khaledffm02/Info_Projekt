import 'package:flutter/material.dart';

void main() async{


 WidgetsFlutterBinding.ensureInitialized();
 
 if(kIsWeb){await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyAocdxKkpHf2hDQ4QlZtT_2HKU-ThEspUI",
  authDomain: "projekt-24-a9104.firebaseapp.com",
  projectId: "projekt-24-a9104",
  storageBucket: "projekt-24-a9104.firebasestorage.app",
  messagingSenderId: "351644604797",
  appId: "1:351644604797:web:2279767fbcdab70688d414"));
} else{
  await Firebase.initializeApp();
}
  
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: const Center(
            child: Text(
              "Hallo World",
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
          ),
        ),
      ),
    ),
  );
}
