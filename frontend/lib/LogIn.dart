import 'package:flutter/material.dart';
import 'package:frontend/Validator.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() {
    return _LogInScreenState();
  }
}

class _LogInScreenState extends State<LogInScreen> {
  @override
  Widget build(context) {
    return const Center(
      child: Text(
        'Log In Screen',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
