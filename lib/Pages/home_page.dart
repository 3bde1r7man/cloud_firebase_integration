import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'ChatRoomPage.dart'; // Import ChatRoomPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _channelController = TextEditingController();
  final int USERID = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Channels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      labelText: 'Channel Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addChannel,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('channels').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No channels found.'),
                    );
                  }

                  final channels = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      final channelName = channel['name'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('channels').doc(channel.id).get(),
                        builder: (context, channelSnapshot) {
                          if (channelSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final channelData = channelSnapshot.data?.data() as Map<String, dynamic>;
                          final subscribedUsers = List<int>.from(channelData?['users'] ?? []);

                          if (!subscribedUsers.contains(USERID)) {
                            return ListTile(
                              title: Text(channelName),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_active),
                                    onPressed: () {
                                      _subscribeToChannel(channelName);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _removeChannel(channel.id);
                                    },
                                  ),
                                ]
                              ),
                            );
                          }

                          return ListTile(
                            title: Text(channelName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_off),
                                  onPressed: () {
                                    _unsubscribeFromChannel(channelName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _removeChannel(channel.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(channelName: channelName),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addChannel() async {
    final channelName = _channelController.text.trim();

    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel name cannot be empty.')),
      );
      return;
    }

    if (channelName.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel name cannot contain spaces.')),
      );
      return;
    }

    final channelExists = await _firestore
        .collection('channels')
        .where('name', isEqualTo: channelName)
        .get()
        .then((value) => value.docs.isNotEmpty);

    if (channelExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel already exists.')),
      );
      return;
    }

    try {
      await _firestore.collection('channels').add({'name': channelName, 'users': []});
      _channelController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Channel "$channelName" added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add channel: $e')),
      );
    }
  }

  Future<void> _removeChannel(String channelId) async {
    try {
      await _firestore.collection('channels').doc(channelId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel removed successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove channel: $e')),
      );
    }
  }

  void _subscribeToChannel(String channelName) async {
    try {
      await _firebaseMessaging.subscribeToTopic(channelName);
      final querySnapshot = await _firestore
          .collection('channels')
          .where('name', isEqualTo: channelName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final channelId = querySnapshot.docs.first.id;

        await _firestore.collection('channels').doc(channelId).update({
          'users': FieldValue.arrayUnion([USERID]) // Add user ID to the array
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscribed to $channelName and added user ID.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Channel $channelName not found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to subscribe to $channelName: $e')),
      );
    }
  }

  void _unsubscribeFromChannel(String channelName) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(channelName);
      final querySnapshot = await _firestore
          .collection('channels')
          .where('name', isEqualTo: channelName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final channelId = querySnapshot.docs.first.id;

        await _firestore.collection('channels').doc(channelId).update({
          'users': FieldValue.arrayRemove([USERID]) // Remove user ID from the array
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unsubscribed from $channelName and removed user ID.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Channel $channelName not found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsubscribe from $channelName: $e')),
      );
    }
  }
}
