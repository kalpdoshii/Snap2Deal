class Coupon {
  final String id;
  final String title;
  final String description;
  final int discountValue;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discountValue,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json["_id"],
      title: json["title"],
      description: json["description"] ?? "",
      discountValue: json["discountValue"] ?? 0,
    );
  }
}
