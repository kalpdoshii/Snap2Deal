import 'package:flutter/material.dart';
import '../../core/services/coupon_service.dart';
import '../../core/services/vendor_service.dart';
import '../../core/models/coupon_model.dart';
import '../../core/models/vendor_model.dart';

class CouponApprovalScreen extends StatefulWidget {
  const CouponApprovalScreen({super.key});

  @override
  State<CouponApprovalScreen> createState() => _CouponApprovalScreenState();
}

class _CouponApprovalScreenState extends State<CouponApprovalScreen> {
  late Future<List<Coupon>> pendingCouponsFuture;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pendingCouponsFuture = CouponService.getPendingCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Coupons')),
      body: FutureBuilder<List<Coupon>>(
        future: pendingCouponsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending coupons'));
          }

          final coupons = snapshot.data!;

          return ListView.builder(
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return FutureBuilder<Vendor?>(
                future: VendorService.getVendorById(coupon.vendorId),
                builder: (context, vendorSnapshot) {
                  final vendor = vendorSnapshot.data;
                  return _buildCouponCard(
                    coupon,
                    vendor?.name ?? 'Unknown Vendor',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon, String vendorName) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coupon.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'By: $vendorName',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Code:', coupon.code),
            _buildInfoRow('Discount:', '${coupon.discount}%'),
            _buildInfoRow('Description:', coupon.description),
            _buildInfoRow(
              'Expires:',
              '${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => _approveCoupon(coupon),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _rejectCoupon(coupon),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _approveCoupon(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Coupon'),
        content: const Text('Do you want to approve this coupon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await CouponService.approveCoupon(coupon.id);
              if (success) {
                setState(() {
                  pendingCouponsFuture = CouponService.getPendingCoupons();
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coupon approved successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectCoupon(Coupon coupon) {
    _notesController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide rejection reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Rejection reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_notesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              Navigator.pop(context);
              final success = await CouponService.rejectCoupon(
                coupon.id,
                adminNotes: _notesController.text,
              );
              if (success) {
                setState(() {
                  pendingCouponsFuture = CouponService.getPendingCoupons();
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coupon rejected')),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
