import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class PaymentService {
  static Razorpay _razorpay = Razorpay();

  static void init(
    Function(PaymentSuccessResponse) onSuccess,
    Function(PaymentFailureResponse) onError,
  ) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
  }

  static void clear() {
    _razorpay.clear();
  }

  static Future<void> startPayment(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/payment/create-order"),
      headers: {
        "Content-Type": "application/json",
        "userid": userId!,
      },
      body: jsonEncode({ "amount": amount }),
    );

    final order = jsonDecode(res.body);

    _razorpay.open({
      "key": "rzp_test_xxxxx", // your key id
      "amount": order["amount"],
      "order_id": order["id"],
      "name": "Snap2Deal",
      "description": "Premium Membership",
      "prefill": {
        "contact": prefs.getString("userPhone"),
        "email": prefs.getString("userEmail"),
      },
    });
  }

  static Future<void> verifyPayment(
    PaymentSuccessResponse response,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/payment/verify"),
      headers: {
        "Content-Type": "application/json",
        "userid": userId!,
      },
      body: jsonEncode({
        "razorpay_order_id": response.orderId,
        "razorpay_payment_id": response.paymentId,
        "razorpay_signature": response.signature,
      }),
    );
  }
}
