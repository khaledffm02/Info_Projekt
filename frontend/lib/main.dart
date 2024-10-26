import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: const Center(
            child: Text(
              "Hallo World",
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
          ),
        ),
      ),
    ),
  );
}
