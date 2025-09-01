// lib/services/api_service.dart
import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/messages.dart';

class ApiService {
  
  Future<String> processMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/process_messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': message}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to process message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<List<Message>> getChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('chat_history') ?? [];
      
      return historyJson
          .map((json) => Message.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<void> saveChatHistory(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last10 = messages.length > 20 
          ? messages.sublist(messages.length - 20) 
          : messages;
      
      final historyJson = last10
          .map((message) => jsonEncode(message.toJson()))
          .toList();
      
      await prefs.setStringList('chat_history', historyJson);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }
}