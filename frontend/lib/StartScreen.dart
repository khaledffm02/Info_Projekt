import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/LogIn.dart';

class StartScreen extends StatelessWidget {
  const  StartScreen(this.logIn, {super.key} );   //switchState can be  now used as a   Function
  final void Function() logIn;                   //LogIn Variable that cann be use in a button
  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 250),
          const Text(
            "App Name",
            style: TextStyle(
              fontSize: 30,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          const SizedBox(height: 200),
          OutlinedButton(
            onPressed: () {
              logIn();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Log In'),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
