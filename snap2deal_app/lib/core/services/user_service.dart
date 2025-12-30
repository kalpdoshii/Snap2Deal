import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/constants/api_constants.dart';

class UserService {
  static Future<bool> updateProfile({
    required String name,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/user/update-profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "name": name,
        "email": email,
      }),
    );

    return response.statusCode == 200;
  }
}
