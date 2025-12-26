import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/red_theme.dart';
import '../../core/services/coupon_service.dart';
import '../scan/scan_screen.dart';

class CouponListRed extends StatefulWidget {
  const CouponListRed({super.key});

  @override
  State<CouponListRed> createState() => _CouponListRedState();
}

class _CouponListRedState extends State<CouponListRed> {
  List coupons = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final data = await CouponService.getUserCoupons(userId);

    setState(() {
      coupons = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: RedTheme.primaryRed,
        elevation: 0,
        title: const Text("My Coupons"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : coupons.isEmpty
              ? const Center(
                  child: Text(
                    "No active coupons available",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (_, index) {
                    final coupon = coupons[index]["couponId"];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏷 OFFER TAG
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: RedTheme.lightRed,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ACTIVE",
                              style: TextStyle(
                                color: RedTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            coupon["title"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Valid for offline redemption",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 16),

                          // 🔴 SCAN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RedTheme.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScanScreen(
                                      couponId: coupon["_id"],
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Scan to Redeem",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
