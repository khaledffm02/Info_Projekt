import 'package:flutter/material.dart';

class Validator {
  // E-Mail-Validierungsmethode
  static String? validateEmail(String email) {
    final emailRegex = RegExp(r'.+@.+\..+'); // Einfache Regex für E-Mail-Formatprüfung
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null; // E-Mail ist gültig
  }

  // Passwort-Validierungsmethode
  static bool validatePassword(String password) {
    // Passwort muss mindestens 12 Zeichen lang sein, Groß- und Kleinbuchstaben sowie ein Sonderzeichen enthalten
    final passwordRegexMinor = RegExp(r'[a-z]');
    final passwordRegexMajor = RegExp(r'[A-Z]');
    final passwordRegexSpecialChar = RegExp(r'[@$!%*?&]');
    if (!passwordRegexMinor.hasMatch(password) ||
        !passwordRegexMajor.hasMatch(password) ||
        !passwordRegexSpecialChar.hasMatch(password)) {

      return false;
    }
    return true; // Passwort ist gültig
  }
}