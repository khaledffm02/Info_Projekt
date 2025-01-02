import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart'; // ApiService importieren
import 'package:frontend/shared/DialogHelper.dart';
import 'dart:async';

import '../shared/CustomDrawer.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/start/Dashboard.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _failedAttempts = 0; // Count failed attempt of log in
  final int _maxAttempts = 3; // Max number of log in attempt
  bool _isLocked = false; // Lock state

  void _login() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account locked. Please try again later.'),
        ),
      );
      return;
    }

    if (_failedAttempts >= _maxAttempts) {
      setState(() {
        _isLocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account locked. Please wait 30 seconds before trying again.'),
        ),
      );

      // Unlock the account after 30 seconds
      Timer(const Duration(seconds: 30), () {
        setState(() {
          _isLocked = false;
          _failedAttempts = 0; // Reset attempts after lock period
        });
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: 'All fields are required.',
      );
      return;
    }

    try {
      await ApiService.loginUser(email, password);

      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified != true) {
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content:
          "You didn't confirm the email. Please click the link in your email to verify.",
        );
        await FirebaseAuth.instance.signOut();
      } else {
        setState(() {
          _failedAttempts = 0; // Reset attempts on successful login
        });

        DialogHelper.showDialogCustom(
          context: context,
          title: 'Success',
          content: 'Logged in successfully!',
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/Dashboard');
          },
        );
      }
    } catch (e) {
      setState(() {
        _failedAttempts++;
      });

      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: _failedAttempts >= _maxAttempts
            ? 'Account locked. Please wait 30 seconds before trying again.'
            : 'The provided login details are incorrect or the user does not exist.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/ForgotPassword'),
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
