import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/CurrencyConvertingHelper.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:watch_it/watch_it.dart';

import 'models/CurrencyStateModel.dart';

class ViewTransaction extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Creator;
  final groupId;
  final groupName;
  final groupCode;

  const ViewTransaction({
    super.key,
    required this.transaction,
    required this.Creator,
    required this.groupId, required this.groupName, required this.groupCode,
  });

  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  late String currentUserId;
  late bool isConfirmedByCurrentUser; // Variable to track if current user confirmed the transaction

  @override
  void initState() {
    super.initState();
    // Get the current user's ID from Firebase Authentication
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Check if the current user has already confirmed the transaction
    final friends = widget.transaction['friends'];
    final friend = friends.firstWhere(
          (f) => f['friendId'] == currentUserId,
      orElse: () => <String, dynamic>{}, // Use Map<String, dynamic> as the fallback
    );
    isConfirmedByCurrentUser = friend.isNotEmpty && friend['isConfirmed'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final friends = transaction['friends'];
    final bool isCreator = transaction['creatorID'] == currentUserId;
    final groupId = widget.groupId;

    // Find the friend that matches the current user and has an amount owed
    final currentUserFriend = friends.firstWhere(
          (f) => f['friendId'] == currentUserId,
      orElse: () => <String, dynamic>{},
    );
    var amountOwed = currentUserFriend['amountOwed'] ?? 0.0;
    amountOwed = amountOwed is int ? amountOwed.toDouble() : amountOwed;


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
            //if (!isCreator) ...[
              const Text(
                "Friends' Shares:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFriendsList(friends, isCreator, transaction),
           // ],
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
              "Total: ${transaction['totalAmount']} €",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),


            // Show the Add Payment Button only if the current user owes money and the transaction is confirmed
            if (!isCreator && amountOwed > 0 && isConfirmedByCurrentUser) ...[
              ElevatedButton(
                onPressed: () => _showPaymentDialog(
                  context,
                  currentUserId,
                  transaction['creatorName'],
                  amountOwed,
                ),
                child: const Text("Add Payment"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(
      List<Map<String, dynamic>> friends,
      bool isCreator,
      Map<String, dynamic> transaction,
      ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final friendId = friend['friendId'];
        final friendName = friend['name'];
        final isConfirmed = friend['isConfirmed'];
        final creatorName = transaction['creatorName'];

        var amountOwed = friend['amountOwed'] ?? 0.0;
        amountOwed = amountOwed is int ? amountOwed.toDouble() : amountOwed;


        // Check if the current user matches the friendId
        final isCurrentUser = friendId == currentUserId;

        return ListTile(
          title: Text("Friend: $friendName"),
          subtitle: Text("Owes: $amountOwed €"),
          //ToDO: neue Variable für ansicht in andere currency
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confirm Button
              ElevatedButton(
                onPressed: isConfirmed || !isCurrentUser
                    ? null // Disable button if already confirmed or not the current user
                    : () async {
                  _showConfirmationDialog(
                    context,
                    currentUserId,
                    creatorName,
                    amountOwed,
                  );
                },
                child: Text(isConfirmed ? "Confirmed" : "Confirm"),
              ),
              const SizedBox(width: 8), // Add some spacing between the buttons
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context,
      String currentUserId,
      String creatorName,
      double amountOwed,
      ) async {
    String amountConvertedToUserCurrency = "";
    if (di<CurrencyStateModel>().userCurrency != "EUR") {
      var currencyConvertingHelper = new CurrencyConvertingHelper();
      amountConvertedToUserCurrency =
      " (${currencyConvertingHelper.convertSingleAmountToUserCurrency(
          amountOwed, "EUR").toStringAsFixed(2)} ${di<CurrencyStateModel>()
          .userCurrency})";
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Transaction"),
        content: Text(
          "Do you confirm that you owe $creatorName €$amountOwed$amountConvertedToUserCurrency?",
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
      // Call your API method to confirm the transaction in Firestore
      await ApiService.confirmTransaction(
        transactionId: widget.transaction['id'],
        groupId: widget.groupId,
      );

      // Find the friend in the `friends` list and update their `isConfirmed` status
      setState(() {
        final friend = widget.transaction['friends']
            .firstWhere((f) => f['friendId'] == friendId);
        friend['isConfirmed'] = true;
        isConfirmedByCurrentUser = true; // Update local confirmation state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction confirmed!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to confirm transaction: $e")),
      );
    }
  }



  Future<void> _showPaymentDialog(
      BuildContext context,
      String friendId,
      String creatorName,
      double amountOwed,
      ) async {
    String amountConvertedToUserCurrency = "";
    if (di<CurrencyStateModel>().userCurrency != "EUR"){
      var currencyConvertingHelper = new CurrencyConvertingHelper();
      amountConvertedToUserCurrency = " (${currencyConvertingHelper.convertSingleAmountToUserCurrency(amountOwed, "EUR").toStringAsFixed(2)} ${di<CurrencyStateModel>().userCurrency})";
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Payment"),
        content: Text(
          "Do you confirm that you paid $creatorName €$amountOwed$amountConvertedToUserCurrency?",
        ),
        //ToDo Show in Other currency
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
      _addPayment(friendId, amountOwed);
    }
  }

  Future<void> _addPayment(String friendId, double amountOwed) async {
    try {

      final creatorId = widget.transaction['creatorID'];


      await ApiService.addPayment(
        groupId: widget.groupId,
        toId: creatorId,
        fromId: currentUserId,
        amount: amountOwed,
      );

      DialogHelper.showDialogCustom(
        context: context,
        title: 'Success',
        content: 'The Payment was sent',
        onConfirm: () {
          Navigator.pushNamed(
            context,
            '/GroupOverview',
            arguments: {
              'groupId': widget.groupId, // Pass the group ID
              'groupName': widget.groupName,
              'groupCode': widget.groupCode,
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark payment as complete: $e")),
      );
    }
  }
}
