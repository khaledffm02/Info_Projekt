import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ApiService.dart';

class GroupService {
  static Future<List<Map<String, dynamic>>> getUserGroups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final userId = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('memberIDs.$userId', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'data': doc.data(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching user groups: $e");
      return [];
    }
  }

  static Future<Map<String, double>> calculateTotalBalanceForUser() async {
    try {

      final userGroups = await getUserGroups();

      final groupIds =
          userGroups.map((group) => group['id'] as String).toList();

      double totalOwedToOthers = 0.0;
      double totalOwedByOthers = 0.0;

      for (String groupId in groupIds) {
        final balances = await ApiService.getGroupBalance(
            groupId, FirebaseAuth.instance.currentUser!.uid);
        totalOwedToOthers += balances['owedToOthers']!;
        totalOwedByOthers += balances['owedByOthers']!;
      }

      return {
        'totalOwedToOthers': totalOwedToOthers,
        'totalOwedByOthers': totalOwedByOthers,
      };
    } catch (e) {
      print("Error calculating total balance: $e");
      throw Exception("Failed to calculate total balance.");
    }
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(
      String groupId) async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        throw Exception("Group not found.");
      }

      final memberIDs = groupDoc.data()?['memberIDs'] as Map<String, dynamic>?;

      if (memberIDs == null || memberIDs.isEmpty) {
        throw Exception("No members found in the group.");
      }

      List<Map<String, dynamic>> members = [];
      for (String userId in memberIDs.keys) {
        if (memberIDs[userId] == true) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            members.add({
              'id': userId,
              'name': userDoc.data()?['firstName'] ?? "deleted user",
              'amount': 0.0, // Placeholder for amount
            });
          } else {
            members.add({
              'id': userId,
              'name':  "deleted user",
              'amount': 0.0, // Placeholder for amount
            });
          }
        }
      }

      return members;
    } catch (e) {
      print("Error fetching group members: $e");
      throw Exception("Failed to fetch group members.");
    }
  }

  static Future<List<Map<String, dynamic>>> getOwnTransactions(
      String groupId) async {
    try {

      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (currentUserId.isEmpty) {
        throw Exception("User not authenticated");
      }

      final CollectionReference groupRef =
          FirebaseFirestore.instance.collection('groups');

      final DocumentSnapshot groupSnapshot = await groupRef.doc(groupId).get();

      if (!groupSnapshot.exists) {
        throw Exception("Group not found");
      }

      final Map<String, dynamic> transactions = groupSnapshot['transactions'];

      if (transactions.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> ownTransactions = [];

      for (var transactionId in transactions.keys) {
        final transactionData = transactions[transactionId];

        if (transactionData['user']['userID'] == currentUserId) {
          final friends = transactionData['friends'];

          final creatorName =
              await _getUserName(transactionData['user']['userID']);

          final friendsWithNames = await _getFriendsOwe(friends);

          ownTransactions.add({
            'id': transactionId,
            'title': transactionData['meta']['title'],
            'category': transactionData['meta']['category'],
            'storageURL': transactionData['meta']['storageURL'],
            'timestamp': transactionData['meta']['timestamp'],
            'friends': friendsWithNames,
            'creatorName': creatorName,
            'creatorID': transactionData['user']['userID'],
            'totalAmount': transactionData['user']['value'],
          });
        }
      }

      return ownTransactions;
    } catch (e) {
      print("Error fetching transactions: $e");
      throw Exception("Failed to fetch transactions: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getOtherTransactions(
      String groupId) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        throw Exception("User not authenticated");
      }

      final CollectionReference groupRef =
          FirebaseFirestore.instance.collection('groups');
      final DocumentSnapshot groupSnapshot = await groupRef.doc(groupId).get();

      if (!groupSnapshot.exists) {
        throw Exception("Group not found");
      }

      final Map<String, dynamic> transactions = groupSnapshot['transactions'];

      if (transactions.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> otherTransactions = [];

      for (var transactionId in transactions.keys) {
        final transactionData = transactions[transactionId];
        final String creatorId = transactionData['user']['userID'];
        final Map<String, dynamic> friends = transactionData['friends'] ?? {};

        if (creatorId != currentUserId) {
          bool isInvolved = friends.containsKey(currentUserId);
          String involvementStatus = isInvolved ? "involved" : "uninvolved";

          final creatorName = await _getUserName(creatorId);

          final friendsWithNames = await _getFriendsOwe(friends); // Now async

          otherTransactions.add({
            'id': transactionId,
            'title': transactionData['meta']['title'],
            'category': transactionData['meta']['category'],
            'storageURL': transactionData['meta']['storageURL'],
            'timestamp': transactionData['meta']['timestamp'],
            'creatorName': creatorName,
            'creatorID': creatorId,
            'totalAmount': transactionData['user']['value'],
            'friends': friendsWithNames,
            'involvementStatus': involvementStatus,
          });
        }
      }

      return otherTransactions;
    } catch (e) {
      print("Error fetching other transactions: $e");
      throw Exception("Failed to fetch other transactions: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> _getFriendsOwe(
      Map<String, dynamic> friends) async {
    List<Map<String, dynamic>> friendsOweList = [];

    for (var friendId in friends.keys) {
      final friendData = friends[friendId];

      final friendName = await _getUserName(friendId);

      friendsOweList.add({
        'friendId': friendId,
        'name': friendName,
        'amountOwed': friendData['value'],
        'isConfirmed': friendData['isConfirmed'],
      });
    }

    return friendsOweList;
  }

  static Future<String> _getUserName(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['firstName'] ??
            'Unknown'; // Return the first name, default to 'Unknown' if not found
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching firstname for userId $userId : $e");
      return 'Unknown'; // Return 'Unknown' in case of error
    }
  }
}
