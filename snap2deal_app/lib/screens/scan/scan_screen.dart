import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/coupon_service.dart';
import 'coupon_redemption_timer_screen.dart';

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

          // Get coupon details
          final coupon = await CouponService.getCouponById(couponId);
          if (coupon == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coupon not found')),
            );
            Navigator.pop(context);
            return;
          }

          // Scan coupon and create redemption record
          final redemption = await CouponService.scanCoupon(
            couponId: couponId,
            userId: userId,
          );

          if (redemption != null) {
            // Navigate to redemption timer screen
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CouponRedemptionTimerScreen(
                    coupon: coupon,
                    userId: userId,
                    redemption: redemption,
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error scanning coupon')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

