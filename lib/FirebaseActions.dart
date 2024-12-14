import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firebase_integration/main.dart';
import 'package:cloud_firebase_integration/Pages/welcome_ch1.dart';
import 'package:cloud_firebase_integration/Pages/welcome_ch2.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class FirebaseActions {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final  FirebaseActions instance = FirebaseActions._internal();

  factory FirebaseActions(){
      return instance;
  }

  FirebaseActions. _internal();

  // Initialize notifications
  Future<void> initializeNotification() async {
    // Request notification permissions
    final permisson =  await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    print(permisson.authorizationStatus);

    print('token: ${await _firebaseMessaging.getToken()}');

    // Initialize local notifications
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        final payloadData = response.payload;
        if (payloadData != null) {
          final channel = payloadData;
          _handleNavigation(channel);
        }
      },
    );

    // Create notification channel
    await setupNotificationChannel();

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Set up handlers for different app states
    handleNotification();           // Handle foreground messages
    handleBackgroundNotification();  // Handle background messages
    handleInitialMessage();         // Handle terminated state messages
  }

  // Create default notification channel
  Future<void> setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // Channel ID must match the AndroidManifest.xml
      'Default Channel', // Channel name
      description: 'This is the default notification channel',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle notifications when the app is in the foreground
  void handleNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      print('Handling notifications in the foreground!');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification}');
      print('Message android: ${message.notification?.android}');
      if (notification != null ) {
        _showLocalNotification(message);
      }
    });
  }

  // Handle notifications when the app is opened from the background
  void handleBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification!');
      print('Message data: ${message.data}');
      // Handle the message only when user taps the notification
      String? channel = message.data['channel'];
      if (channel != null) {
        _handleNavigation(channel);
      }
    });
  }

  // Handle notifications when the app is opened from a terminated state
  void handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App started from terminated state via notification!');
      // Handle the message only when user taps the notification
      String? channel = initialMessage.data['channel'];
      if (channel != null) {
        _handleNavigation(channel);
      }
    }
  }

  // Handle navigation based on channel
  void _handleNavigation(String channel) {
    if (channel == 'channel1') {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => WelcomeCh1()));
    } else if (channel == 'channel2') {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => WelcomeCh2()));
    }
  }

  // Show a local notification
  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'This is the default notification channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['channel'], // Pass the channel as payload
      );
    }
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}