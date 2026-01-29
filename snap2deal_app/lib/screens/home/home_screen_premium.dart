import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/models/vendor_model.dart';
import 'package:snap2deal_app/core/services/vendor_service.dart';
import 'package:snap2deal_app/screens/home/vendor_details_screen.dart';
import 'package:snap2deal_app/widgests/logo_loader.dart';

class HomeScreenPremium extends StatefulWidget {
  final Function(String category) onCategoryTap;

  const HomeScreenPremium({super.key, required this.onCategoryTap});

  @override
  State<HomeScreenPremium> createState() => _HomeScreenPremiumState();
}

class _HomeScreenPremiumState extends State<HomeScreenPremium> {
  bool isSubscribed = false;
  int daysLeft = 0;
  String? expandedVendorId;

  final List<Map<String, String>> categories = const [
    {"name": "Restaurants", "image": "assets/images/categories/restaurant.jpg"},
    {"name": "Cafe", "image": "assets/images/categories/cafe.jpg"},
    {"name": "Salons", "image": "assets/images/categories/salon.jpg"},
    {"name": "Shops", "image": "assets/images/categories/shop.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString("subscriptionExpiry");

    print("SUB EXPIRY => ${prefs.getString("subscriptionExpiry")}");

    if (expiryString == null) {
      setState(() {
        isSubscribed = false;
        daysLeft = 0;
      });
      return;
    }

    final expiryDate = DateTime.tryParse(expiryString);
    if (expiryDate == null) {
      setState(() {
        isSubscribed = false;
        daysLeft = 0;
      });
      return;
    }

    final now = DateTime.now();

    if (expiryDate.isAfter(now)) {
      setState(() {
        isSubscribed = true;
        daysLeft = expiryDate.difference(now).inDays;
      });
    } else {
      setState(() {
        isSubscribed = false;
        daysLeft = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Membership Adda"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          isSubscribed ? _membershipCard() : _buyPlanBanner(),
          const SizedBox(height: 24),

          const Text(
            "Categories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _categorySlider(),

          const SizedBox(height: 24),

          const Text(
            "Top Vendors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          FutureBuilder<List<Vendor>>(
            future: VendorService.fetchVendors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LogoLoader();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No vendors available"));
              }

              final vendors = snapshot.data!.take(5).toList();

              return Column(
                children: vendors.map((vendor) {
                  return VendorExpandableCard(
                    vendor: vendor,
                    isExpanded: expandedVendorId == vendor.id,
                    onTap: () {
                      setState(() {
                        expandedVendorId = expandedVendorId == vendor.id
                            ? null
                            : vendor.id;
                      });
                    },
                    onViewCoupons: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VendorDetailsScreen(
                            vendorName: vendor.name,
                            merchantId: vendor.id,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔥 BUY PLAN BANNER
  Widget _buyPlanBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Unlock Premium Deals",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "One membership. Unlimited offline savings.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _planTile("Monthly Plan", "₹99 / month"),
          const SizedBox(height: 12),
          _planTile("Quarterly Plan", "₹249 / 3 months"),
        ],
      ),
    );
  }

  Widget _planTile(String title, String price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(color: Colors.orange)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Subscription coming soon")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Buy"),
          ),
        ],
      ),
    );
  }

  // 🟡 PREMIUM CARD
  Widget _membershipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE53935)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back!", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          const Text(
            "Premium Member",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$daysLeft days left",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🖼 CATEGORY SLIDER
  Widget _categorySlider() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: AssetImage(category["image"]!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.45),
                  BlendMode.darken,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              category["name"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

/* -------------------- EXPANDABLE VENDOR CARD -------------------- */

class VendorExpandableCard extends StatelessWidget {
  final Vendor vendor;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onViewCoupons;

  const VendorExpandableCard({
    super.key,
    required this.vendor,
    required this.isExpanded,
    required this.onTap,
    required this.onViewCoupons,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: vendor.logoUrl.isNotEmpty
                  ? NetworkImage(vendor.logoUrl)
                  : null,
              child: vendor.logoUrl.isEmpty ? const Icon(Icons.store) : null,
            ),
            title: Text(
              vendor.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),

          if (isExpanded) _expandedSection(context),
        ],
      ),
    );
  }

  Widget _expandedSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: vendor.coverImageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(vendor.coverImageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Icon(
              i < vendor.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: onViewCoupons,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("View Coupons"),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
