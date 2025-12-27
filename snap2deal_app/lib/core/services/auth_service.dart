import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AuthService {
  static Future<bool> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone}),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> verifyOtp(
      String phone, String otp, String name, String? email) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "otp": otp,
        "name": name,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
