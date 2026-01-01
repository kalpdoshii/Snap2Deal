import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/coupon_service.dart';
import '../scan/scan_screen.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  List coupons = [];

  @override
  void initState() {
    super.initState();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final data = await CouponService.getUserCoupons(userId);
    setState(() => coupons = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Coupons")),
      body: ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (_, index) {
          final coupon = coupons[index]["couponId"];
          return Card(
            child: ListTile(
              title: Text(coupon["title"]),
              trailing: ElevatedButton(
                child: const Text("Scan to Redeem"),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
