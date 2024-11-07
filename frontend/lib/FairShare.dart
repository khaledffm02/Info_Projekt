import 'package:flutter/material.dart';
import 'package:frontend/LogIn.dart';
import 'package:frontend/SignUp.dart';
import 'StartScreen.dart';

class FairShare extends StatefulWidget {
  const FairShare({super.key});

  @override
  State<FairShare> createState() {
    return _FairShareState();
  }
}

class _FairShareState extends State<FairShare> {
  Widget? aktiveScreen;

  @override
  void initState() {
    aktiveScreen=StartScreen(switchToLogInScreen, switchToSignUpScreen);
    super.initState();
  }// Give Pointer to switch screen in StartScreen

  void switchToLogInScreen() {
    setState(() {
      aktiveScreen = const LogInScreen();           //Setting new State
    });
  }
  void switchToSignUpScreen() {
    setState(() {
      aktiveScreen = const SignUpScreen();           //Setting new State
    });
  }


  @override
  Widget build(context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black87),
          child: aktiveScreen,                          //Rendering the content Conditionaly
        ),
      ),
    );
  }
}
