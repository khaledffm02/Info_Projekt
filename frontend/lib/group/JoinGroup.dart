// new Join Group

import 'package:flutter/material.dart';

import '../shared/ApiService.dart';
import '../shared/DialogHelper.dart';

class JoinGroup extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();

  JoinGroup({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Group"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter invitation code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{
                // Revalidating beim Klicken auf den Button
                final code = _codeController.text;


                try {
                  // Call the API to join the group
                 await ApiService.joinGroup(context, code);

                  // Show success dialog
                 DialogHelper.showDialogCustom(
                     context: context,
                     title: 'Success',
                     content: 'You are in the new group',
                     onConfirm: () {
                       Navigator.pushNamed(context, '/Dashboard'); // Navigate to the dashboard
                     },

                 );

                } catch (error) {
                  // Show error dialog if the group code is invalid or another error occurred
                  DialogHelper.showDialogCustom(
                    context: context,
                    title: 'Error',
                    content: error.toString(), // Show the error message
                  );

                }


              },
              child: const Text('Validate Code'),
            ),
          ],
        ),
      ),
    );
  }
}