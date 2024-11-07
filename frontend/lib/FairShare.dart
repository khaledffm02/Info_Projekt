import 'package:flutter/material.dart';
import 'package:frontend/LogIn.dart';
import 'StartScreen.dart';

class FairShare extends StatefulWidget {
  const FairShare({super.key});

  @override
  State<FairShare> createState() {
    return _FairShareState();
  }
}

class _FairShareState extends State<FairShare> {
  Widget? aktivScreen;

  @override
  void initState() {
    aktivScreen=StartScreen(switchScreen);
    super.initState();
  }// Give Pointer to switch screen in StartScreen

  void switchScreen() {
    setState(() {
      aktivScreen = const LogInScreen();           //Setting new State
    });
  }

  @override
  Widget build(context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black87),
          child: aktivScreen,                          //Rendering the content Conditionaly
        ),
      ),
    );
  }
}
