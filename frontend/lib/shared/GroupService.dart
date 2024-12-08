import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  // Fetch all groups the current user is a member of
  static Future<List<Map<String, dynamic>>> getUserGroups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final userId = user.uid; // User's unique document ID

      // Query Firestore to find groups where the user is in memberIDs
      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('memberIDs.$userId', isEqualTo: true)
          .get();

      // Parse and return the list of groups
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Use document ID as the "name"
          'data': doc.data(), // Full group data
        };
      }).toList();
    } catch (e) {
      print("Error fetching user groups: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        throw Exception("Group not found.");
      }

      // Extract the memberIDs map
      final memberIDs = groupDoc.data()?['memberIDs'] as Map<String, dynamic>?;

      if (memberIDs == null || memberIDs.isEmpty) {
        throw Exception("No members found in the group.");
      }

      // Fetch details of each member from the users collection
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
              'name': userDoc.data()?['firstName'],
              'amount': 0.0, // Placeholder for amount, can be updated later
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


}
