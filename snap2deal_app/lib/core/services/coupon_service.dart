import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/models/coupon_model.dart';
import '../constants/api_constants.dart';

class CouponService {
  static Future<List<dynamic>> getUserCoupons(String userId) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/users/$userId/coupons"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> redeemCoupon({
    required String userId,
    required String couponId,
    required String merchantQrToken,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/scan/scan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "couponId": couponId,
        "merchantQrToken": merchantQrToken,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> fetchCouponsByMerchant(
  String merchantId,
) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString("userId");

  if (userId == null) {
    throw Exception("USER_NOT_LOGGED_IN");
  }

  final res = await http.get(
    Uri.parse(
      "${ApiConstants.baseUrl}/api/coupons/merchant/$merchantId",
    ),
    headers: {
      "Content-Type": "application/json",
      "userid": userId, // 🔑 auth middleware reads this
    },
  );

  if (res.statusCode == 200) {
    // 🔥 BACKEND RETURNS A MAP NOW
    return jsonDecode(res.body);
  }

  if (res.statusCode == 403) {
    throw Exception("SUBSCRIPTION_EXPIRED");
  }

  throw Exception("FAILED_TO_LOAD_COUPONS");
}



}
