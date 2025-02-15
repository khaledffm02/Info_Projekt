
class Validator {

  static String? validateEmail(String email) {
    final emailRegex = RegExp(r'.+@.+\..+');         //Redex for Email Format
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static bool validatePassword(String password) {
   // The password must be at least 12 characters long and include uppercase and lowercase letters, at least one digit, and at least special character.

    final passwordRegexMinor = RegExp(r'[a-z]');
    final passwordRegexMajor = RegExp(r'[A-Z]');
    final passwordRegexNumber = RegExp(r'\d');
    final passwordRegexSpecialChar = RegExp(r'[@$!%*?&]');
    if (!passwordRegexMinor.hasMatch(password) ||
        !passwordRegexMajor.hasMatch(password) ||
        !passwordRegexNumber.hasMatch(password) ||
        !passwordRegexSpecialChar.hasMatch(password) ||
        password.length<12) {

      return false;
    }
    return true;
  }
}