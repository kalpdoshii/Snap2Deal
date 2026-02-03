import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import 'vendor_approval_screen.dart';
import 'coupon_approval_screen.dart';
import 'users_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = AdminService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: statsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'Total Vendors',
                        stats['totalVendors'].toString(),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Pending Vendors',
                        stats['pendingVendors'].toString(),
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Total Users',
                        stats['totalUsers'].toString(),
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Total Coupons',
                        stats['totalCoupons'].toString(),
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Pending Coupons',
                        stats['pendingCoupons'].toString(),
                        Colors.red,
                      ),
                      _buildStatCard(
                        'Approved Coupons',
                        stats['approvedCoupons'].toString(),
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Quick Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActionButton(
                        'Approve Vendors',
                        Icons.business,
                        () => _navigateToVendorApproval(),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Approve Coupons',
                        Icons.card_giftcard,
                        () => _navigateToCouponApproval(),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'View Users',
                        Icons.people,
                        () => _navigateToUsers(),
                      ),
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

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
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

  void _navigateToVendorApproval() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VendorApprovalScreen()),
    );
  }

  void _navigateToCouponApproval() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CouponApprovalScreen()),
    );
  }

  void _navigateToUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UsersListScreen()),
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
              await AdminService.logoutAdmin();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/admin-login', (route) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
