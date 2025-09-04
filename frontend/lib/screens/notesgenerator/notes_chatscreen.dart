// screens/notes_chat_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              "Welcome back.\nShare your syllabus or a PDF,\nand I’ll create clear, focused notes for you. Just let me know your preferences, and we’ll get started.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  // All your existing functions (unchanged)
  void _pickPDF() async {
    try {
      final file = await _apiService.pickPDFFile();
      if (file != null) {
        setState(() {
          _selectedPDF = file;
        });

        // Add message showing PDF selected
        _addMessage("📄 PDF selected: ${file.path.split('/').last}", true);
        _addMessage(
          "Great! Now tell me how you'd like me to process this PDF. For example:\n• 'Summarize in 3 pages'\n• 'Create detailed notes with key concepts highlighted'\n• 'Make it simple for exam preparation'",
          false,
        );
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

        response = await _apiService.processTextNotes(
          text,
          "Create comprehensive notes",
        );
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
      _messages.add(
        Message(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              (_messages.length.toString()), // Generate unique ID
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PurpleWaveBackground(),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Notes Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PDF indicator
                if (_selectedPDF != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PDF selected: ${_selectedPDF!.path.split('/').last}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white70),
                          onPressed: () => setState(() => _selectedPDF = null),
                        ),
                      ],
                    ),
                  ),

                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),

                // Input area
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // PDF upload
                      GestureDetector(
                        onTap: _isLoading ? null : _pickPDF,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Input box
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: _selectedPDF != null
                                  ? 'How should I process this PDF?'
                                  : 'Lets get started....',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Send button
                      GestureDetector(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5C86), Color(0xFF6D28D9)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dark theme message bubbles
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
                color: message.isUser
                    ? Color(0xFF6D28D9).withOpacity(0.9)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Copy button
            if (!message.isUser &&
                !message.text.contains("🔄") &&
                !message.text.contains("❌"))
              Container(
                margin: EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => _copyToClipboard(message.text),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 16, color: Colors.white70),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: Colors.white70,
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

class PurpleWaveBackground extends StatelessWidget {
  const PurpleWaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0A4B), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -100,
            child: _glowLayer(300, Colors.purpleAccent.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -120,
            right: -150,
            child: _glowLayer(400, Colors.deepPurple.withOpacity(0.12)),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: _glowLayer(250, Colors.purple.withOpacity(0.1)),
          ),
          Positioned(top: 220, left: 80, child: _lightStreak()),
          Positioned(bottom: 250, right: 100, child: _lightStreak()),
        ],
      ),
    );
  }

  Widget _glowLayer(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.8,
            spreadRadius: size * 0.3,
          ),
        ],
      ),
    );
  }

  Widget _lightStreak() {
    return Container(
      width: 140,
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.0),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
