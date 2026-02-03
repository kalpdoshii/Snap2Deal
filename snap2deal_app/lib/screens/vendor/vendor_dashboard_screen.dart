import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/vendor_service.dart';
import '../../core/models/vendor_model.dart';
import 'upload_media_screen.dart';
import 'create_coupon_screen.dart';
import 'vendor_analytics_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  late Future<Vendor?> vendorFuture;
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
  }

  void _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    vendorId = prefs.getString('vendorId');
    if (vendorId != null) {
      vendorFuture = VendorService.getVendorById(vendorId!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vendorId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vendor Dashboard')),
        body: const Center(child: Text('Loading...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<Vendor?>(
        future: vendorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Vendor not found'));
          }

          final vendor = snapshot.data!;

          if (vendor.status != 'approved') {
            return _buildPendingApprovalView(vendor);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildVendorCard(vendor),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuButton(
                        'Upload Logo & Banner',
                        Icons.image,
                        Colors.blue,
                        () => _navigateToUploadMedia(vendor),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuButton(
                        'Create Coupon',
                        Icons.card_giftcard,
                        Colors.orange,
                        () => _navigateToCreateCoupon(vendor),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuButton(
                        'Analytics Dashboard',
                        Icons.bar_chart,
                        Colors.green,
                        () => _navigateToAnalytics(vendor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingApprovalView(Vendor vendor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Pending Approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              vendor.status == 'pending'
                  ? 'Your vendor registration is pending admin approval.'
                  : 'Your vendor registration was rejected.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (vendor.adminNotes != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(vendor.adminNotes!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: vendor.logo != null
                      ? NetworkImage(vendor.logo!)
                      : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${vendor.status}',
                        style: TextStyle(
                          color: vendor.status == 'approved'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  void _navigateToUploadMedia(Vendor vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UploadMediaScreen(vendor: vendor)),
    );
  }

  void _navigateToCreateCoupon(Vendor vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateCouponScreen(vendor: vendor)),
    );
  }

  void _navigateToAnalytics(Vendor vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VendorAnalyticsScreen(vendor: vendor)),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('vendorId');
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/vendor-login', (route) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
