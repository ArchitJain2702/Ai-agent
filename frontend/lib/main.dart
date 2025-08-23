
import 'package:flutter/material.dart';
import 'package:frontend/screens/intropages/intro_page_1.dart';
import 'package:frontend/screens/intropages/intro_page_2.dart';
import 'package:frontend/screens/signin_signup/signup_1.dart';
import 'package:frontend/screens/signin_signup/signup_2.dart';

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
      home: SignupOtpPage(email: 'architjain877@gmail.com'),
    );
  }
}
