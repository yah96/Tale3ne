import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tale3ne/models/Messages.dart';
import 'package:tale3ne/services/RequestsServices.dart';

class ChatService {
  final String baseUrl = RequestsServices.baseUrl;

  Future<String> getChats(String userId) async {
    final url = Uri.parse('$baseUrl/chats/$userId/messages');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to retrieve chats');
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/getMessages');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> messageList = data['messages'];

      final List<Message> messages = messageList
          .map<Message>((message) => Message.fromJson(message))
          .toList();
      return messages;
    } else {
      throw Exception('Failed to retrieve messages');
    }
  }



  Future<String> sendMessage(
      String chatId,
      String content,
      String uid,
      String fromName,
      String toId,
      String toName,
      ) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/messages');

    final body = json.encode({
      'content': content,
      'UID': uid, // User's own UID
      'from_ID': uid,
      'from_name': fromName,
      'lastMessage': content,
      'to_ID' : toId,
      'to_name' : toName,
      'addtime': "",
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String messageId = data['messageId'];
      return messageId;
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<String> createChat() async {
    final url = Uri.parse('$baseUrl/chats');
    final response = await http.post(url);

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['chatId'];
    } else {
      throw Exception('Failed to create chat');
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/messages/$messageId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  Future<void> deleteChat(String chatId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete chat');
    }
  }
}
