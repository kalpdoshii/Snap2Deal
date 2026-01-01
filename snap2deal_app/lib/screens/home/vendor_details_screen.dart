import 'package:flutter/material.dart';
import 'package:snap2deal_app/core/models/coupon_model.dart';
import 'package:snap2deal_app/core/services/coupon_service.dart';
import 'package:snap2deal_app/screens/subscription/subscription_screen.dart';
import '../scan/scan_screen.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String vendorName;
  final String merchantId;

  const VendorDetailsScreen({
    super.key,
    required this.vendorName,
    required this.merchantId,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  late Future<Map<String, dynamic>> couponsFuture;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  void _loadCoupons() {
    couponsFuture =
        CouponService.fetchCouponsByMerchant(widget.merchantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(widget.vendorName),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: couponsFuture,
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          // ✅ NEW RESPONSE STRUCTURE
          final data = snapshot.data!;
          final bool isSubscribed = data["isSubscribed"] ?? false;
          final List couponsJson = data["coupons"] ?? [];

          if (couponsJson.isEmpty) {
            return const Center(child: Text("No coupons available"));
          }

          final coupons =
              couponsJson.map((e) => Coupon.fromJson(e)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              return _couponCard(
                context,
                coupons[index],
                isSubscribed,
              );
            },
          );
        },
      ),
    );
  }

  // 🧾 COUPON CARD WITH LOCK LOGIC
  Widget _couponCard(
    BuildContext context,
    Coupon coupon,
    bool isSubscribed,
  ) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isSubscribed)
                const Icon(Icons.lock, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            coupon.description,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSubscribed ? Colors.orange : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (!isSubscribed) {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const SubscriptionScreen(),
  ),
);
                  return;
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanScreen(
                      couponId: coupon.id,
                    ),
                  ),
                );

                if (result == true && mounted) {
                  setState(() {
                    _loadCoupons();
                  });
                }
              },
              child: Text(
                isSubscribed ? "Scan to Redeem" : "Get Membership",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 MEMBERSHIP DIALOG
  void _showMembershipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Membership Required"),
        content: const Text(
          "Upgrade your membership to unlock exclusive coupons.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 🔜 Navigate to subscription screen
            },
            child: const Text("Get Membership"),
          ),
        ],
      ),
    );
  }
}
