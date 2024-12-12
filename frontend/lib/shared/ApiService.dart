import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/start/Dashboard.dart';
import 'package:http/http.dart' as http;

import 'DialogHelper.dart';

class ApiService {
  static Future<void> registerUser(String email, String password,
      String firstname, String lastname) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

      final url = Uri.parse(
        'https://userregistration-icvq5uaeva-uc.a.run.app'
            '?idToken=${Uri.encodeComponent(idToken)}'
            '&firstName=${Uri.encodeComponent(firstname)}'
            '&lastName=${Uri.encodeComponent(lastname)}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to register user. Server responded with status: ${response
                .statusCode}');
      }
      await credential.user
          ?.sendEmailVerification(); //Trigger for verification Email for registration

    } catch (e) {
      rethrow;
    }
  }

  static Future<void> loginUser(String email, String password) async {
    try {
      // Step 1: Sign in user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Step 2: Retrieve the Firebase ID Token
      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

      // Step 3: Send ID Token to the login API endpoint
      final url = Uri.parse(
        'https://userlogin-icvq5uaeva-uc.a.run.app'
            '?idToken=${Uri.encodeComponent(idToken)}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to log in user. Server responded with status: ${response
                .statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }


  static Future<bool> resetPassword(String email) async {
    try {
      // Endpoint-URL
      final url = Uri.parse(
        'https://sendnewpassword-icvq5uaeva-uc.a.run.app'
            '?email=${Uri.encodeComponent(email)}',
      );

      // Sende die Anfrage
      final response = await http.get(url);

      // Überprüfe den Status der Antwort
      if (response.statusCode == 200) {
        return true; // Erfolg
      } else {
        throw Exception(
            'Failed to reset password. Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return false; // Rückgabe false bei Fehler
    }
  }


  static Future<void> createGroup(BuildContext context) async {
    try {
      // Get the current user from Firebase Authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Get the ID token from the current user
      final idToken = await user.getIdToken();

      // Build the API request URL with the idToken as a query parameter
      final url = Uri.parse('https://groupcreate-icvq5uaeva-uc.a.run.app')
          .replace(queryParameters: {
        'idToken': idToken,
      });

      // Make the API call
      final response = await http.get(url);

      // Check if the response indicates success
      if (response.statusCode != 200) {
        throw Exception("Failed to create group: ${response.body}");
      }

      // Notify the user about the successful group creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group created successfully!")),
      );
    } catch (e) {
      // Log and notify the user of the error
      print("Error creating group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  static Future<void> joinGroup(BuildContext context, String groupCode) async {
    try {
      // Get the current user from Firebase Authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Check if the groupCode exists in Firestore
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups') // Adjust this to your Firestore structure
          .where('groupCode', isEqualTo: groupCode)
          .limit(1)
          .get();

      if (groupDoc.docs.isEmpty) {
        throw Exception("Group with code $groupCode does not exist.");
      }




      // Get the ID token from the current user
      final idToken = await user.getIdToken();

      // Build the API request URL with the idToken as a query parameter
      final url = Uri.parse('https://groupjoin-icvq5uaeva-uc.a.run.app')
          .replace(queryParameters: {
        'idToken': idToken,
        'groupCode': groupCode,
      });

      // Make the API call
      final response = await http.get(url);

      // Check if the response indicates success
      if (response.statusCode != 200) {
        throw Exception("Failed to join group: ${response.body}");
      }

      // Notify the user about the successful group creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group joined successfully!")),
      );
    } catch (e) {
      rethrow;
    }
  }

// Method for Re-Authentication
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    // Hole den aktuellen Benutzer
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No user is logged in");
    }else{
      print(user.toString());
    }

    // Überprüfen, ob die Passwörter übereinstimmen
    if (newPassword != confirmPassword) {
      throw Exception("The new passwords do not match.");
    }

    // Validierung des neuen Passworts
/*    final errorMessage = Validator.validatePassword(newPassword);
    if (errorMessage != null) {
      throw Exception("Error: $errorMessage");
    }
*/
    try {
      // Erstelle die Anmeldeinformationen (Credential)
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: "test",
      );
      print(user.email);
      print(credential.toString());

      // Re-Authentifizierung
      await user.reauthenticateWithCredential(credential);
      print("Test2");
      // Passwort aktualisieren
      await user.updatePassword(newPassword);
      print("test3");
      // Erfolgsmeldung zurückgeben
      DialogHelper.showDialogCustom(
        context: context,
        title: "Confirmation",
        content: "Your password has been successfully changed.",
      );
    } catch (e) {
      // Fehler werfen
      throw Exception("Failed to change password: $e");
    }
  }

  static const String deleteUserUrl = 'https://userdelete-icvq5uaeva-uc.a.run.app';

  /// Methode zur Benutzerlöschung (GET-Request)
  static Future<void> deleteUser({required BuildContext context}) async {
    // Hole den aktuellen Benutzer
    User? user = FirebaseAuth.instance.currentUser;
    print("API: current User is:"+ user.toString());
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    try {
      // ID-Token des Benutzers abrufen
      String? idToken = await user.getIdToken();
      print("API:  Currentuser IDTocken is:" + idToken!);
      // GET-Request senden (idToken als Query-Parameter)
      final uri = Uri.parse('$deleteUserUrl?idToken=$idToken');
      final response = await http.get(uri);

      // Überprüfe die Antwort
      if (response.statusCode == 200) {
        print("User successfully deleted");
        print(response.statusCode);
        await user.delete();
        print("User successfully deleted from Firebase Authentication");

        // Optional: Benutzer aus Firebase abmelden


        // Bestätigung anzeigen
        DialogHelper.showDialogCustom(
          context: context,
          title: "User Deleted",
          content: "Your account has been successfully deleted.",
        );
      } else {
        // Fehlerbehandlung bei nicht erfolgreicher Antwort
        throw Exception("Failed to delete user. Server returned: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Failed to delete user: $e");
    }
  }
}


