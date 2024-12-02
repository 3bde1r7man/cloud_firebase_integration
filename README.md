# Cloud Firebase Integration

## Overview
This project explores Firebase integration with Flutter by implementing two key functionalities:
  **1. Dynamic Notification Channels with Firebase Cloud Messaging (FCM):**
    - Build a system to allow users to subscribe to topics (channels) and receive targeted notifications.
    - Notifications are tested in both foreground and background states.
  **2. Real-Time Channel Communication with Firebase Databases:**
    - Extend the setup by enabling real-time communication within notification channels.
    - Utilize *Firestore* for managing channel data and user subscriptions and *Firebase Realtime Database* for chat rooms.

## Features
  **Dynamic Notification Channels**
    - Subscribe to/unsubscribe from notification channels (topics).
    - Receive push notifications targeted to:
      * All users.
      * Specific topics.
      * Specific devices.
    - Notifications handled seamlessly in both app states: foreground and background.
  **Real-Time Channel Communication**
    - Firestore Integration:
      * Manage channel data (add, remove, list).
      * Store and retrieve user subscriptions persistently.
    - Realtime Database Integration:
      * Create chat rooms for each channel.
      * Real-time messaging functionality for immediate interaction.
    - Chat Interface:
      * Post messages to channels.
      * View messages from other users in real time.

## Setup Instructions
  **Prerequisites**
    - Flutter SDK and Android Studio/Visual Studio Code installed.
    - Firebase project set up in the Firebase Console.
  **1. Clone the Repository**
    `git clone https://github.com/3bde1r7man/cloud_firebase_integration.git`
    `cd cloud_firebase_integration`
  **2. Install Dependencies**
    Run the following command to fetch required Flutter packages:
    `flutter pub get`
  **3. Configure Firebase**
    - Firebase Cloud Messaging (FCM):
      1. Go to Firebase Console.
      2. Add a new project (or use an existing one).
      3. Add your app (Android/iOS/web) with the package name found in `android/app/src/main/AndroidManifest.xml`.
        *Note:* We used here *Android*.
      4. Download the `google-services.json` file and place it in `android/app/`.
      5. Modify `android/build.gradle` and `android/app/build.gradle` according to Firebase setup instructions.
    - Firestore and Realtime Database:
      1. Enable *Cloud Firestore* and *Realtime Database* in Firebase Console.
      2. Set appropriate rules for both databases to allow development access.
  **4. Run the Application**
    `flutter run`

## Usage
  **Dynamic Notification Channels**
    1. Subscribe/Unsubscribe to Topics:
      - Open the app to view the list of channels.
      - Tap a channel to subscribe or unsubscribe.
    2. Send Notifications:
      - Navigate to Firebase Console > Cloud Messaging.
      - Test notifications by targeting:
        * All users.
        * A specific topic.
        * Specific devices (using device tokens).
    3. Test Notifications:
      - *Foreground:* Notifications appear as app pop-ups.
      - *Background:* Notifications are displayed in the system tray.
  **Real-Time Channel Communication**
    1. Manage Channels (Firestore):
      - Add, remove, or list channels in the app interface.
    2. Chat Rooms (Realtime Database):
      - Select a channel to open its chat room.
      - Post messages to the channel and view others' messages in real time.

## Experience
  Working on this project provided valuable insights into Firebase's powerful tools for building scalable real-time applications.
  **Firebase Cloud Messaging (FCM)**
    - Learned to configure push notifications for both app states (foreground/background).
    - Overcame challenges with device tokens and version mismatches during setup.
  **Firestore and Realtime Database**
    - Discovered the strengths of *Firestore* for structured data and user subscription persistence.
    - Experienced the real-time capabilities of *Firebase Realtime Database* for chat messaging.
  **Challenges and Solutions**
    - *Version Conflicts:* Resolved dependency mismatches using flutter pub outdated and updated necessary packages.
    - *Testing on Devices:* Debugged and optimized notification behavior across emulators and physical devices.

This project solidifies Firebase’s role in delivering scalable and real-time app functionalities, preparing me for more advanced use cases in the future.
