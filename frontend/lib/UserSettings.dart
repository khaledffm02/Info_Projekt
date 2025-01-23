import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/ChangePassword.dart';
import 'package:frontend/shared/ApiService.dart';

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);

  final String label;
  final Color color;
}

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController colorController = TextEditingController();
  ColorLabel? selectedColor;

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
        child: SingleChildScrollView(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChangePasswordWidget(), // Passwort ändern
              const SizedBox(height: 40.0),
              _buildDropdownMenu(), // Dropdown-Menü
              const SizedBox(height: 40.0),
              _buildDeleteAccountButton(), // Button: Konto löschen
            ],
          ),
        )),
      ),
    );
  }

  // Dropdown-Menü
  Widget _buildDropdownMenu() {
    return Center(
      child: DropdownMenu<ColorLabel>(
        initialSelection: ColorLabel.green,
        controller: colorController,
        label: const Text('Currency'),
        onSelected: (ColorLabel? color) {
          setState(() {
            selectedColor = color;
          });
        },
        dropdownMenuEntries: ColorLabel.values
            .map<DropdownMenuEntry<ColorLabel>>((ColorLabel color) {
          return DropdownMenuEntry<ColorLabel>(
            value: color,
            label: color.label,
            enabled: color.label != 'Grey',
          );
        }).toList(),
      ),
    );
  }

  // Button zum Löschen des Kontos
  Widget _buildDeleteAccountButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final bool? confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Account'),
                content:
                    const Text('Are you sure you want to delete your account?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Abbrechen
                    },
                    child: const Text('Return'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Bestätigen
                    },
                    child: const Text('Delete User'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            try {
              await ApiService.deleteUser(context: context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/StartScreen');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'An error occurred while deleting. Please try again'),
                ),
              );
            }
          }
        },
        child: const Text('Delete account'),
      ),
    );
  }
}
