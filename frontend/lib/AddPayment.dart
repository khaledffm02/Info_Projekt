import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';


class AddPayment extends StatefulWidget {
  final List<Map<String, dynamic>> members; // List of group members
  final String groupName; // Group ID for reference


  const AddPayment({
    super.key,
    required this.members,
    required this.groupName,

  });

  @override
  _AddPaymentState createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  late String currentUserId;
  String? selectedMemberId; // Declare selectedMemberId as nullable String
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get the current user's ID from Firebase Authentication
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _submitPayment() async {
    final amount = double.tryParse(_amountController.text);
    if (selectedMemberId == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a member and enter a valid amount.")),
      );
      return;
    }

    try {
      // Call your API method to mark the payment as completed
      await ApiService.addPayment(
        groupId: widget.groupName,
        toId: selectedMemberId!, // Use the selected member ID
        fromId: currentUserId,
        amount: amount,
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
              'groupId': widget.groupName, // Pass the group ID
              'groupName': widget.groupName, // Use group name or fallback to ID
            },
          );



        },

      );


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send payment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Member",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMemberId, // Bind selectedMemberId
              items: widget.members.where((member) => member['id'] != currentUserId).map((member) {
                return DropdownMenuItem<String>(
                  value: member['id'], // Use member ID as the value
                  child: Text(member['name']), // Display member name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMemberId = value; // Update selected member ID
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Choose a member",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enter Amount (€)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter amount",
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black12,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  "Send Payment",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
