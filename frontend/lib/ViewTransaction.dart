import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';

class ViewTransaction extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Creator;
  final groupId;

  const ViewTransaction({
    super.key,
    required this.transaction,
    required this.Creator,
    required this.groupId,
  });

  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  late String currentUserId;

  void initState() {
    super.initState();
    // Get the current user's ID from Firebase Authentication
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }


  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final friends = transaction['friends'];
    final bool isCreator = transaction['creatorID'] == currentUserId;
    final groupId = widget.groupId;


    return Scaffold(
      appBar: AppBar(
        title: Text(transaction['title']), // Page header
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCreator) ...[
              const Text(
                "Friends' Shares:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFriendsList(friends, isCreator, transaction),
            ],
            const SizedBox(height: 16),
            const Text(
              "Creator Info:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Creator: ${transaction['creatorName']}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Total Owed: ${transaction['totalAmount']} €",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(List<Map<String, dynamic>> friends, bool isCreator, Map<String, dynamic> transaction) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        // Each friend is a map
        final friend = friends[index];
        final friendId = friend['friendId'];
        final friendName = friend['name'];
        final amountOwed = friend['amountOwed'];
        final isConfirmed = friend['isConfirmed'];
        final creatorName = transaction['creatorName'];


        return ListTile(
          title: Text("Friend: $friendName"),
          subtitle: Text("Owes: $amountOwed €"),
          trailing: isCreator
              ? Text(
            isConfirmed ? "Confirmed" : "Not Confirmed",
            style: TextStyle(
              color: isConfirmed ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
              : ElevatedButton(
            onPressed: isConfirmed
                ? null // Disable button if already confirmed
                : () async {
              _showConfirmationDialog(
                context,
                currentUserId,
                //friendId,
                creatorName,
                amountOwed,
              );
            },
            child: Text(isConfirmed ? "Confirmed" : "Confirm"),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context,
      String currentUserId,
      //friendId
      String creatorName,
      double amountOwed,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Transaction"),
        content: Text(
          "Do you confirm that you owe $creatorName €$amountOwed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _confirmTransaction(currentUserId);
    }
  }


  Future<void> _confirmTransaction(String friendId) async {

    try {
      print("\n\n");
      print(widget.groupId);
      print("\n\n");
      print(widget.transaction['id']);
      // Call your API method to confirm the transaction in Firestore
      await ApiService.confirmTransaction(
        transactionId: widget.transaction['id'],
       // friendId: currentUserId,
        groupId : widget.groupId,
      );

      /*
      setState(() {
        widget.transaction['friends'][friendId]['isConfirmed'] = true;
      });
*/
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction confirmed!")),
      );


      setState(() {
        widget.transaction['friends'][friendId]['isConfirmed'] = true;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to confirm transaction: $e")),
      );

    }
  }



}
