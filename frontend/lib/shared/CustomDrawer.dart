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
              color: Colors.blue,
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
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create a group'),
            onTap: () {
              Navigator.pushNamed(context, '/CreateGroup');
            },
          ),
/*          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              Navigator.pushNamed(context, '/transactionHistory');
            },
        ),*/
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.pushNamed(context, 'User-signs-out');
            },
          )
        ],
      ),
    );
  }
}
