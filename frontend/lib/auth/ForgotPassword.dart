import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
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
              onPressed: () async {
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
                  try {
                    ApiService.resetPassword(email);
                  }catch(e){
                    print("Email  was not sent: $e");
                  }

                  try {


                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Erfolgreich'),
                        content: Text('„Falls die E-Mail-Adresse existiert, haben wir Ihnen eine Nachricht an $email mit Anweisungen zum Zurücksetzen des Passworts gesendet.“'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Erste Aktion: Dialog schließen
                              Navigator.pushNamed(context, '/LogInScreen'); // Zweite Aktion: Navigation zum Login-Screen
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Fehler'),
                        content: const Text('Das Senden der OTP-E-Mail ist fehlgeschlagen.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
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
