import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:frontend/shared/RatesService.dart';
import 'package:watch_it/watch_it.dart';
import 'dart:async';
import '../models/LogInStateModel.dart';
import '../shared/CustomDrawer.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/Dashboard.dart';
import 'dart:developer' as developer;
import 'package:timer_button/timer_button.dart';
import 'package:logger/logger.dart';

class LogInScreen extends WatchingWidget {
  LogInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool otpMode = false; // Standardmäßig deaktiviert

  Future<void> _login(BuildContext context, bool otpMode) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: 'All fields are required.',
      );
      return;
    }
//ToDo with more that 4 Try in snackbar
    try {
      var loginSuccess = await ApiService.loginUser(email, password);

      if (loginSuccess == false) {
        /*     ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User doesn't exist"),
          ),
        );
*/
        await ApiService.increaseLoginAttempts(email);
        developer.log('Testmessage', name: 'Info');

        var getLoginResponse = await ApiService.getLoginAttempts(email);
        di<LogInStateModel>().failedLoginAttempts = getLoginResponse;

        print(di<LogInStateModel>().failedLoginAttempts);

        if (di<LogInStateModel>().failedLoginAttempts == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You did not log in correctly for the 3rd time. We sent a One Time Password to your Email.'),
            ),
          );

          try {
            await ApiService.resetPassword(email);
          } catch (e) {
            print("Email was not sent: $e");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Log in failed. It is your attempt(s) ' +
                    getLoginResponse.toString(),
              ),
            ),
          );
        }
        return;
      }

      await RatesService.UpdateRates();
      await ApiService.resetLoginAttempts(email);
      di<LogInStateModel>().failedLoginAttempts =
          await ApiService.getLoginAttempts(email);
      print(di<LogInStateModel>().failedLoginAttempts);

      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified != true) {
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content:
              "You didn't confirm the email. Please click the link in your email to verify.",
        );
        await FirebaseAuth.instance.signOut();
      } else if (otpMode == false) {}

      if (otpMode == false) {
        di<LogInStateModel>().otpMode = false;
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Success',
          content: 'Logged in successfully!',
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/Dashboard');
          },
        );
      } else if (otpMode == true) {
        print("OTP mode active");
        Navigator.pushNamed(context, '/ChangePassword');
        //toDo: reset attempt_reset
      }
    } catch (e) {
      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: 'Failed to log in: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    otpMode = watchPropertyValue((LogInStateModel x) => x.otpMode);
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
              onPressed: () async {
                _login(context, otpMode);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text("Log in"),
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
