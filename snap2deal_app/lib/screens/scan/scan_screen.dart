import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/coupon_service.dart';

class ScanScreen extends StatelessWidget {
  final String couponId;
  const ScanScreen({required this.couponId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
       onDetect: (BarcodeCapture capture) async {
  final List<Barcode> barcodes = capture.barcodes;

  if (barcodes.isEmpty) return;

  final String? qrToken = barcodes.first.rawValue;

  if (qrToken == null) return;

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString("userId")!;

  final success = await CouponService.redeemCoupon(
    userId: userId,
    couponId: couponId,
    merchantQrToken: qrToken,
  );

  Navigator.pop(context, true);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "🎉 Coupon Redeemed Successfully"
            : "❌ Invalid or Used Coupon",
      ),
    ),
  );
},

      ),
    );
  }
}
