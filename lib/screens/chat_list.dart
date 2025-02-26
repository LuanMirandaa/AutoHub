import 'dart:developer';

import 'package:auto_hub/components/menu.dart';
import 'package:auto_hub/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatefulWidget {
  final User user;

  const ChatListScreen({super.key, required this.user});

  @override
  State<ChatListScreen> createState() => __ChatListScreenState();
}

class __ChatListScreenState extends State<ChatListScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<QueryDocumentSnapshot>> fetchChats() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: (Menu(user: widget.user)),
      appBar: AppBar(
        title: const Text('Conversas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            //.orderBy('lastMessageTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sem conversas ativas.\n Começe a conversar em um anúncio!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;
              final participants = chat['participants'] as List<dynamic>;
              final otherUserId =
                  participants.firstWhere((id) => id != currentUserId);

              final lastMessage =
                  chat['lastMessage'] as String? ?? 'Sem mensagens';
              final lastMessageTimestamp =
                  (chat['lastMessageTimestamp'] as Timestamp).toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Carregando..'),
                    );
                  }
                  final user =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final otherUserName =
                      user['name'] as String? ?? 'Usuário desconhecido';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['avatarImage'] != null &&
                              user['avatarImage']!.isNotEmpty
                          ? NetworkImage(user['avatarImage'])
                          : AssetImage('assets/images/avatar.png')
                              as ImageProvider,
                      radius: 25,
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(lastMessage),
                    trailing: Text(
                      '${lastMessageTimestamp.day}/${lastMessageTimestamp.month}/${lastMessageTimestamp.year}  ${lastMessageTimestamp.hour}:${lastMessageTimestamp.minute}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (chatId == null ||
                                currentUserId == null ||
                                otherUserId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Erro ao carregar chat: dados inválidos!')),
                              );
                              return Container(); // Evita o erro ao tentar navegar com valores nulos
                            }

                            return ChatScreen(
                              user: FirebaseAuth.instance.currentUser!,
                              chatId: chatId!,
                              currentUserId: currentUserId!,
                              otherUserId: otherUserId!,
                            );
                          },
                        ),
                      );
                    },
                    onLongPress: () {
                      _showDeleteChatDialog(context, chatId);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers(String currentUserId) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .get();

    return usersSnapshot.docs.map((doc) => doc.data()).toList();
  }


  String _generateChatId(String userId1, String userId2) {
    // Generate a unique chat ID by sorting user IDs
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  void _showDeleteChatDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Conversa'),
          content: const Text(
              'Tem certeza que deseja excluir essa conversa? \n Todas as mensagens serão perdidas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteChat(chatId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(String chatId) {
    FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  }
}
