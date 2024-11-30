import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State createState() => _HomePageState();
}

class _HomePageState extends State {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Firebase Integration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _firebaseMessaging.subscribeToTopic('channel1');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subscribed to Channel 1')),
                );
              },
              child: Text('Subscribe to Channel 1'),
            ),
            ElevatedButton(
              onPressed: () {
                _firebaseMessaging.subscribeToTopic('channel2');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subscribed to Channel 2')),
                );
              },
              child: Text('Subscribe to Channel 2'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _firebaseMessaging.unsubscribeFromTopic('channel1');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unsubscribed from Channel 1')),
                );
              },
              child: Text('Unsubscribe from Channel 1'),
            ),
            ElevatedButton(
              onPressed: () {
                _firebaseMessaging.unsubscribeFromTopic('channel2');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unsubscribed from Channel 2')),
                );
              },
              child: Text('Unsubscribe from Channel 2'),
            ),
          ],
        ),
      ),
    );
  }
}
