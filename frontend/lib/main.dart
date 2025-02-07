import 'package:watch_it/watch_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/FairShare.dart';
import 'Dependencies.dart';


//change
void main() async {

  initializeDependencies();

 try {
    await dotenv.load(fileName: ".env");
    print("Dotenv geladen: ${dotenv.env}");
  } catch (e) {
    print("Fehler beim Laden der .env-Datei: ${e.toString()}");
    print("Fehler beim Laden der .env-Datei: $e");

  }


  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['WEB_API_KEY']!,
        authDomain: dotenv.env['WEB_AUTH_DOMAIN']!,
        projectId: dotenv.env['WEB_PROJECT_ID']!,
        storageBucket: dotenv.env['WEB_STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['WEB_MESSAGING_SENDER_ID']!,
        appId: dotenv.env['WEB_APP_ID']!,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const FairShare());
}
