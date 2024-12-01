import 'package:flutter/material.dart';

class DialogHelper {
  static void showDialogCustom({
    required BuildContext context,
    required String title,
    required String content,
    VoidCallback? onConfirm,
  }) {

    if (!context.mounted) return; // Sicherstellen, dass der Kontext gültig ist
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließt den Dialog
                if (onConfirm != null) onConfirm(); // Führt die Bestätigungsaktion aus
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
