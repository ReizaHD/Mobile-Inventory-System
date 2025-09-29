# Mobile Inventory System

Mobile Inventory System — built with Flutter.  

## Table of Contents  
- [About](#about)  
- [Features](#features)  
- [Tech Stack](#tech-stack)  
- [Installation & Setup](#installation--setup)  
- [Usage](#usage)  
- [Project Structure](#project-structure)  

---

## About

This is a mobile inventory management app intended to simplify tracking and managing inventory items.  
The app supports cross-platform (Android, iOS, Windows, Web) via Flutter.  

## Features

Here are some features (you can tailor this list):

- Add / edit / delete inventory items  
- Search / filter items  
- Synchronization (if you have backend / cloud support)  
- Offline capability / local persistence  
- Multi‑platform support (Android, iOS, Web, Windows)  
- Role or user access (if applicable)  
- Google Maps integration (requires API key)  

## Tech Stack

- Flutter & Dart  
- Local persistence (e.g. SQLite, Hive, or other)  
- Firebase / backend (if used)  
- Google Maps SDK (requires API key)  
- Platform support: Android, iOS, Web, Windows  

## Installation & Setup

1. **Prerequisites**  
   - Flutter SDK (>= your version)  
   - An IDE: VS Code, Android Studio, etc.  
   - (If using Firebase) A Firebase project & config files  
   - A Google Maps API key  

2. **Clone the repo**

   ```bash
   git clone https://github.com/ReizaHD/Mobile-Inventory-System.git
   cd Mobile-Inventory-System
   ```

3. **Get dependencies**

   ```bash
   flutter pub get
   ```

4. **Add Google Maps API key**

   After running `flutter pub get`, open your `local.properties` file (located in the `/android` directory) and add the following line:

   ```properties
   MAPS_API_KEY=YOUR_API_KEY_HERE
   ```

   Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key.

5. **Platform-specific setup**

   - Android: ensure `android/app/google-services.json` (if using Firebase)  
   - iOS: ensure `ios/Runner/GoogleService-Info.plist` (if needed)  
   - Web / Windows: any config needed  

6. **Run**

   ```bash
   flutter run
   ```

## Usage

- Launch the app on your device or emulator  
- Sign in / authenticate (if there is auth)  
- Navigate inventory dashboard  
- Add items, search items, edit, delete  
- (If applicable) sync with cloud / server  

## Project Structure

Below is a simplified view of your repo structure (from what I saw):

```
/android  
/assets  
/ios  
/lib  
/test  
/web  
/windows  
.gitignore  
analysis_options.yaml  
firebase.json  
pubspec.yaml  
pubspec.lock  
README.md  
```

- `lib/` → main application code  
- `assets/` → static resources (images, icons, etc.)  
- `android/`, `ios/`, `web/`, `windows/` → platform-specific files  
- `test/` → unit or widget tests  
- `firebase.json` → Firebase configuration  
- `analysis_options.yaml` → lint / static analysis rules  

---
