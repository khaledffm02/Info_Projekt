# Fairshare - Flutter & Firebase App

Fairshare is an app designed to simplify the process of sharing and managing expenses. Built with Flutter and Firebase, alongside a JavaScript backend, it enables users to split expenses within a group, track payments, and view statistics.

## 🚀 Features

- **User-Friendly Login**:
  - Standard login with access to the dashboard.
  - Password reset via email OTP with mandatory password update.
  - Account unlock with OTP and mandatory password change.
  - Email verification for added security.

- **Dynamic Expense Management**:
  - Overview of all transactions and shared expenses.
  - Smart cost distribution among group members.

- **Firebase Integration**:
  - Authentication with email and password.
  - Password and OTP management.
  - Secure storage and retrieval of data via Firebase Firestore.

- **Modern User Interface**:
  - Intuitive design using Flutter widgets.
  - Responsive layout for multiple platforms (iOS, Android, Web).

## 📱 Screens

1. **StartScreen**: Entry point with navigation to login and registration.
2. **LogInScreen**: Login screen with retry counter and account lock after three failed attempts.
3. **ForgotPasswordScreen**: Reset password via email validation and OTP.
4. **ChangePasswordScreen**: Mandatory password change after reset or account unlock.
5. **Dashboard**: Expense overview and tools for cost splitting.
6. (...)

## 🔧 Technologies

- **Frontend**: Flutter
- **Backend**:
  - Firebase (BaaS):
    - Authentication
    - Firestore
    - Firebase Hosting (optional)
  - JavaScript for backend logic
- **Configuration**: `flutter_dotenv` for environment variables.

## 🛠️ Installation

1. **Requirements**:
   - Install Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
   - Set up Firebase: [Firebase Console](https://console.firebase.google.com/)
   - Internet connection
   - Android Studio and  Chrome for Web builds

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/<username>/fairshare.git
   cd fairshare
3. **Set Up Firebase:**
    Link the project to Firebase.
    Add your google-services.json (for Android) and GoogleService-Info.plist (for iOS) files to the respective directories.
    Configure the .env file with your Firebase settings. In The Projekt you find the .env.example
4. **Run the App:**
      ```bash
      flutter run -d chrome   //Web Version
      flutter run             //Android
