
import 'package:flutter/material.dart';
import 'package:frontend/screens/intropages/intro_page_1.dart';
import 'package:frontend/screens/intropages/intro_page_2.dart';
import 'package:frontend/screens/notesgenerator/notes_chatscreen.dart';
import 'package:frontend/screens/signin_signup/signup_1.dart';
import 'package:frontend/screens/signin_signup/signup_2.dart';
import 'package:frontend/screens/youtbe_dis/youtube_dis.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesChatScreen(),
    );
  }
}
