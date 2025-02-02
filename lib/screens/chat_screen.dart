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

  String currentMessage = "";

  Future<void> getMessages() async {
    //   final messagesSnapshot =
    //   await FirebaseFirestore.instance.collection("messages").get();
    //   setState(() {
    //     messages.clear();
    //     for (final message in messagesSnapshot.docs) {
    //       messages.add(message["message"]);
    //     }
    //   });
  }

  Future<void> addMessage(String message) async {
    await FirebaseFirestore.instance
        .collection("messages")
        .add({"message": message});
    // setState(() {
    //   messages.add(message);
    // });
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
  void initState() {
    super.initState();
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: (Menu(user: widget.user)),
      appBar: AppBar(
        title: const Text('Minhas Conversas'),
      ),
      body: StreamBuilder<List<String>>(
          stream: messagesStream(),
          builder: (context, snapshot) {
            final messages = snapshot.data ?? [];
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            );
          }),
      bottomSheet: SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: textController,
              onChanged: (value) {
                currentMessage = value;
              },
            )),
            IconButton(
                onPressed: () {
                  if (currentMessage.isNotEmpty) {
                    textController.clear();
                    addMessage(currentMessage);
                  }
                },
                icon: const Icon(Icons.send))
          ],
        ),
      ),
    );
  }
}
