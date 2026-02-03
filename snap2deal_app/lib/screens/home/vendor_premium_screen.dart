import 'package:flutter/material.dart';
import '../../core/models/vendor_model.dart';
import '../../core/services/vendor_service.dart';
import 'vendor_details_screen.dart';

class VendorsScreen extends StatefulWidget {
  final String initialCategory;

  const VendorsScreen({super.key, required this.initialCategory});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  late String selectedCategory;

  final categories = ["All", "Restaurant", "Cafe", "Salon", "Shop"];

  late Future<List<Vendor>> vendorsFuture;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory.isNotEmpty
        ? widget.initialCategory
        : "All";
    vendorsFuture = VendorService.fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Vendors"),
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
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '❌ Error Loading Vendors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString().replaceAll(
                              'Exception: ',
                              '',
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                vendorsFuture = VendorService.fetchVendors();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No vendors available"));
                }

                final allVendors = snapshot.data!;
                final filteredVendors = selectedCategory == "All"
                    ? allVendors
                    : allVendors
                          .where(
                            (v) =>
                                v.category.toLowerCase() ==
                                selectedCategory.toLowerCase(),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            // 🔵 LOGO
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  vendor.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.store, size: 32),
                ),
              ),
            ),

            // 🧾 INFO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vendor.category,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
