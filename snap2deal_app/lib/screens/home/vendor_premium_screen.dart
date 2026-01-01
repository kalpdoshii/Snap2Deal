import 'package:flutter/material.dart';
import '../../core/models/vendor_model.dart';
import '../../core/services/vendor_service.dart';
import 'package:snap2deal_app/screens/home/vendor_details_screen.dart';
class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  String selectedCategory = "All";

  final categories = ["All", "Restaurant", "Salon", "Shop"];

  late Future<List<Vendor>> vendorsFuture;

  @override
  void initState() {
    super.initState();
    vendorsFuture = VendorService.fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Vendors",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black54),
          SizedBox(width: 12),
          Icon(Icons.settings, color: Colors.black54),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 🟠 CATEGORY FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((c) {
                  final isActive = c == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: isActive,
                      selectedColor: Colors.orange,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isActive ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() => selectedCategory = c);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🏪 VENDORS LIST (DYNAMIC)
          Expanded(
            child: FutureBuilder<List<Vendor>>(
              future: vendorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No vendors available"),
                  );
                }

                final allVendors = snapshot.data!;
                final filteredVendors = selectedCategory == "All"
                    ? allVendors
                    : allVendors
                        .where(
                          (v) => v.category == selectedCategory,
                        )
                        .toList();

                if (filteredVendors.isEmpty) {
                  return const Center(
                    child: Text("No vendors in this category"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVendors.length,
                  itemBuilder: (context, index) {
                    final vendor = filteredVendors[index];
                    return _vendorCard(context, vendor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧾 VENDOR CARD
 Widget _vendorCard(BuildContext context, Vendor vendor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vendor.category.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // CTA
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
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
              child: const Text(
                "View Vendor",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
