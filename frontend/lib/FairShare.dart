import 'package:flutter/material.dart';
import 'package:frontend/CreateExpense.dart';
import 'package:frontend/group/CreateGroup.dart';
import 'package:frontend/auth/ForgotPassword.dart';
import 'package:frontend/GroupOverview.dart';
import 'package:frontend/group/GroupPage.dart';
import 'package:frontend/group/JoinGroup.dart';
import 'package:frontend/auth/LogIn.dart';
import 'package:frontend/auth/SignUp.dart';
import 'package:frontend/StartScreen.dart';
import 'package:frontend/start/Dashboard.dart';

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
    aktivScreen=StartScreen(switchToLogInScreen, switchToSignUpScreen);
    super.initState();
  }// Give Pointer to switch screen in StartScreen

  void switchToLogInScreen() {
    setState(() {
      aktivScreen = const LogInScreen();           //Setting new State
    });
  }
  void switchToSignUpScreen() {
    setState(() {
      aktivScreen = const SignUpScreen();           //Setting new State
    });
  }


  @override
  Widget build(context) {
    return MaterialApp(
      routes: {
        '/SignUpScreen' : (context) => const SignUpScreen(),
        '/LogInScreen' : (context) => const LogInScreen(),
        '/ForgotPassword' : (context) => ForgotPassword(),
        '/CreateGroup': (context) => const CreateGroup(),
        '/JoinGroup': (context) => JoinGroup(),
        '/GroupPage': (context) => const GroupPage(),
        '/Dashboard': (context) => const Dashboard(),

        '/CreateExpense': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return CreateExpense(members: arguments['members']);
        },

        '/GroupOverview': (context) {
        // Retrieve the arguments from the navigation
        final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        return GroupOverview(
        groupName: arguments['groupName'],
        members: arguments['members'],
        );

        }

      },




      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black87),
          child: aktivScreen,                          //Rendering the content Conditionaly
        ),
      ),
    );
  }
}