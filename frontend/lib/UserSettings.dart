import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:frontend/shared/Validator.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
            // Old password
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your old Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // New password
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter new Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Button for changing password
            ElevatedButton(
              onPressed: () async {
                final oldPassword = _oldPasswordController.text.trim();
                final newPassword = _newPasswordController.text.trim();
                final confirmPassword = _confirmPasswordController.text.trim();

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('The new password cannot be empty')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                final emailTrimmed = user?.email?.trim();
                if (user != null) {
                  // Create the credential with email and password
                  final credential = EmailAuthProvider.credential(
                    email: emailTrimmed ?? '',
                    password: oldPassword,
                  );

                  try {
                    // User re-authentication
                    await user.reauthenticateWithCredential(credential);
                    print('Reauthentication successful!');
                  } catch (e) {
                    print('Error during reauthentication: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Reauthentication failed. Check your old password.')),
                    );
                    return;
                  }
                }

                try {
                  await user?.updatePassword(newPassword);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                    ),
                  );
                  Navigator.pushNamed(context, '/Dashboard');
                } catch (e) {
                  print("Error updating password: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'An error occurred while changing the password.')),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
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
              child: Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }
}
