
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/StartScreen.dart';
import 'package:frontend/FairShare.dart';


//change
void main() async {
 /* try {
    await dotenv.load(fileName: "asset/.env");
    print("Dotenv geladen: ${dotenv.env}");
  } catch (e) {
    print("Fehler beim Laden der .env-Datei: ${e.toString()}");
    print("Fehler beim Laden der .env-Datei: $e");

  }
  */


  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAocdxKkpHf2hDQ4QlZtT_2HKU-ThEspUI",

          authDomain: "projekt-24-a9104.firebaseapp.com",

          projectId: "projekt-24-a9104",

          storageBucket: "projekt-24-a9104.firebasestorage.app",

          messagingSenderId: "351644604797",

          appId: "1:351644604797:web:2279767fbcdab70688d414"

      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const FairShare());
}
