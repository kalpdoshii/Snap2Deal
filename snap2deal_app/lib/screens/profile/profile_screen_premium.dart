import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/services/user_service.dart';
import 'package:snap2deal_app/screens/profile/edit_profile_screen.dart';
import 'package:snap2deal_app/screens/splash/splash_screen.dart';

class ProfileScreenPremium extends StatefulWidget {
  const ProfileScreenPremium({super.key});

  @override
  State<ProfileScreenPremium> createState() => _ProfileScreenPremiumState();
}

class _ProfileScreenPremiumState extends State<ProfileScreenPremium> {
  String name = "";
  String phone = "";
  String email = "";
  int couponsLeft = 0;
int usedCoupons = 0;
int totalSaved = 0;
bool loadingStats = true;


  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("userName") ?? name;
      phone = prefs.getString("userPhone") ?? phone;
      email = prefs.getString("userEmail") ?? email;
    });
  }

  Future<void> loadStats() async {
  final data = await UserService.fetchProfileStats();

  if (data != null) {
    setState(() {
      couponsLeft = data["couponsLeft"];
      usedCoupons = data["usedCoupons"];
      totalSaved = data["totalSaved"];
      loadingStats = false;
    });
  }
}


  String get initials {
    final parts = name.split(" ");
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name.isNotEmpty ? name[0] : "U";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F4),
      appBar: AppBar(
  automaticallyImplyLeading: false,
  title: const Text("Profile"),
),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 20),
            _optionsCard(),
            const SizedBox(height: 24),
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  // 🔶 PROFILE CARD
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.orange,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
  onTap: () async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (updated == true) {
      loadUser(); // refresh profile
    }
  },
  child: Container(
    padding: const EdgeInsets.all(6),
    decoration: const BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.edit, size: 16, color: Colors.white),
  ),
),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.workspace_premium, size: 16, color: Colors.orange),
              SizedBox(width: 6),
              Text(
                "Premium Member",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔢 STATS
  Widget _statsRow() {
    return Row(
      children: [
        _statCard("--", "Coupons Left"),
        const SizedBox(width: 12),
        _statCard("--", "Used"),
        const SizedBox(width: 12),
        _statCard("--", "Saved"),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // ⚙ OPTIONS
  Widget _optionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        children: [
          _optionTile(
            icon: Icons.credit_card,
            title: "Subscription",
            subtitle: "Premium Plan - 89 days left",
          ),
          _divider(),
          _optionTile(icon: Icons.phone, title: "Phone", subtitle: phone),
          _divider(),
          _optionTile(icon: Icons.email, title: "Email", subtitle: email),
          _divider(),
          _optionTile(
            icon: Icons.lock,
            title: "Privacy & Security",
            subtitle: "Manage your data",
          ),
          _divider(),
          _optionTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "FAQs and contact",
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFFF1EC),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 72);
  }

  // 🔴 LOGOUT
  Widget _logoutButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      ),
      onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const SplashScreen()),
    (route) => false,
  );
},

      icon: const Icon(Icons.logout),
      label: const Text(
        "Logout",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
