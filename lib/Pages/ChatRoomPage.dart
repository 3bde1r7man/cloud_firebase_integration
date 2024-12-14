import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatRoomPage extends StatefulWidget {
  final String channelName;

  const ChatRoomPage({Key? key, required this.channelName}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.channelName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _database.child('channels/${widget.channelName}/messages').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages.'));
                }

                final messages = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                if (messages == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messageList = messages.entries.map((entry) {
                  final data = entry.value as Map<dynamic, dynamic>;
                  return {
                    "userId": data['userId'],
                    "message": data['message'],
                    "timestamp": data['timestamp']
                  };
                }).toList()
                  ..sort((a, b) => a['timestamp'].compareTo(b['timestamp'])); // Sort by timestamp

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text('User: ${message['userId']}'),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                                message['timestamp'] * 1000)
                            .toLocal()
                            .toString(),
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database
        .child('channels/${widget.channelName}/messages')
        .push()
        .set({
      'userId': _auth.currentUser!.uid,
      'message': message,
      'timestamp': timestamp,
    });

    _messageController.clear();
  }
}
