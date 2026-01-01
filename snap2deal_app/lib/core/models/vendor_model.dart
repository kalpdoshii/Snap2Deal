class Vendor {
  final String id;
  final String name;
  final String category;
  final String address;

  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json["_id"],
      name: json["name"],
      category: json["category"],
      address: json["address"] ?? "",
    );
  }
}
