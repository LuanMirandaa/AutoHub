import 'package:auto_hub/components/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  final String chatId;
  final String currentUserId;
  final String otherUserId;

  const ChatScreen(
      {super.key,
      required this.user,
      required this.chatId,
      required this.currentUserId,
      required this.otherUserId});

  @override
  State<ChatScreen> createState() => __ChatScreenState();
}

class __ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editMessageController = TextEditingController();
  //final CollectionReference _messages = FirebaseFirestore.instance.collection("messages");
  //final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //final String currentUserName = FirebaseAuth.instance.currentUser!.displayName!;
  String? _editingMessageId;
  String? otherUserName;



  //String currentMessage = "";

  // void _sendMessage() async {
  //   if (textController.text.trim().isEmpty) return;

  //   if (_editingMessageId == null) {
  //     await _messages.add({
  //       'text': textController.text,
  //       'senderId': currentUserId,
  //       'senderName': currentUserName,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } else {
  //     await _messages.doc(_editingMessageId).update({
  //       'text': textController.text,
  //     });
  //     _editingMessageId = null;
  //   }

  //   textController.clear();
  // }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId,
        'message': message,
        'timestamp': DateTime.now(),
        'isDeleted': false,
        'edited': false,
      });
      _messageController.clear();
    }
  }

  // void _deleteMessage(String messageId) async {
  //   await _messages.doc(messageId).delete();
  // }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isDeleted': true});
  }

  // void _editMessage(String messageId, String currentText) {
  //   setState(() {
  //     _editingMessageId = messageId;
  //     textController.text = currentText;
  //   });
  // }

  void _startEditingMessage(String messageId, String currentMessage) {
    setState(() {
      _editingMessageId = messageId;
      _editMessageController.text = currentMessage;
    });
  }

  void _updateMessage() {
    final updatedMessage = _editMessageController.text.trim();
    if (updatedMessage.isNotEmpty && _editingMessageId != null) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(_editingMessageId)
          .update({
        'message': updatedMessage,
        'edited': true,
      });
      setState(() {
        _editingMessageId = null;
        _editMessageController.clear();
      });
    }
  }

  // Stream<List<String>> messagesStream() {
  //   return FirebaseFirestore.instance
  //       .collection("messages")
  //       .snapshots()
  //       .map((snapshot) {
  //     final messages =
  //         snapshot.docs.map((e) => e["messages"] as String).toList();
  //     return messages;
  //   });
  // }

  void _showMessageOptions(
      BuildContext context, String messageId, String currentMessage) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Mensagem'),
                onTap: () {
                  Navigator.pop(context);
                  _startEditingMessage(messageId, currentMessage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Excluir Mensagem'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteMessageDialog(context, messageId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteMessageDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Mensagem'),
          content: const Text('Tem certeza que deseja excluir essa mensagem?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.pop(context); // Fecha o diálogo
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

   @override
  void initState() {
    super.initState();
    // Inicializando a variável com base no widget.title
    //otherUserName = FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get().toString();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      final userData = snapshot.data() as Map<String, dynamic>;
      final name = userData['name'] as String?;
      
      if (name != null && name.isNotEmpty) {
        setState(() {
          otherUserName = name;
        });
      } else {
        setState(() {
          otherUserName = 'Nome não disponível';
        });
      }
    } else {
      setState(() {
        otherUserName = 'Usuário não encontrado';
      });
    }
  } catch (e) {
    setState(() {
      otherUserName = 'Erro ao carregar nome';
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      drawer: (Menu(user: widget.user)),
      appBar: AppBar(
        title: Text(
    otherUserName ?? 'Carregando...',
  ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  //_messages.orderBy('timestamp', descending: true).snapshots(),
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageId = messages[index].id;
                    final messageData = message.data() as Map<String, dynamic>;
                    final isMine =
                        messageData['senderId'] == widget.currentUserId;
                    final isDeleted = messageData['isDeleted'] == true;
                    final isEdited = messageData['edited'] == true;

                    if (isDeleted) {
                      return const ListTile(
                        title: Text(
                          'Essa mensagem foi excluída.',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      );
                      
                    }

                    return GestureDetector(
                      onLongPress: () {
                        if (isMine) {
                          _showMessageOptions(
                              context, messageId, messageData['message']);
                        }
                      },
                      child: Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: isMine ? const Color.fromARGB(151, 141, 11, 201) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                messageData['message'],
                                style: TextStyle(
                                    color:
                                        isMine ? Colors.white : Colors.black),
                              ),
                              if (isEdited)
                                Text(
                                  'Edited',
                                  style: TextStyle(
                                    color: isMine
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_editingMessageId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editMessageController,
                      decoration: const InputDecoration(
                        hintText: 'Edite sua mensagem...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _updateMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _editingMessageId = null;
                        _editMessageController.clear();
                      });
                    },
                  ),
                ],
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
                      hintText: 'Digite a mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
