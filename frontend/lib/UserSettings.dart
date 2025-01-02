import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {

                    return AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to delete your account?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // User cancels
                          },
                          child: const Text('Return'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // User confirms
                          },
                          child: Text('Delete User'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  try {
                    // API call to delete user
                    await ApiService.deleteUser(context: context);

                    // Sign out the user
                    await FirebaseAuth.instance.signOut();
                    print('User deleted and signed out.');

                    // Navigate to the start screen
                    Navigator.pushReplacementNamed(context, '/StartScreen');
                  } catch (e) {
                    print('User was not deleted: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'An error occurred while deleting. Please try again'),
                      ),
                    );
                  }
                } else {
                  print('User cancelled account deletion.');
                }
              },
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }
}
