import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ScanService {
  static Future<bool> redeemCoupon({
    required String vendorId,
    required String couponType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/scan/redeem"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "vendorId": vendorId,
        "couponType": couponType,
      }),
    );

    return res.statusCode == 200;
  }
}
