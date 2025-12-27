import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/screens/splash/splash_screen.dart';
import '../../core/theme/red_theme.dart';

class ProfileScreenRed extends StatelessWidget {
  const ProfileScreenRed({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 HEADER WITH USER DATA
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final prefs = snapshot.data!;
                final name = prefs.getString("userName") ?? "User";
                final phone = prefs.getString("userPhone") ?? "";
                final email = prefs.getString("userEmail");

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        RedTheme.primaryRed,
                        RedTheme.primaryRed.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: RedTheme.primaryRed,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 👤 NAME
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 📱 PHONE
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: const TextStyle(color: Colors.white70),
                        ),

                      // 📧 EMAIL (OPTIONAL)
                      if (email != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // ⭐ SUBSCRIPTION CARD
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Gold Membership",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Valid till 23 days",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: RedTheme.lightRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "ACTIVE",
                          style: TextStyle(
                            color: RedTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 💰 SAVINGS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.savings,
                        color: RedTheme.primaryRed, size: 32),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You Saved",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "₹1,450",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ⚙ OPTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProfileOption(
                    icon: Icons.history,
                    title: "Redemption History",
                    onTap: () {},
                  ),
                  ProfileOption(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () => logout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 🔹 OPTION TILE
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: RedTheme.primaryRed),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
