class Coupon {
  final String id;
  final String title;
  final String description;
  final int discountValue;
  final bool isLocked;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.isLocked,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json["_id"],
      title: json["title"],
      description: json["description"] ?? "",
      discountValue: json["discountValue"] ?? 0,
      isLocked: json["isLocked"] ?? true,
    );
  }
}
