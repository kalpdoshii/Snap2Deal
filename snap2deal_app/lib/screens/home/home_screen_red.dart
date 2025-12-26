import 'package:flutter/material.dart';
import 'package:snap2deal_app/screens/home/coupon_list_red.dart';
import '../../core/theme/red_theme.dart';
import '../profile/profile_screen.dart';
import '../home/coupon_list_screen.dart';

class HomeScreenRed extends StatelessWidget {
  const HomeScreenRed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: RedTheme.primaryRed,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: "Coupons"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CouponListScreen()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 HERO HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
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
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Snap2Deal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Unlock exclusive offline deals",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ⭐ MEMBERSHIP CARD (FLOATING)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                      ),
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
                          SizedBox(height: 4),
                          Text("Expires in 23 days",
                              style: TextStyle(color: Colors.grey)),
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

            // 🧩 CATEGORIES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CategoryPill(label: "Food 🍔"),
                  CategoryPill(label: "Beauty 💇"),
                  CategoryPill(label: "Retail 🛍️"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🏪 OFFERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  OfferCard(
                    shop: "Spice Route Restaurant",
                    offer: "Buy 2 Get 1 Free",
                  ),
                  OfferCard(
                    shop: "Glow Salon",
                    offer: "₹150 OFF on ₹500",
                  ),
                  OfferCard(
                    shop: "Style Mart",
                    offer: "₹300 OFF on ₹1000",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 🔹 CATEGORY PILL
class CategoryPill extends StatelessWidget {
  final String label;
  const CategoryPill({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// 🔹 OFFER CARD
class OfferCard extends StatelessWidget {
  final String shop;
  final String offer;

  const OfferCard({
    required this.shop,
    required this.offer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: RedTheme.lightRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store,
                color: RedTheme.primaryRed, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  offer,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RedTheme.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CouponListRed()),
              );
            },
            child: const Text(
              "View",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
