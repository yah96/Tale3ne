import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tale3ne/services/MessagesService.dart';
import 'package:tale3ne/models/Chats.dart';
import 'package:tale3ne/pages/chat/ChatScreen.dart';

class ChatsPage extends StatefulWidget {
  final String id;
  final String name;

  ChatsPage({required this.id, required this.name});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService chatService = ChatService();
  TextEditingController messageController = TextEditingController();
  List<Chats> chats = [];

  @override
  void initState() {
    super.initState();
    // Load chats when the chat screen is initialized
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      final chatId = widget.id;
      final jsonString = await chatService.getChats(chatId);
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<Chats> fetchedChats = data['chats']
          .map<Chats>((chat) => Chats.fromJson(chat))
          .toList();

      setState(() {
        chats = fetchedChats.cast<Chats>();
      });
    } catch (e) {
      print('Error loading chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final otherUserId = chat.fromId == widget.id ? chat.toId : chat.fromId;
          final otherUserName = chat.fromId == widget.id ? chat.toName : chat.fromName;

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                otherUserName, // Display the other user's name
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: chat.lastMessage != null
                  ? Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              )
                  : null,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userId: widget.id,
                      userName: widget.name,
                      otherUserId: otherUserId,
                      otherUserName: otherUserName,
                    ),
                  ),
                );

                // Check if there's any result from the ChatScreen
                if (result != null && result is bool && result) {
                  // Reload chats when returning from ChatScreen
                  await loadChats();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
