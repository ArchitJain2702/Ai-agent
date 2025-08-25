// lib/models/message.dart
class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool canCopy;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.canCopy = false,
  });

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'canCopy': canCopy,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    canCopy: json['canCopy'] ?? false,
  );
}