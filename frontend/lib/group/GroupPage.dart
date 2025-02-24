
import 'package:flutter/material.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/CreateGroup');
                },
                child: const Text('Create Group'),
              ),
              const SizedBox(height: 16.0), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/JoinGroup');
                },
                child: const Text('Join Group'),
              ),
            ],
          ),
        ),
      ),

    );
  }
}



