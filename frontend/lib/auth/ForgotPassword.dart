import 'package:flutter/material.dart';
import 'package:frontend/shared/Validator.dart';


class ForgotPassword extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPassword({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password?"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Revalidating beim Klicken auf den Button
                final email = _emailController.text;
                final errorMessage = Validator.validateEmail(email);

                if (errorMessage != null) {
                  // Zeige Fehlermeldung, falls die E-Mail ungültig ist
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Email'),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Zeigt Bestätigung, falls die E-Mail gültig ist
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content: Text('Password reset link sent to $email'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/LogInScreen');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Validate Email'),
            ),
          ],
        ),
      ),
    );
  }
}
