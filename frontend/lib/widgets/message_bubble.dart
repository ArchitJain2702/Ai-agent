// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/messages.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String) onCopy;

  MessageBubble({required this.message, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser 
           ? MainAxisAlignment.end 
           : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                   ? Colors.white.withOpacity(0.15)
                   : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: message.isUser 
                     ? Radius.circular(18) 
                     : Radius.circular(4),
                  bottomRight: message.isUser 
                     ? Radius.circular(4) 
                     : Radius.circular(18),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  
                  if (message.canCopy)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () => onCopy(message.text),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
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
          ),
        ],
      ),
    );
  }
}