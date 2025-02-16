# Fairshare - Flutter & Firebase App

Fairshare is an app designed to simplify the process of sharing and managing expenses. Built with Flutter and Firebase, orchestrated by a TypeScript backend, it enables users to split expenses within a group, track payments, and view statistics.

## 🚀 Features

- **User-Friendly Login**:
  - Seamless & secure authentication.
  - Easy account recovery & protection.
  
- **Dynamic Expense Management**:
  - Overview of all transactions and shared expenses.
  - Smart cost distribution among group members.

- **Firebase Integration**:
  - Real-time updates and sync of group transactions and balances
  - Utilizes Firestore for real-time, scalable storage and retrieval of user and transaction data
 
- **Modern User Interface**:
  - Intuitive design using Flutter widgets.
  - Responsive layout for multiple platforms (iOS, Android, Web).

- **Backend Architecture & Security**
  - Secure backend built with TypeScript and Google Cloud Functions, handling authentication, data validation, and error tracing scalable for millions of users.
  - Robust error logging, secure password management, and customized email handling ensure smooth user interactions while safeguarding sensitive information.

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
  - TypeScript for backend logic (in Backend branch)
  - nodeJS Cloud Functions
- **Configuration**: `flutter_dotenv` for environment variables.

## 🛠️ Installation

1. **Requirements**:
   - Install Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
   - Set up Firebase: [Firebase Console](https://console.firebase.google.com/)
   - Internet connection
   - Android Studio and  Chrome for Web builds

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/khaledffm02/Info_Projekt.git
   cd Info_Projekt\frontend
   flutter pub get

4. **Run the App:**
      ```bash
      flutter run -d chrome   //Web Version
