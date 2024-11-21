import 'package:flutter/material.dart';
import 'package:frontend/CreateExpense.dart';
import 'package:frontend/CreateGroup.dart';
import 'package:frontend/ForgotPassword.dart';
import 'package:frontend/GroupOverview.dart';
import 'package:frontend/GroupPage.dart';
import 'package:frontend/JoinGroup.dart';
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
        '/SignUpScreen' : (context) => SignUpScreen(),
        '/LogInScreen' : (context) => LogInScreen(),
        '/ForgotPassword' : (context) => ForgotPassword(),
        '/CreateGroup': (context) => CreateGroup(),
        '/JoinGroup': (context) => JoinGroup(),
        '/GroupPage': (context) => GroupPage(),
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

      /*
      onGenerateRoute: (settings) {
        // Handle named routes dynamically
        if (settings.name == '/GroupOverview') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return GroupOverview(
                groupName: args['groupName'],
                members: args['members'],
              );
            },
          );
        }
        return null; // Return null if the route does not match
      },
*/

      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black87),
          child: aktivScreen,                          //Rendering the content Conditionaly
        ),
      ),
    );
  }
}
