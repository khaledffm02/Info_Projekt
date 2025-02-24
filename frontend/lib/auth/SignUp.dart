import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import '../shared/Validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _firstnameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
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
              const SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Terms and Conditions"),
                              content: const SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Welcome to FairShare, a money-splitting platform designed to help users manage shared expenses.\n',
                                      style: TextStyle(
                                          fontSize: 20,
                                          height: 1.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Interpersonal Disputes:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'FairShare solely facilitates the splitting and tracking of expenses. We are not liable for any disputes or conflicts that may arise between users regarding transactions, payments, or interpersonal interactions.\n',
                                      style:
                                          TextStyle(fontSize: 16, height: 1.5),
                                    ),
                                    Text(
                                      'Account Deletion:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'If you choose to delete your account, all associated personal data, including participation in groups, will be permanently removed. Group data relevant to remaining members will remain intact without your personal information.\nIf a User deletes their account with an outstanding balance, we reserve the right to hold information in our databases for the purpose of debt collection\n',
                                      style:
                                          TextStyle(fontSize: 16, height: 1.5),
                                    ),
                                    Text(
                                      'Data Protection:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'We are committed to protecting your data in compliance with privacy laws. By continuing, you acknowledge and accept these terms.\n\nPlease read these carefully before proceeding.',
                                      style:
                                          TextStyle(fontSize: 16, height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop();
                                  },
                                  child: const Text("Close"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'In Order to use our App, you have to accept our Terms and Conditions.  You can see them HERE',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(   //only of AGB button is checked , the user is able to proceed
                onPressed: isChecked
                    ? () async {
                        final firstname = _firstnameController.text.trim();
                        final lastname = _lastnameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        final confirmPassword = _confirmPasswordController.text;

                        // Input validation
                        if (firstname.isEmpty ||
                            lastname.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            confirmPassword.isEmpty) {
                          DialogHelper.showDialogCustom(
                            context: context,
                            title: 'Error',
                            content: 'All fields are required.',
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          DialogHelper.showDialogCustom(
                            context: context,
                            title: 'Error',
                            content: 'Passwords do not match.',
                          );
                          return;
                        }
                        if (Validator.validatePassword(password)) {
                          try {
                            await ApiService.registerUser(
                                email, password, firstname, lastname);
                            DialogHelper.showDialogCustom(
                              context: context,
                              title: 'Success',
                              content: 'User registered successfully. Confirm your Account through the link, we send to you via email',
                              onConfirm: () {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(context, '/LogInScreen');
                              },
                            );
                          } catch (e) {
                            DialogHelper.showDialogCustom(
                              context: context,
                              title: 'Error',
                              content: '$e',
                            );
                          }
                        }else{
                          DialogHelper.showDialogCustom(context: context, title: "Error", content: 'Password must be at least 12 characters long, include both uppercase and lowercase letters, and contain at least one special character');
                        }
                      }
                    : null,
                child: const Text('Create Account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
