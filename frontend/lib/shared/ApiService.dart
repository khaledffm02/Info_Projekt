import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  static Future<void> createTransaction(String requestBody) async {
    const String endpointURL = "https://createtransaction-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

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


  static Future<void> confirmTransaction({required String transactionId, required String groupId}) async {
    const String endpointURL = "https://confirmtransaction-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

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
        'transactionID': transactionId,
      });

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

    static Future<void> addPayment({
      //required String transactionId,
      required String groupId,
      required String? toId,
      required String fromId,
      required double amount
    }) async {
      const String endpointURL = "https://addpayment-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

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

  static getGroupBalance(String groupId, String uid) async {
    const String endpointURL = "https://getgroupbalance-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

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

/*
   static getMemberbalance(String groupId, String uid) async {


      const String endpointURL = "https://getgroupbalance-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

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

        print(url);


        if (response.statusCode == 200) {

          // Parse the response body
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          // Extract the "balances" map
          final HashSet<Map<String, dynamic>> balances = responseData['balances'] ?? {};


          // Return the calculated balances
          return {
            balances
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

  */


  static Future<Map<String, dynamic>> getMemberbalance(String groupId, String uid) async {
    const String endpointURL = "https://getgroupbalance-icvq5uaeva-uc.a.run.app";

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
        print("API Error - Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to retrieve balance: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in API call: $e");
      throw Exception("Error retrieving balances: $e");
    }
  }











}


