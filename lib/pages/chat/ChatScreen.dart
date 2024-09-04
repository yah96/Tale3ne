import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tale3ne/services/MessagesService.dart';
import 'package:tale3ne/models/Messages.dart' as MyAppMessage;
import 'package:web_socket_channel/io.dart';
import 'package:tale3ne/pages/chat/ChatFunctions.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String otherUserId;
  final String otherUserName;
  final String userName;
  Future<void> handleSendMessage() async {
    // TODO: implement handleSendMessage
    throw UnimplementedError();
  }
  ChatScreen({
    required this.userId,
    required this.userName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  TextEditingController messageController = TextEditingController();
  List<MyAppMessage.Message> messages = [];
  final channel = IOWebSocketChannel.connect('ws://192.168.1.105:3001');
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      messages = await ChatFunctions.loadMessages(
          chatService, widget.userId, widget.otherUserId, messages);
      ChatFunctions.scrollToBottom(_scrollController);

      channel.sink.add(json.encode({
        'action': 'connect',
        'UID': widget.userId,
      }));
      channel.stream.listen(
            (message) {
          try {
            final messageData = json.decode(message);
            print(message);
            final newMessage = MyAppMessage.Message.fromJson(messageData);
            setState(() {
              messages.add(newMessage);
              ChatFunctions.scrollToBottom(_scrollController);
            });
          } catch (e) {
            print('Error decoding or handling message: $e');
          }
        },
        onError: (error) {
          print('Error in channel.stream.listen: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
      // Set loading state to false after messages are loaded
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle error from loading messages
      print('Error loading messages: $e');
      // Set loading state to false even in case of an error
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.otherUserName),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatFunctions.buildMessage(message,widget.userId);
                },
              ),
            ),
            ChatFunctions.buildInputArea(messageController,handleSendMessage),
          ],
        ),
      ),
    );
  }
  Future<void> handleSendMessage() async {
    try {
      await ChatFunctions.sendMessage(
        chatService,
        channel,
        widget.userId,
        widget.otherUserId,
        widget.userName,
        widget.otherUserName,
        messageController,
        messages,
        _scrollController,
      );
      setState(() {});
    } catch (e) {
      print('Error handling send message: $e');
    }
  }
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}