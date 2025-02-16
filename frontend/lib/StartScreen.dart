import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen(this.logIn, this.SignUp,
      {super.key}); //switchState can be  now used as a   Function
  final void Function() logIn;
  final void Function() SignUp; //LogIn Variable that can be use in a button
  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 250),
            const Text(
              "FairShare",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 200),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/LogInScreen');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/SignUpScreen');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
