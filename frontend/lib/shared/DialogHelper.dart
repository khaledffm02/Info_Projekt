import 'package:flutter/material.dart';

class DialogHelper {
  static void showDialogCustom({
    required BuildContext context,
    required String title,
    required String content,
    VoidCallback? onConfirm,
  }) {
    // Überprüfen, ob der Navigator verfügbar ist und der Kontext gültig ist
    if (!Navigator.of(context, rootNavigator: true).mounted) {
      debugPrint("DialogHelper: Context is no longer mounted. Dialog cannot be shown.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Schließt den Dialog
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
