import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tale3ne/services/MessagesService.dart';
import 'package:tale3ne/models/Messages.dart' as MyAppMessage;
import 'package:web_socket_channel/io.dart';

class ChatFunctions {
  static Future<List<MyAppMessage.Message>> loadMessages(
      ChatService chatService,
      String userId,
      String otherUserId,
      List<MyAppMessage.Message> messages,
      ) async {
    try {
      final chatId = generateChatId(userId, otherUserId);
      final fetchedMessages = await chatService.getMessages(chatId);
      messages.clear();
      messages.addAll(fetchedMessages.cast<MyAppMessage.Message>());
      return messages; // Return the updated messages list
    } catch (e) {
      print('Error loading messages: $e');
      throw e; // rethrow the exception to propagate it
    }
  }

  static Future<void> sendMessage (
      ChatService chatService,
      IOWebSocketChannel channel,
      String userId,
      String otherUserId,
      String userName,
      String otherUserName,
      TextEditingController messageController,
      List<MyAppMessage.Message> messages,
      ScrollController _scrollController,
      ) async {
    final chatId = generateChatId(userId, otherUserId);
    final content = messageController.text;
    final UID = userId;
    final recipientUserId = otherUserId;
    final senderName = userName;

    try {
      final messageId = await chatService.sendMessage(
        chatId,
        content,
        UID,
        senderName,
        recipientUserId,
        otherUserName,
      );

      final messageData = {
        '_id': messageId,
        'UID': UID,
        'addtime': {
          '_seconds': DateTime.now().second,
          '_nanoseconds': DateTime.now().microsecond * 1000,
        },
        'content': content,
        'recipientUserId': recipientUserId,
        'senderName': senderName,
      };

      final messageJson = json.encode(messageData);
      print(messageJson);
      channel.sink.add(messageJson);

      final ownMessage = MyAppMessage.Message(
        id: messageData['_id'] as String,
        userId: messageData['UID'] as String,
        seconds: (messageData['addtime'] as Map<String, dynamic>)['_seconds'] as int,
        nanoseconds: (messageData['addtime'] as Map<String, dynamic>)['_nanoseconds'] as int,
        content: messageData['content'] as String,
        senderName: messageData['senderName'] as String,
      );

      messages.add(ownMessage);
      messageController.clear();
      scrollToBottom(_scrollController);

      // Return the messageId to signal completion
    } catch (e) {
      print('Error sending message: $e');
      // Rethrow the exception to propagate it
      throw e;
    }
  }


  static void scrollToBottom(ScrollController _scrollController) {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  static String generateChatId(String userId, String otherUserId) {
    if (userId.compareTo(otherUserId) < 0) {
      return '$userId$otherUserId';
    } else {
      return '$otherUserId$userId';
    }
  }
  static Widget buildMessage(MyAppMessage.Message message,userId) {
    return Align(
      alignment: message.userId == userId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: message.userId == userId
              ? Colors.blue
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.userId == userId
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
  static Widget buildInputArea(
      TextEditingController messageController, Function onPressedCallback) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => onPressedCallback(),
          ),
        ],
      ),
    );
  }

}
