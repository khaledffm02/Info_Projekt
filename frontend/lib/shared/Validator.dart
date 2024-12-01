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
  static String? validatePassword(String password) {
    // Passwort muss mindestens 8 Zeichen lang sein, Groß- und Kleinbuchstaben sowie ein Sonderzeichen enthalten
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      return 'Password must be at least 8 characters long, include both uppercase and lowercase letters, and contain at least one special character';
    }
    return null; // Passwort ist gültig
  }
}