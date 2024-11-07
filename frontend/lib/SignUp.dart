import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(context) {
    return const Center(
      child: Text(
        'Sign Up Screen Screen',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
