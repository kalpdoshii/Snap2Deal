class Vendor {
  final String id;
  final String name;
  final String category;
  final String address;
  final String logoUrl;
  final String coverImageUrl;
  double rating = 0.0;


  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.logoUrl,
    required this.coverImageUrl,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json["_id"],
      name: json["name"],
      category: json["category"],
      address: json["address"] ?? "",
      logoUrl: json["logoUrl"] ?? "",
      coverImageUrl: json["coverImageUrl"] ?? "",

    );
  }
}
