import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/models/coupon_model.dart';
import 'package:snap2deal_app/core/services/coupon_service.dart';
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
  late Future<List<Coupon>> couponsFuture;
  late Future<bool> isSubscribedFuture;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
    isSubscribedFuture = _checkSubscription();
  }

  void _loadCoupons() {
    couponsFuture = CouponService.getCouponsByMerchant(widget.merchantId);
  }

  Future<bool> _checkSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final isSubscribed = data['isSubscribed'] ?? false;

      return isSubscribed;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(widget.vendorName),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<bool>(
        future: isSubscribedFuture,
        builder: (context, subscriptionSnapshot) {
          if (subscriptionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final isSubscribed = subscriptionSnapshot.data ?? false;

          return FutureBuilder<List<Coupon>>(
            future: couponsFuture,
            builder: (context, snapshot) {
              // ⏳ Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              // ❌ Error
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadCoupons();
                          });
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No coupons available"));
              }

              final coupons = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  return _couponCard(context, coupons[index], isSubscribed);
                },
              );
            },
          );
        },
      ),
    );
  }

  // 🧾 COUPON CARD - BEAUTIFUL DESIGN
  Widget _couponCard(BuildContext context, Coupon coupon, bool isSubscribed) {
    final isLocked = !isSubscribed;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔴 RED HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    coupon.discount > 0
                        ? "🎉 ${coupon.discount}% Off"
                        : "🎁 ${coupon.title.split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🌊 WAVY DIVIDER
          Container(
            height: 16,
            color: Colors.white,
            child: CustomPaint(
              painter: WavePainter(),
              size: const Size(double.infinity, 16),
            ),
          ),

          // 📝 CONTENT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coupon.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Valid till ${coupon.expiryDate.toString().split(' ')[0]}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Limited",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLocked
                        ? () {
                            // Navigate to subscription screen
                            Navigator.of(context).pushNamed('/subscription');
                          }
                        : coupon.used
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScanScreen(couponId: coupon.id),
                              ),
                            );
                          },
                    child: Text(
                      isLocked
                          ? "🔒 Buy Subscription"
                          : coupon.used
                          ? "✓ Already Used"
                          : "🔲 Scan to Redeem",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🌊 WAVE PAINTER FOR DIVIDER
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 8.0;
    final waveWidth = 20.0;

    path.moveTo(0, waveHeight);
    for (double x = 0; x < size.width; x += waveWidth) {
      path.quadraticBezierTo(x + waveWidth / 2, 0, x + waveWidth, waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
