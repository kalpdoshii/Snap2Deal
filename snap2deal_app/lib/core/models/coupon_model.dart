class Coupon {
  final String id;
  final String title;
  final String merchantId;

  Coupon({
    required this.id,
    required this.title,
    required this.merchantId,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json["_id"],
      title: json["title"],
      merchantId: json["merchantId"],
    );
  }
}
