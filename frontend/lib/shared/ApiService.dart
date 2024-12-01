// lib/services/api_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> registerUser(
      String email,
      String password,
      String firstname,
      String lastname,
      ) async {
    try {
      // Step 1: Register user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Retrieve the Firebase ID Token
      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

      // Step 3: Send data to the API endpoint
      final url = Uri.parse(
        'https://userregistration-icvq5uaeva-uc.a.run.app'
            '?idToken=${Uri.encodeComponent(idToken)}'
            '&firstName=${Uri.encodeComponent(firstname)}'
            '&lastName=${Uri.encodeComponent(lastname)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Return success
        return;
      } else {
        throw Exception(
            'Failed to register user. Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Re-throws the caught exception
    }
  }
}
