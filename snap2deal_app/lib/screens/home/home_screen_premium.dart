import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/red_theme.dart';

class HomeScreenPremium extends StatelessWidget {
  const HomeScreenPremium({super.key});

  Future<String> _getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 HERO
            Container(
              padding: const EdgeInsets.fromLTRB(20, 64, 20, 90),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    RedTheme.primaryRed,
                    RedTheme.primaryRed.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: FutureBuilder<String>(
                future: _getName(),
                builder: (context, snap) {
                  final name = snap.data ?? "User";
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $name 👋",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Unlock exclusive offline deals near you",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 💳 FLOATING MEMBERSHIP
            Transform.translate(
              offset: const Offset(0, -56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RedTheme.lightRed,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.workspace_premium,
                            color: RedTheme.primaryRed),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gold Membership",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "23 days remaining",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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

            const SizedBox(height: 4),

            // 🧭 CATEGORIES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _CategoryChip(label: "Food", icon: Icons.restaurant),
                  _CategoryChip(label: "Beauty", icon: Icons.cut),
                  _CategoryChip(label: "Retail", icon: Icons.store),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🏷️ OFFERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  _OfferCard(
                    title: "Spice Route",
                    subtitle: "Buy 2 Get 1 Free",
                    tag: "POPULAR",
                  ),
                  _OfferCard(
                    title: "Glow Salon",
                    subtitle: "₹150 OFF on ₹500",
                    tag: "LIMITED",
                  ),
                  _OfferCard(
                    title: "Style Mart",
                    subtitle: "₹300 OFF on ₹1000",
                    tag: "HOT",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ===== Components =====

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RedTheme.primaryRed),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  const _OfferCard({
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: RedTheme.lightRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_offer,
                color: RedTheme.primaryRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: RedTheme.lightRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: RedTheme.primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
