import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:frontend/shared/Validator.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Old password
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your old Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            //new password
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter new Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            //Buttor for changing password
            ElevatedButton(
              onPressed: () async {
                final oldPassword = _oldPasswordController.text.trim();
                final newPassword = _newPasswordController.text.trim();
                final confirmPassword = _confirmPasswordController.text.trim();

                if (newPassword.isEmpty & confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('The new password can not be empty')),
                  );
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }

                final user = FirebaseAuth.instance.currentUser;
                final emailTrimmed = user?.email?.trim();
                if (user != null) {
                  //create the credential with email and password
                  final credential = EmailAuthProvider.credential(
                    email: emailTrimmed ?? '',
                    password: oldPassword,
                  );

                  try {
                    //User re-authentication
                    await user.reauthenticateWithCredential(credential);
                    print('Reauthentication successful!');
                  } catch (e) {
                    print('Error during reauthentication: $e');
                  }
                }
                print("test");

                try {
                  await user?.updatePassword(newPassword);
                  DialogHelper.showDialogCustom(context: context, title: "Succes" , content: "Password was changed");
                  Navigator.pushNamed(context, '/Dashboard');
                } catch (e) {
                  print("test_update_password: $e");
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
