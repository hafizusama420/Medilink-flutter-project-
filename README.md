# MediLink 🏥

**MediLink** is a modern, cross-platform medical management system built with **Flutter**, **GetX**, and **Firebase**. It provides a secure and seamless experience for users to manage their medical profiles, appointments, and healthcare services.

## 🚀 Features
- **Secure Authentication**: Email/Password registration with mandatory email verification.
- **MVVM Architecture**: Clean separation of concerns using Model-View-ViewModel pattern.
- **Reactive State Management**: Ultra-fast UI updates powered by GetX.
- **Comprehensive Profiles**: Customizable profiles for Patients, Doctors, and Admins.
- **Modern UI**: Polished Material Design 3 theme with professional medical aesthetics.
- **Cross-Platform**: Ready for Android, iOS, Web, Windows, macOS, and Linux.

## 🛠️ Technology Stack
- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Backend/Database**: [Firebase](https://firebase.google.com) (Auth, Firestore)
- **Fonts**: Poppins & Inter (via Google Fonts)

## 🏢 Architecture Overview
The project follows a modular and scalable **MVVM** structure:
- **Models**: Data structures for Firebase storage.
- **Views**: UI screens built with Flutter widgets.
- **ViewModels**: Business logic and state handling using GetX Controllers.
- **Services**: Core logic for Authentication and Database communication.

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Firebase Account & CLI
- Android Studio / VS Code

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/hafizusama420/Medilink-flutter-project-.git
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🔐 Security Measures
- Mandatory email verification for all users.
- Robust input validation on signup and login.
- Secure Firebase Security Rules for database protection.
- Protection against common auth exceptions.

---
*Developed as a semester project to demonstrate professional Flutter development practices.*