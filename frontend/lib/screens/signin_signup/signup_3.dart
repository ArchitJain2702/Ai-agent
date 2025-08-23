import 'package:flutter/material.dart';
import 'package:frontend/services/auth_services.dart';

class SignupCompletePage extends StatefulWidget {
  final String signupToken;
  const SignupCompletePage({super.key, required this.signupToken});

  @override
  State<SignupCompletePage> createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends State<SignupCompletePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _extraDetailsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  void _completeSignup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signupComplete(
        signupToken: widget.signupToken,
        name: name,
        gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
        extraDetails: _extraDetailsController.text.trim().isEmpty ? null : _extraDetailsController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Signup completed ✅")),
        );

        // ✅ Navigate to Login or Home Page
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Signup failed ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name (required)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(
                labelText: "Gender (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: "Occupation (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _extraDetailsController,
              decoration: const InputDecoration(
                labelText: "Extra Details (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number (optional)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeSignup,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Complete Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

