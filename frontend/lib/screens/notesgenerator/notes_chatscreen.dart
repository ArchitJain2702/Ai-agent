// screens/notes_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:file_picker/file_picker.dart';
import 'package:frontend/models/messages.dart';
import 'package:frontend/services/discription_api.dart';
import 'dart:io';

class NotesChatScreen extends StatefulWidget {
  @override
  _NotesChatScreenState createState() => _NotesChatScreenState();
}

class _NotesChatScreenState extends State<NotesChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  File? _selectedPDF;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

 void _addWelcomeMessage() {
  setState(() {
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hi! I'm your notes assistant. You can:\n\n• Type or paste your syllabus and I'll create notes\n• Upload a PDF and I'll summarize it\n• Specify requirements like '5 pages', 'simple language', 'highlight key concepts'\n\nHow can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  });
}

  void _pickPDF() async {
    try {
      final file = await _apiService.pickPDFFile();
      if (file != null) {
        setState(() {
          _selectedPDF = file;
        });
        
        // Add message showing PDF selected
        _addMessage("📄 PDF selected: ${file.path.split('/').last}", true);
        _addMessage("Great! Now tell me how you'd like me to process this PDF. For example:\n• 'Summarize in 3 pages'\n• 'Create detailed notes with key concepts highlighted'\n• 'Make it simple for exam preparation'", false);
      }
    } catch (e) {
      _showError('Failed to pick PDF: $e');
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedPDF == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String response;
      
      if (_selectedPDF != null) {
        // Process PDF with user's requirements
        _addMessage(text, true); // Add user's requirements message
        _addMessage("🔄 Processing your PDF... This may take a moment.", false);
        
        response = await _apiService.processPDFNotes(_selectedPDF!, text);
        
        // Clear selected PDF after processing
        setState(() {
          _selectedPDF = null;
        });
      } else {
        // Process text-based notes
        _addMessage(text, true);
        _addMessage("🔄 Creating notes from your content...", false);
        
        response = await _apiService.processTextNotes(text, "Create comprehensive notes");
      }

      // Remove loading message and add AI response
      setState(() {
        if (_messages.isNotEmpty && _messages.last.text.contains("🔄")) {
          _messages.removeLast();
        }
      });
      
      _addMessage(response, false);
      
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && _messages.last.text.contains("🔄")) {
          _messages.removeLast();
        }
      });
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _messageController.clear();
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + (_messages.length.toString()),
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String error) {
    _addMessage("❌ $error", false);
  }

  // New method to copy message to clipboard
  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    // Show a snackbar to confirm copy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Message copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 Notes Assistant'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // PDF Selection indicator
          if (_selectedPDF != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PDF selected: ${_selectedPDF!.path.split('/').last}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => setState(() => _selectedPDF = null),
                  ),
                ],
              ),
            ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // PDF upload button
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.blue.shade700),
                  onPressed: _isLoading ? null : _pickPDF,
                  tooltip: 'Upload PDF',
                ),
                
                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _selectedPDF != null 
                          ? 'How should I process this PDF?'
                          : 'Type syllabus or describe what notes you need...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: message.isUser ? 50 : 0,
          right: message.isUser ? 0 : 50,
        ),
        child: Column(
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade700 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Copy button for AI messages only
            if (!message.isUser && !message.text.contains("🔄") && !message.text.contains("❌"))
              Container(
                margin: EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => _copyToClipboard(message.text),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}