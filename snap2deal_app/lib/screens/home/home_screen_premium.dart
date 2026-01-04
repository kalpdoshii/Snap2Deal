import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/core/models/vendor_model.dart';
import 'package:snap2deal_app/core/services/vendor_service.dart';
import 'package:snap2deal_app/screens/home/vendor_details_screen.dart';
import 'package:snap2deal_app/screens/home/vendor_premium_screen.dart';

class HomeScreenPremium extends StatefulWidget {
  const HomeScreenPremium({super.key});

  @override
  State<HomeScreenPremium> createState() => _HomeScreenPremiumState();
}

class _HomeScreenPremiumState extends State<HomeScreenPremium> {
  String? expandedVendorId;
  bool isSubscribed = false;
  int daysLeft = 0;

  final List<Map<String, String>> categories = [
    {
      "name": "Restaurants",
      "image": "assets/images/categories/restaurant.jpg",
    },
    {
      "name": "Cafe",
      "image": "assets/images/categories/cafe.jpg",
    },
    {
      "name": "Salons",
      "image": "assets/images/categories/salon.jpg",
    },
    {
      "name": "Shops",
      "image": "assets/images/categories/shop.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString("subscriptionExpiry");

    if (expiryString != null) {
      final expiryDate = DateTime.parse(expiryString);
      final now = DateTime.now();

      if (expiryDate.isAfter(now)) {
        setState(() {
          isSubscribed = true;
          daysLeft = expiryDate.difference(now).inDays;
        });
        return;
      }
    }

    setState(() {
      isSubscribed = false;
      daysLeft = 0;
    });
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
          // 🔝 TOP SECTION
          isSubscribed ? _membershipCard() : _buyPlanBanner(),
          const SizedBox(height: 24),

          // 📂 CATEGORIES
          const Text(
            "Categories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _categorySlider(),

          const SizedBox(height: 24),

          // ⭐ TOP VENDORS (SAFE UI)
          const Text(
            "Top Vendors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
FutureBuilder<List<Vendor>>(
  future: VendorService.fetchVendors(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final vendors = snapshot.data!.take(5).toList();

    return Column(
      children: vendors.map((vendor) {
        return VendorExpandableCard(
          vendor: vendor,
          isExpanded: expandedVendorId == vendor.id,
          onTap: () {
            setState(() {
              expandedVendorId =
                  expandedVendorId == vendor.id ? null : vendor.id;
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

  // 🟢 SUBSCRIPTION BANNER (NOT SUBSCRIBED)
  Widget _buyPlanBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.red],
        ),
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

  // 🟡 MEMBERSHIP CARD (SUBSCRIBED)
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
          const Text(
            "Welcome back!",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          const Text(
            "Premium Member",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$daysLeft Days Left",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🖼️ CATEGORY IMAGE SLIDER
  Widget _categorySlider() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VendorsScreen(
                    initialCategory: category["name"]!,
                  ),
                ),
              );
            },
            child: Container(
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
              child: Center(
                child: Text(
                  category["name"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ⭐ TOP VENDORS (SAFE PLACEHOLDER)
 Widget topVendorsSection(List vendors) {
  return SizedBox(
    height: 180,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];

        return GestureDetector(
          onTap: () {
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
          child: Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 12),
              ],
            ),
            child: Row(
              children: [
                // 🔵 LOGO
                Container(
                  width: 90,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      vendor.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 40),
                    ),
                  ),
                ),

                // 🧾 INFO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vendor.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vendor.category,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "View Deals →",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _topVendorTile(BuildContext context, Vendor vendor) {
  return InkWell(
    onTap: () {
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
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // 🟠 LOGO
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: NetworkImage(vendor.logoUrl),
          ),

          const SizedBox(width: 14),

          // 🏪 NAME
          Expanded(
            child: Text(
              vendor.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  );
}


}

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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          // 🔹 HEADER
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(vendor.logoUrl),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      vendor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // 🔻 EXPAND AREA
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: _expandedContent(context),
          ),
        ],
      ),
    );
  }

  Widget _expandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🖼️ COVER IMAGE
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(vendor.coverImageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ⭐ RATING
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < vendor.rating
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 🔘 CTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: onViewCoupons,
              child: const Text(
                "View Coupons",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
