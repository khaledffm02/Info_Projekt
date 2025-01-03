import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart'; // ApiService importieren
import 'package:frontend/shared/DialogHelper.dart';
import 'package:watch_it/watch_it.dart';
import 'dart:async';

import '../models/LogInStateModel.dart';
import '../shared/CustomDrawer.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/start/Dashboard.dart';

class LogInScreen extends WatchingWidget {
  LogInScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  void _login(BuildContext context, bool otpMode) async {

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: 'All fields are required.',
      );
      return;
    }

    try {
      var loginSuccess =  await ApiService.loginUser(email, password);

      if (loginSuccess == false) {
        if (di<LogInStateModel>().failedLoginAttempts == 2){
          //TODO Meldung anzeigen, dass das der dritte Fehlversuch war und jetzt ein OTP per Mail kommt.
          // TODO OTP per Mail verschicken
          print("3. Fehlerhafte Anmeldung bla");
        } else {
          //TODO Meldung, dass Login nicht erfolgreich. Anzahl der Fehlversuche anzeigen.
          print( di<LogInStateModel>().failedLoginAttempts.toString() + ". + 1 Fehlerhafte Anmeldung ");
        }
        di<LogInStateModel>().failedLoginAttempts++; // OTPMode wird im Setter von failedLoginAttempt auf True gesetzt

        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified != true) {
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content:
          "You didn't confirm the email. Please click the link in your email to verify.",
        );
        await FirebaseAuth.instance.signOut();
      } else if (otpMode == false){

        di<LogInStateModel>().otpMode=false; //otpMode was already "false" but in the setter, we also reset the counter "_failedLoginAttempts"

        DialogHelper.showDialogCustom(
          context: context,
          title: 'Success',
          content: 'Logged in successfully!',
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/Dashboard');
          },
        );
      } else if (otpMode == true){
        print( "otp mode true ");
        //TODO Weiterleitung zu Screen "Passwort ändern"
      }
    }catch(e){
      //todo
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpMode = watchPropertyValue((LogInStateModel x) => x.otpMode);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _login(context, otpMode);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/ForgotPassword'),
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
