import 'package:flutter/material.dart';

class LogInStateModel extends ChangeNotifier {
  int _maxLoginAttempts = 3;

  int _failedLoginAttempts = 0;

  int get failedLoginAttempts => _failedLoginAttempts;

  set failedLoginAttempts(int value) {
    _failedLoginAttempts++;
    if (_failedLoginAttempts > 2) {
      _otpMode = true;
    }
    notifyListeners();
  }

  bool _otpMode = false;

  bool get otpMode => _otpMode;

  set otpMode(bool value) {
    _failedLoginAttempts = 0;
    _otpMode = value;

    notifyListeners();
  }
}
