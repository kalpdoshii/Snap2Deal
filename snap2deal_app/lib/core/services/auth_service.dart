import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  // 📲 SEND OTP
  static Future<bool> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone}),
    );

    return response.statusCode == 200;
  }

  // ✅ VERIFY OTP + SAVE USER
  static Future<bool> verifyOtp(
    String phone,
    String otp,
    String name,
    String? email,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "otp": otp,
        "name": name,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data["user"];

      // 🔐 SAVE USER DATA LOCALLY
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", user["_id"]);
      await prefs.setString("userPhone", user["phone"]);
      await prefs.setString("userName", user["name"] ?? "");
      await prefs.setString("userEmail", user["email"] ?? "");

      // 🎟 SAVE SUBSCRIPTION EXPIRY
      if (user["subscriptionExpiry"] != null) {
        await prefs.setString("subscriptionExpiry", user["subscriptionExpiry"]);
      } else {
        await prefs.remove("subscriptionExpiry");
      }

      // 🧪 DEBUG LOG (IMPORTANT)
      print("✅ USER SAVED: ${user["_id"]}");

      return true;
    }

    return false;
  }
}
