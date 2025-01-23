import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DialogHelper.dart';

class ApiService {
  static Future<void> registerUser(
      String email, String password, String firstname, String lastname) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final idToken = await credential.user?.getIdToken() ?? '';
      print(idToken);

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
            'Failed to register user. Server responded with status: ${response.statusCode}');
      }
      await credential.user
          ?.sendEmailVerification(); //Trigger for verification Email for registration
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    try {
      // Step 1: Sign in user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Step 2: Retrieve the Firebase ID Token
      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }
      print(idToken);

      // Step 3: Send ID Token to the login API endpoint
      final url = Uri.parse(
        'https://userlogin-icvq5uaeva-uc.a.run.app'
        '?idToken=${Uri.encodeComponent(idToken)}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
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

  static Future<int> getLoginAttempts(String email) async {
    try {
      // Construct the URL with the email parameter
      final url = Uri.parse(
          'https://getloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri.encodeComponent(email)}');

      // Perform the GET request
      final response = await http.get(url);

      // Print the response details for debugging
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Check if the response is successful
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // Decode the response and directly access "attempts"
        final decodedBody = json.decode(response.body);
        if (decodedBody['loginAttempts'] != null) {
          //   print("Rückgabewert: Api" + decodedBody['loginAttempts']);
          return int.parse(decodedBody['loginAttempts'].toString());
        } else {
          print('Key "attempts" not found in the response');
          return -1;
        }
      } else {
        print('Error: Response is empty or status code is not 200');
        return -1;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return -1;
    }
  }

  static Future<int?> increaseLoginAttempts(email) async {
    try {
      final url = Uri.parse(
          'https://increaseloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri.encodeComponent(email)}');
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  static void resetLoginAttempts(email) async {
    try {
      final url = Uri.parse(
          'https://resetloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri.encodeComponent(email)}');
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
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
    } else {
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

  static const String deleteUserUrl =
      'https://userdelete-icvq5uaeva-uc.a.run.app';

  /// Methode zur Benutzerlöschung (GET-Request)
  static Future<void> deleteUser({required BuildContext context}) async {
    // Hole den aktuellen Benutzer
    User? user = FirebaseAuth.instance.currentUser;
    print("API: current User is:" + user.toString());
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
        throw Exception(
            "Failed to delete user. Server returned: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Failed to delete user: $e");
    }
  }

  static Future<void> confirmTransaction(
      {required String transactionId, required String groupId}) async {
    const String endpointURL =
        "https://confirmtransaction-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Get the ID token from the current user
      final idToken = await user.getIdToken();

      print("\n\n");
      print(idToken);
      print("\n\n");

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupId,
        'transactionID': transactionId,
      });

      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Transaction successfully confirmed!");
      } else {
        print("Failed to confirm transaction: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error confirming transaction: $e");
      rethrow;
    }
  }

  static Future<void> createTransaction(String requestBody) async {
    const String endpointURL =
        "https://createtransaction-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Get the ID token from the current user
      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'request': requestBody,
      });

      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Transaction successfully stored!");
      } else {
        print("Failed to store transaction: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error sending transaction: $e");
      rethrow;
    }
  }

  // get memberbalance

  static Future<Map<String, dynamic>> getMemberbalance(
      String groupId, String uid) async {
    const String endpointURL =
        "https://getgroupbalance-icvq5uaeva-uc.a.run.app";

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();
      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupId,
      });

      print("Fetching balances...");
      print("URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final balances = responseData['balances'] ?? {};
        return balances; // Return the map directly
      } else {
        print(
            "API Error - Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to retrieve balance: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in API call: $e");
      throw Exception("Error retrieving balances: $e");
    }
  }

  // get groupbalance

  static getGroupBalance(String groupId, String uid) async {
    const String endpointURL =
        "https://getgroupbalance-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Get the ID token from the current user
      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupId,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the "balances" map
        final Map<String, dynamic> balances = responseData['balances'] ?? {};

        double totalOwedToOthers = 0.0; // Positive balances
        double totalOwedByOthers = 0.0; // Negative balances

        balances.forEach((userId, balance) {
          if (userId == uid) {
            // Skip the user's own ID
            return;
          }

          final double balanceValue = balance.toDouble();

          if (balanceValue < 0) {
            totalOwedToOthers += balanceValue;
          } else if (balanceValue > 0) {
            totalOwedByOthers += balanceValue;
          }
        });

        print(
            "Processed group balance for $groupId: Owed to others: $totalOwedToOthers, Owed by others: $totalOwedByOthers");

        // Return the calculated balances
        return {
          'owedToOthers': totalOwedToOthers,
          'owedByOthers': totalOwedByOthers,
        };
      } else {
        print("Failed to retrieve balance : ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error retrieving balance: $e");
      rethrow;
    }
  }

  // add payment

  static Future<void> addPayment(
      {
      //required String transactionId,
      required String groupId,
      required String? toId,
      required String fromId,
      required double amount}) async {
    const String endpointURL =
        "https://addpayment-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'groupId': groupId,
        'idToken': idToken,
        'fromID': fromId,
        //'transactionId': transactionId,
        'toID': toId, // Include toId in the query parameters
        'amount': amount.toString(), // Convert amount to string
      });

      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Payment successfully added!");
      } else {
        print("Failed to add payment: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error adding payment: $e");
      rethrow;
    }
  }
}
