class Vendor {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final String image;
  final double rating;
  final int reviews;
  final String phoneNumber;
  final String email;
  final String address;
  final String timing;
  final int minOrder;
  final bool isApproved;
  final String status; // 'pending', 'approved', 'rejected'
  final String? logo; // Vendor's logo URL
  final String? banner; // Vendor's banner URL
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? adminNotes;
  final int totalCoupons;
  final int redeemedCoupons;

  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.timing,
    required this.minOrder,
    required this.isApproved,
    this.status = 'pending',
    this.logo,
    this.banner,
    required this.createdAt,
    this.approvedAt,
    this.adminNotes,
    this.totalCoupons = 0,
    this.redeemedCoupons = 0,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json["id"] ?? json["_id"] ?? "",
      name: json["name"] ?? "",
      category: json["category"] ?? "",
      description: json["description"] ?? "",
      location: json["location"] ?? "",
      image: json["image"] ?? "",
      rating: (json["rating"] ?? 0.0).toDouble(),
      reviews: json["reviews"] ?? 0,
      phoneNumber: json["phoneNumber"] ?? "",
      email: json["email"] ?? "",
      address: json["address"] ?? "",
      timing: json["timing"] ?? "",
      minOrder: json["minOrder"] ?? 0,
      isApproved: json["isApproved"] ?? true,
      status: json["status"] ?? "pending",
      logo: json["logo"],
      banner: json["banner"],
      createdAt: json["createdAt"] is String
          ? DateTime.parse(json["createdAt"])
          : (json["createdAt"] as dynamic)?.toDate() ?? DateTime.now(),
      approvedAt: json["approvedAt"] is String
          ? DateTime.parse(json["approvedAt"])
          : (json["approvedAt"] as dynamic)?.toDate(),
      adminNotes: json["adminNotes"],
      totalCoupons: json["totalCoupons"] ?? 0,
      redeemedCoupons: json["redeemedCoupons"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category": category,
      "description": description,
      "location": location,
      "image": image,
      "rating": rating,
      "reviews": reviews,
      "phoneNumber": phoneNumber,
      "email": email,
      "address": address,
      "timing": timing,
      "minOrder": minOrder,
      "isApproved": isApproved,
      "status": status,
      "logo": logo,
      "banner": banner,
      "createdAt": createdAt,
      "approvedAt": approvedAt,
      "adminNotes": adminNotes,
      "totalCoupons": totalCoupons,
      "redeemedCoupons": redeemedCoupons,
    };
  }
}
