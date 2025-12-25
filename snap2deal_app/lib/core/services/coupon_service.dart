import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class CouponService {
  static Future<List<dynamic>> getUserCoupons(String userId) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/users/$userId/coupons"),
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
      Uri.parse("${ApiConstants.baseUrl}/scan/scan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "couponId": couponId,
        "merchantQrToken": merchantQrToken,
      }),
    );

    return response.statusCode == 200;
  }
}
