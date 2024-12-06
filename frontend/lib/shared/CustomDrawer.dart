import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black12,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/Dashboard');
            },
          ),

          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create a group'),
            onTap: () {
              Navigator.pushNamed(context, '/CreateGroup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Join a group'),
            onTap: () {
              Navigator.pushNamed(context, '/JoinGroup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('User Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/UserSettings');
            },
          ),


          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              try {
                //sign out the current user
                await FirebaseAuth.instance.signOut();

                // check if user got sign out
                final currentUser = FirebaseAuth.instance.currentUser;
                print('Aktueller Benutzer nach Abmeldung: $currentUser');

                // Go to logIn site
                Navigator.pushReplacementNamed(context, '/LogInScreen');  //from stack deleted
              } catch (e) {
                print('Fehler beim Abmelden: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler beim Abmelden: $e')),   //small pop up with message
                );
              }
            },
          )
        ],
      ),
    );
  }
}