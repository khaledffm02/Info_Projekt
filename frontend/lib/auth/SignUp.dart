import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/DialogHelper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _registerUser(
      String email, String password, String firstname, String lastname) async {
    try {
      // Step 1: Register user with Firebase Authentication
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Retrieve the Firebase ID Token
      final idToken = await credential.user?.getIdToken() ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to retrieve ID Token.');
      }

      // Step 3: Send data to the API endpoint
      final url = Uri.parse(
        'https://userregistration-icvq5uaeva-uc.a.run.app'
            '?idToken=${Uri.encodeComponent(idToken)}'
            '&firstName=${Uri.encodeComponent(firstname)}'
            '&lastName=${Uri.encodeComponent(lastname)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          DialogHelper.showDialogCustom(
            context: context,
            title: 'Success',
            content: 'User registered successfully.',
            onConfirm: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/LogInScreen');
            },
          );
        }
      } else {
        if (mounted) {
          DialogHelper.showDialogCustom(
            context: context,
            title: 'Error',
            content:
            'Failed to register user. Server responded with status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content: 'An error occurred: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstnameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _lastnameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final firstname = _firstnameController.text.trim();
                final lastname = _lastnameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                final confirmPassword = _confirmPasswordController.text;

                // Input validation
                if (firstname.isEmpty ||
                    lastname.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty) {
                  DialogHelper.showDialogCustom(
                    context: context,
                    title: 'Error',
                    content: 'All fields are required.',
                  );
                  return;
                }

                // Password match validation
                if (password != confirmPassword) {
                  DialogHelper.showDialogCustom(
                    context: context,
                    title: 'Error',
                    content: 'Passwords do not match.',
                  );
                  return;
                }

                // Register user
                await _registerUser(email, password, firstname, lastname);
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
