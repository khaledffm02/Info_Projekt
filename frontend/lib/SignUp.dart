import 'package:flutter/material.dart';
import 'package:frontend/Validator.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16.0), // Space between text fields

            TextField(
              controller: _emailController,
              obscureText: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),// Space between text fields
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                final email = _emailController.text;
                var errorMessage = Validator.validateEmail(email);
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
                final password = _passwordController.text;
                Validator.validatePassword(password);
                print('Username: $username, Email: $email, Password $password');
                // prints out your info in console
              },
              child: const Text('Create Account'),
            )
          ],
        ),
      )),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ]),
    );
  }
}
