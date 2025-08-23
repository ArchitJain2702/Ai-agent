import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  // ===== SIGNUP FLOW =====

  // Step 1: Request OTP for signup
  static Future<Map<String, dynamic>> signupRequestOtp(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signup/request-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  // Step 2: Verify OTP for signup
  static Future<Map<String, dynamic>> signupVerifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signup/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return jsonDecode(response.body);
  }

  // Step 3: Complete signup (profile details)
  static Future<Map<String, dynamic>> signupComplete({
    required String signupToken,
    required String name,
    String? gender,
    String? occupation,
    String? extraDetails,
    String? phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signup/complete"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "signupToken": signupToken,
        "name": name,
        "gender": gender,
        "occupation": occupation,
        "extraDetails": extraDetails,
        "phoneNumber": phoneNumber,
      }),
    );
    return jsonDecode(response.body);
  }

  // ===== SIGNIN FLOW =====

  // Step 1: Request OTP for signin
  static Future<Map<String, dynamic>> signinRequestOtp(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signin/request-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  // Step 2: Verify OTP for signin
  static Future<Map<String, dynamic>> signinVerifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signin/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return jsonDecode(response.body);
  }
}
