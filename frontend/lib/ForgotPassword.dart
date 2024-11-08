import 'package:flutter/material.dart';

class Forgotpassword extends StatelessWidget {  // Or StatefulWidget if you need state

  final TextEditingController _emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: Text("Forgot Password?"),
    backgroundColor: Colors.lightBlue,
    centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          verticalDirection: VerticalDirection.up,
          children: [
            ElevatedButton(
              onPressed:(){
                final email = _emailController.text;
                print('Email: $email');
                // prints out your info in console
              },
              child: const Text('Reset Password'),

            ),

            const SizedBox(height: 16.0), // Space between text fields


            TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Type in your Email address',
                  border: OutlineInputBorder(),
                ),
              keyboardType: TextInputType.emailAddress,
            ),



          ],




        ),

      ),
    ),
    );
  }
}