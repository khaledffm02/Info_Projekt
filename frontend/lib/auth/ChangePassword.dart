import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/Validator.dart';
import 'package:watch_it/watch_it.dart';

import '../models/LogInStateModel.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
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
                final credential = EmailAuthProvider.credential(
                  email: emailTrimmed ?? '',
                  password: oldPassword,
                );

                try {
                  await user.reauthenticateWithCredential(credential);
                  print('Reauthentication successful!');
                } catch (e) {
                  print('Error during reauthentication: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
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
                di<LogInStateModel>().otpMode=false;
                Navigator.pushNamed(context, '/Dashboard');
              } catch (e) {
                print("Error updating password: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'An error occurred while changing the password.')),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}
