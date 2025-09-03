// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/messages.dart';

class ApiService {
  
  // ============ EXISTING YOUTUBE FUNCTIONALITY ============
  
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

  // ============ NEW NOTES FUNCTIONALITY ============

  /// Process text-based notes from syllabus or any text content
  /// [content] - The text content (syllabus, topics, etc.)
  /// [preferences] - User requirements like "5 pages", "highlight key concepts", etc.
  Future<String> processTextNotes(String content, String preferences) async {
    try {
      print('📝 Sending text notes request...');
      print('Content length: ${content.length} characters');
      print('Preferences: $preferences');
      
      final response = await http.post(
        Uri.parse('$baseUrl/notes/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'preferences': preferences,
          'contentType': 'syllabus'
        }),
      );
      
      print('📊 Notes response status: ${response.statusCode}');
      print('📦 Notes response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['notes'] ?? 'No notes generated';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to process notes: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Text notes error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Upload and process PDF file to generate notes
  /// [pdfFile] - The PDF file to process
  /// [preferences] - User requirements for the notes
  Future<String> processPDFNotes(File pdfFile, String preferences) async {
    try {
      print('📄 Uploading PDF: ${pdfFile.path}');
      print('File size: ${await pdfFile.length()} bytes');
      print('Preferences: $preferences');
      
      // Create multipart request for file upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/notes/upload'),
      );
      
      // Add the PDF file
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf', // This must match the multer field name in backend
          pdfFile.path,
          // Optionally specify content type
          // contentType: MediaType('application', 'pdf'),
        )
      );
      
      // Add user preferences as a form field
      request.fields['preferences'] = preferences;
      
      print('🚀 Sending PDF upload request...');
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 PDF response status: ${response.statusCode}');
      print('📦 PDF response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['notes'] ?? 'No notes generated from PDF';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to process PDF: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ PDF processing error: $e');
      throw Exception('PDF processing error: $e');
    }
  }

  /// Pick a PDF file from device storage
  /// Returns the selected File or null if cancelled
  Future<File?> pickPDFFile() async {
    try {
      print('📁 Opening file picker for PDF...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Only allow PDF files
        allowMultiple: false, // Single file selection
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          final file = File(filePath);
          print('✅ PDF selected: ${file.path}');
          print('File size: ${await file.length()} bytes');
          return file;
        }
      }
      
      print('❌ No PDF file selected');
      return null;
    } catch (e) {
      print('❌ File picker error: $e');
      throw Exception('Failed to pick PDF file: $e');
    }
  }

  /// Get notes chat history (separate from YouTube chat)
  /// This keeps notes and YouTube descriptions separate
  Future<List<Message>> getNotesHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('notes_history') ?? [];
      
      return historyJson
          .map((json) => Message.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Save notes chat history separately
  Future<void> saveNotesHistory(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last20 = messages.length > 20 
          ? messages.sublist(messages.length - 20) 
          : messages;
      
      final historyJson = last20
          .map((message) => jsonEncode(message.toJson()))
          .toList();
      
      await prefs.setStringList('notes_history', historyJson);
    } catch (e) {
      print('Error saving notes history: $e');
    }
  }

  /// Test connection to notes service
  Future<bool> testNotesConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notes/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Notes service connection test failed: $e');
      return false;
    }
  }
}