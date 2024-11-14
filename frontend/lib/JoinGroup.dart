// Join Group

import 'package:flutter/material.dart';

class JoinGroup extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();

  JoinGroup({super.key});

  //Check the code
  String? validateCode(String code) {
    final codeRegex = RegExp(r'^[a-zA-Z0-9]{6}$');     //code is 6 digits and can have a-z, A-Z, 0-9
    if (!codeRegex.hasMatch(code)) {
      return 'Please enter a valid code';
    }
    return null; // code ist gültig
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Group"),
        backgroundColor: Colors.lightBlue,
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
              onPressed: () {
                // Revalidating beim Klicken auf den Button
                final code = _codeController.text;
                final errorMessage = validateCode(code);

                if (errorMessage != null) {
                  // Zeige Fehlermeldung, falls der Code ungültig ist
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Code'),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Zeigt Bestätigung, falls der Code gültig ist
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content: Text('You are in the new group'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/GroupPage');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
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