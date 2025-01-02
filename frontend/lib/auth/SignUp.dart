import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/shared/ApiService.dart'; // Importiere den ApiService
import 'package:frontend/shared/DialogHelper.dart';

import '../shared/Validator.dart';

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

                // Register user using the ApiService
                try {
                  await ApiService.registerUser(email, password, firstname, lastname);
                  DialogHelper.showDialogCustom(
                    context: context,
                    title: 'Success',
                    content: 'User registered successfully.',
                    onConfirm: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/LogInScreen');
                    },
                  );
                } catch (e) {
                  DialogHelper.showDialogCustom(
                    context: context,
                    title: 'Error',
                    content: 'An error occurred: $e',
                  );
                }
                Validator.validatePassword(password);

              },
              child: const Text('Create Account'),
            )
          ],
        ),
      ),
    );
  }
}
