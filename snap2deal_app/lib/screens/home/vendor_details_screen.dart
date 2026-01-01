import 'package:flutter/material.dart';
import '../scan/scan_screen.dart';

class VendorDetailsScreen extends StatelessWidget {
  final String vendorName;

  const VendorDetailsScreen({
    super.key,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(vendorName),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _couponCard(
            context: context, // ✅ PASS CONTEXT
            title: "Buy 2 Get 1 Free",
            subtitle: "Valid once per user",
            couponId: "coupon_buy2get1",
          ),
          _couponCard(
            context: context, // ✅ PASS CONTEXT
            title: "₹150 OFF on ₹500",
            subtitle: "Minimum bill ₹500",
            couponId: "coupon_flat150",
          ),
        ],
      ),
    );
  }

  Widget _couponCard({
    required BuildContext context, // ✅ ACCEPT CONTEXT
    required String title,
    required String subtitle,
    required String couponId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan to Redeem"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanScreen(
                      couponId: couponId,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
