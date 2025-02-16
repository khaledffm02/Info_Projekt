import 'dart:async';
import 'package:flutter/material.dart';

void showUnclosableDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // ⬅️ //you cannot click outside the Dialog
    builder: (context) {
      return _UnclosableDialog();
    },
  );

// The Dialog close after 30 seconds
Timer(const Duration(seconds: 30), () {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  });
}

// Widget
class _UnclosableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text("Login gesperrt"),
      content: Text("Bitte warte 30 Sekunden, bevor du es erneut versuchst."),
      actions: [
        TextButton(
          onPressed: null, //Button is not activ
          child: Text("Warten...", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
