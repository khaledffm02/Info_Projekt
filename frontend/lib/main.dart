import 'package:flutter/material.dart';
import 'package:frontend/StartScreen.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Colors.black87),
          child: const StartScreen(),),
      ),
    ),
  );
}
