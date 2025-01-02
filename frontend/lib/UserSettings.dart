import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:frontend/shared/Validator.dart';
import 'package:http/http.dart' as http;

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
  
  static Future<void> loginUser(String email, String password, BuildContext context) async {
    try {
      // Step 1: Sign in user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Step 2: Retrieve the Firebase ID Token
      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

      // Step 3: Send ID Token to the login API endpoint
      final url = Uri.parse(
        'https://userlogin-icvq5uaeva-uc.a.run.app'
            '?idToken=${Uri.encodeComponent(idToken)}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to log in user. Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  void handleLogin(String email, String password) async {
    if (_failedLoginAttempts >= _maxAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account locked. Please reset your password.'),
        ),
      );
      return;
    }

    try {
      await loginUser(email, password, context);
      setState(() {
        _failedLoginAttempts = 0; // Reset attempts on successful login
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/Dashboard');
    } catch (e) {
      setState(() {
        _failedLoginAttempts++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Login failed. Attempt $_failedLoginAttempts of $_maxAttempts.'),
        ),
      );

      if (_failedLoginAttempts >= _maxAttempts) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account locked. Please reset your password.'),
          ),
        );
      }
    }
  }

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
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => handleLogin(
                _oldPasswordController.text.trim(),
                _newPasswordController.text.trim(),
              ),
              child: const Text('Login'),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
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
git diff