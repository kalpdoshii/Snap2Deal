import 'package:flutter/material.dart';
import '../../core/models/vendor_model.dart';
import '../../core/services/coupon_service.dart';
import '../../core/models/coupon_model.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  final Vendor vendor;

  const VendorAnalyticsScreen({super.key, required this.vendor});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  late Future<List<Coupon>> _couponsFuture;

  @override
  void initState() {
    super.initState();
    _couponsFuture = CouponService.getVendorCoupons(widget.vendor.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: FutureBuilder<List<Coupon>>(
        future: _couponsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final coupons = snapshot.data!;
          final stats = _calculateStats(coupons);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatCard(
                  'Total Coupons',
                  stats['total'].toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active Coupons',
                  stats['active'].toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  'Pending Approval',
                  stats['pending'].toString(),
                  Colors.orange,
                ),
                _buildStatCard(
                  'Approved',
                  stats['approved'].toString(),
                  Colors.teal,
                ),
                _buildStatCard(
                  'Rejected',
                  stats['rejected'].toString(),
                  Colors.red,
                ),
                _buildStatCard(
                  'Total Redemptions',
                  stats['totalRedemptions'].toString(),
                  Colors.purple,
                ),
                _buildStatCard(
                  'Completed Redemptions',
                  stats['completedRedemptions'].toString(),
                  Colors.cyan,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coupon Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailedCouponList(coupons),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCouponList(List<Coupon> coupons) {
    return Column(
      children: coupons.map((coupon) {
        final totalRedemptions = coupon.redemptions.length;
        final completedRedemptions = coupon.redemptions
            .where((r) => r.status == 'redeemed')
            .length;
        final pendingRedemptions = coupon.redemptions
            .where((r) => r.status == 'pending')
            .length;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code: ${coupon.code} | Discount: ${coupon.discount}%',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Total Scans',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            totalRedemptions.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            completedRedemptions.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            pendingRedemptions.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, int> _calculateStats(List<Coupon> coupons) {
    int total = coupons.length;
    int active = coupons.where((c) => c.status == 'approved').length;
    int pending = coupons.where((c) => c.status == 'pending').length;
    int approved = coupons.where((c) => c.status == 'approved').length;
    int rejected = coupons.where((c) => c.status == 'rejected').length;

    int totalRedemptions = 0;
    int completedRedemptions = 0;

    for (final coupon in coupons) {
      totalRedemptions += coupon.redemptions.length;
      completedRedemptions += coupon.redemptions
          .where((r) => r.status == 'redeemed')
          .length;
    }

    return {
      'total': total,
      'active': active,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'totalRedemptions': totalRedemptions,
      'completedRedemptions': completedRedemptions,
    };
  }
}
