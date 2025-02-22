import 'package:auto_hub/components/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyChatsScreen extends StatefulWidget {
  final User user;
  const MyChatsScreen({super.key, required this.user});

  @override
  State<MyChatsScreen> createState() => __MyChatsScreenState();
}

class __MyChatsScreenState extends State<MyChatsScreen> {
  final textController = TextEditingController();
  final CollectionReference _messages =
      FirebaseFirestore.instance.collection("messages");
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String currentUserName =
      FirebaseAuth.instance.currentUser!.displayName!;
  String? _editingMessageId;

  String currentMessage = "";

  void _sendMessage() async {
    if (textController.text.trim().isEmpty) return;

    if (_editingMessageId == null) {
      await _messages.add({
        'text': textController.text,
        'senderId': currentUserId,
        'senderName': currentUserName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await _messages.doc(_editingMessageId).update({
        'text': textController.text,
      });
      _editingMessageId = null;
    }

    textController.clear();
  }

  void _deleteMessage(String messageId) async {
    await _messages.doc(messageId).delete();
  }

  void _editMessage(String messageId, String currentText) {
    setState(() {
      _editingMessageId = messageId;
      textController.text = currentText;
    });
  }

  Stream<List<String>> messagesStream() {
    return FirebaseFirestore.instance
        .collection("messages")
        .snapshots()
        .map((snapshot) {
      final messages =
          snapshot.docs.map((e) => e["messages"] as String).toList();
      return messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      drawer: (Menu(user: widget.user)),
      appBar: AppBar(
        title: const Text('Conversas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _messages.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageId = message.id;
                    final messageData = message.data() as Map<String, dynamic>;
                    final isMine = messageData['senderId'] == currentUserId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            messageData['senderName'] ?? 'Desconhecido',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isMine ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              messageData['text'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (isMine)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () => _editMessage(
                                      messageId, messageData['text']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteMessage(messageId),
                                ),
                              ],
                            ),
                        ],
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
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
