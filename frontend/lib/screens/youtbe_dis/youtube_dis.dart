// lib/screens/chat_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/messages.dart';
import 'package:frontend/services/discription_api.dart';
import 'package:frontend/widgets/message_bubble.dart';
class DisChatScreen extends StatefulWidget {
  @override
  DisChatScreenState createState() => DisChatScreenState();
}

class DisChatScreenState extends State<DisChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  List<Message> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Load previous conversations from local storage
  void _loadChatHistory() async {
    // We'll implement this to load last 10 conversations
    final history = await _apiService.getChatHistory();
    setState(() {
      messages = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          PurpleWaveBackground(),
          // Main content
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
                          ' Description ',
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

                // Chat messages area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: messages[index],
                        onCopy: _copyToClipboard,
                      );
                    },
                  ),
                ),

                // Loading indicator
                if (isLoading)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6C5CE7), // Purple accent
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Searching...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input area
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    children: [
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
                              hintText: 'Tap here to start with Arora...',
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
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF8B5C86), // Purple
                                Color(0xFF6D28D9), // Darker purple
                              ],
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
                          child: Icon(
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

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Send to backend and get response
      final response = await _apiService.processMessage(text);

      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        canCopy: true, // Bot messages can be copied
      );

      setState(() {
        messages.add(botMessage);
        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(
          Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Sorry, there was an error processing your request.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        isLoading = false;
      });
    }
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          colors: [
            Color(0xFF2A0A4B), // deep purple black
            Color(0xFF000000), // fade to black
          ],
        ),
      ),
      child: Stack(
        children: [
          // Layered blurred glowing blobs
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

          // Floating light streaks
          Positioned(top: 220, left: 80, child: _lightStreak()),
          Positioned(bottom: 250, right: 100, child: _lightStreak()),
        ],
      ),
    );
  }

  /// Softer glow circle (layer-like background)
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
            blurRadius: size * 0.8, // large blur for softness
            spreadRadius: size * 0.3, // spread to blend
          ),
        ],
      ),
    );
  }

  /// Light streaks with blur
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