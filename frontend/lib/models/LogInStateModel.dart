import 'package:flutter/material.dart';
import 'package:frontend/models/Currency.dart';



class LogInStateModel extends ChangeNotifier {

  int _failedLoginAttempts = 0;

  int get failedLoginAttempts => _failedLoginAttempts;

  set failedLoginAttempts(int value) {

    _failedLoginAttempts=value;
    if (_failedLoginAttempts >= 3) {
      _otpMode = true;
    }
    notifyListeners();
  }

  bool _otpMode = false;

  bool get otpMode => _otpMode;

  set otpMode(bool value) {
    _otpMode = value;

    notifyListeners();
  }
}
