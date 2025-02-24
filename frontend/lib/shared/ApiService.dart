import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Currency.dart';
import 'package:frontend/shared/CurrencyConvertingHelper.dart';
import 'package:http/http.dart' as http;

import 'DialogHelper.dart';

class ApiService {
  static Future<void> registerUser(String email, String password,
      String firstname, String lastname) async {
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
            'Failed to register user. Server responded with status: ${response
                .statusCode}');
      }
      await credential.user
          ?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

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

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to reset password. Server responded with status: ${response
                .statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<int> getLoginAttempts(String email) async {
    try {
      final url = Uri.parse(
          'https://getloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri
              .encodeComponent(email)}');

      final response = await http.get(url);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decodedBody = json.decode(response.body);
        if (decodedBody['loginAttempts'] != null) {
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
          'https://increaseloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri
              .encodeComponent(email)}');
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future <void> resetLoginAttempts(email) async {
    try {
      final url = Uri.parse(
          'https://resetloginattempts-icvq5uaeva-uc.a.run.app?email=${Uri
              .encodeComponent(email)}');
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  //create group

  static Future<void> createGroup(BuildContext context, String groupName) async {
    try {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse('https://groupcreate-icvq5uaeva-uc.a.run.app')
          .replace(queryParameters: {
        'idToken': idToken,
        'groupName' : groupName
      });

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to create group: ${response.body}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group created successfully!")),
      );
    } catch (e) {

      print("Error creating group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  static Future<void> joinGroup(BuildContext context, String groupCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final groupDoc = await FirebaseFirestore.instance
          .collection('groups') // Adjust this to your Firestore structure
          .where('groupCode', isEqualTo: groupCode)
          .limit(1)
          .get();

      if (groupDoc.docs.isEmpty) {
        throw Exception("Group with code $groupCode does not exist.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse('https://groupjoin-icvq5uaeva-uc.a.run.app')
          .replace(queryParameters: {
        'idToken': idToken,
        'groupCode': groupCode,
      });

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to join group: ${response.body}");
      }

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
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No user is logged in");
    } else {
      print(user.toString());
    }

    if (newPassword != confirmPassword) {
      throw Exception("The new passwords do not match.");
    }


    try {
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: "test",
      );
      print(user.email);
      print(credential.toString());

      await user.reauthenticateWithCredential(credential);
      print("Test2");
      await user.updatePassword(newPassword);
      print("test3");

      DialogHelper.showDialogCustom(
        context: context,
        title: "Confirmation",
        content: "Your password has been successfully changed.",
      );
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

  static const String deleteUserUrl =
      'https://userdelete-icvq5uaeva-uc.a.run.app';

  static Future<void> deleteUser({required BuildContext context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    print("API: current User is:" + user.toString());
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    try {
      String? idToken = await user.getIdToken();

      final uri = Uri.parse('$deleteUserUrl?idToken=$idToken');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print("User successfully deleted");
        print(response.statusCode);
        await user.delete();
        print("User successfully deleted from Firebase Authentication");


        DialogHelper.showDialogCustom(
          context: context,
          title: "User Deleted",
          content: "Your account has been successfully deleted.",
        );
      } else {
        throw Exception(
            "Failed to delete user. Server returned: ${response
                .statusCode} - ${response.body}");
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

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'request': requestBody,
      });


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


  static Future<Map<String, dynamic>> getMemberbalance(String groupId,
      String uid) async {
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


      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final balances = responseData['balances'] ?? {};
        return balances; // Return the map directly
      } else {
        print(
            "API Error - Status: ${response.statusCode}, Body: ${response
                .body}");
        throw Exception("Failed to retrieve balance: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in API call: $e");
      throw Exception("Error retrieving balances: $e");
    }
  }


  static getGroupBalance(String groupId, String uid) async {
    const String endpointURL =
        "https://getgroupbalance-icvq5uaeva-uc.a.run.app"; // Replace with your actual endpoint

    try {
      CurrencyConvertingHelper currencyConvertingHelper = new CurrencyConvertingHelper();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupId,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        Map<String, dynamic> balances = responseData['balances'] ?? {};

        balances = await currencyConvertingHelper.convertUseridBalanceMap(balances, groupId);

        double totalOwedToOthers = 0.0; // Positive balances
        double totalOwedByOthers = 0.0; // Negative balances


        balances.forEach((userId, balance) {
          if (userId == uid) {
            final double balanceValue = balance.toDouble();
            if (balanceValue < 0) {
              totalOwedByOthers += balanceValue;
            } else if (balanceValue > 0) {
              totalOwedToOthers += balanceValue;
            }
          }

         else{

           return;
          }

        });


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


  static Future<void> addPayment({
    required String groupId,
    required String? toId,
    required String fromId,
    required double amount}) async {
    const String endpointURL =
        "https://addpayment-icvq5uaeva-uc.a.run.app";

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
        'toID': toId,
        'amount': amount.toString(),
      });

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

  static Future<Map<String, dynamic>>? getRates() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }



    String? idToken = await user.getIdToken();
    print("API:  Currentuser IDTocken is:" + idToken!);

    final uri = Uri.parse(
        'https://updaterates-icvq5uaeva-uc.a.run.app?idToken=$idToken');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('currencies')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          return data;
        } else {
          throw Exception("Currencies document data is null.");
        }
      } else {
        throw Exception("Currencies document not found!");
      }
    }else{
      throw Exception("Status Code of the response " + response.statusCode.toString());
    }
  }



  static Future<void> leaveGroup({required String groupID}) async {


    const String endpointURL = "https://groupleave-icvq5uaeva-uc.a.run.app";

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupID,
      });


      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Group successfully left!");
      } else {
        print("Failed to leave Group: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error leaving Group: $e");
      rethrow;
    }
  }


  static Future<void> sendInvitation({required String email, required String groupID}) async {

    const String endpointURL = "https://sendinvitation-icvq5uaeva-uc.a.run.app";

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'email': email,
        'groupID': groupID,
      });


      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Invitation successfully send!");
      } else {
        print("Failed to send invitation: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error sending invitation: $e");
      rethrow;
    }
  }

  static Future<void> sendReminders({required String groupID}) async {

    const String endpointURL = "https://sendreminders-icvq5uaeva-uc.a.run.app";

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final idToken = await user.getIdToken();

      final url = Uri.parse(endpointURL).replace(queryParameters: {
        'idToken': idToken,
        'groupID': groupID,
      });


      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Reminders successfully set!");
      } else {
        print("Failed to set reminders: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error setting reminders: $e");
      rethrow;
    }



  }


}

