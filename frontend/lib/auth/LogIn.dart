import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/start/Dashboard.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() {
    return _LogInScreenState();
  }
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Login"),
          backgroundColor: Colors.black12,
          centerTitle: true,
      ),
     // drawer: const CustomDrawer(),
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
                )
          ),

                const SizedBox(height: 16.0), // Space between text fields

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                      ),
                ),
              const SizedBox(height: 16.0), // Space between button and textfield
              ElevatedButton(
                  onPressed:(){
                 Navigator.pushNamed(context, '/Dashboard');
                  },
                  child: const Text('Login'),

              ),
              const SizedBox(height: 16.0), // Space between button and textfield
              ElevatedButton(
                onPressed:(){
                Navigator.pushNamed(context, '/ForgotPassword');
                },
                child: const Text('Forgot Password'),

              )

            ],
          ),
        )
      ),


       );


  }
}