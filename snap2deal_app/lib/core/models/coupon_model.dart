class Coupon {
  final String id;
  final String vendorId;
  final String merchantId; // For backward compatibility
  final String title;
  final String description;
  final int discount;
  final String code;
  final DateTime expiryDate;
  final bool used;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? adminNotes;
  final String? qrCode; // QR code data/image
  final List<CouponRedemption> redemptions; // Track redemption attempts

  Coupon({
    required this.id,
    required this.vendorId,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.discount,
    required this.code,
    required this.expiryDate,
    required this.used,
    this.status = 'pending',
    required this.createdAt,
    this.approvedAt,
    this.adminNotes,
    this.qrCode,
    this.redemptions = const [],
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final redemptionsList =
        (json["redemptions"] as List?)
            ?.map((r) => CouponRedemption.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return Coupon(
      id: json["id"] ?? json["_id"] ?? "",
      vendorId: json["vendorId"] ?? json["merchantId"] ?? "",
      merchantId: json["merchantId"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      discount: json["discount"] ?? 0,
      code: json["code"] ?? "",
      expiryDate: json["expiryDate"] is String
          ? DateTime.parse(json["expiryDate"])
          : (json["expiryDate"] as dynamic)?.toDate() ?? DateTime.now(),
      used: json["used"] ?? false,
      status: json["status"] ?? "pending",
      createdAt: json["createdAt"] is String
          ? DateTime.parse(json["createdAt"])
          : (json["createdAt"] as dynamic)?.toDate() ?? DateTime.now(),
      approvedAt: json["approvedAt"] is String
          ? DateTime.parse(json["approvedAt"])
          : (json["approvedAt"] as dynamic)?.toDate(),
      adminNotes: json["adminNotes"],
      qrCode: json["qrCode"],
      redemptions: redemptionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "vendorId": vendorId,
      "merchantId": merchantId,
      "title": title,
      "description": description,
      "discount": discount,
      "code": code,
      "expiryDate": expiryDate,
      "used": used,
      "status": status,
      "createdAt": createdAt,
      "approvedAt": approvedAt,
      "adminNotes": adminNotes,
      "qrCode": qrCode,
      "redemptions": redemptions.map((r) => r.toJson()).toList(),
    };
  }
}

class CouponRedemption {
  final String id;
  final String userId;
  final DateTime scannedAt;
  final DateTime? redeemedAt;
  final DateTime? expiresAt; // 3-minute expiry from scan
  final String status; // 'pending', 'redeemed', 'expired'

  CouponRedemption({
    required this.id,
    required this.userId,
    required this.scannedAt,
    this.redeemedAt,
    this.expiresAt,
    this.status = 'pending',
  });

  factory CouponRedemption.fromJson(Map<String, dynamic> json) {
    return CouponRedemption(
      id: json["id"] ?? "",
      userId: json["userId"] ?? "",
      scannedAt: json["scannedAt"] is String
          ? DateTime.parse(json["scannedAt"])
          : (json["scannedAt"] as dynamic)?.toDate() ?? DateTime.now(),
      redeemedAt: json["redeemedAt"] is String
          ? DateTime.parse(json["redeemedAt"])
          : (json["redeemedAt"] as dynamic)?.toDate(),
      expiresAt: json["expiresAt"] is String
          ? DateTime.parse(json["expiresAt"])
          : (json["expiresAt"] as dynamic)?.toDate(),
      status: json["status"] ?? "pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "scannedAt": scannedAt,
      "redeemedAt": redeemedAt,
      "expiresAt": expiresAt,
      "status": status,
    };
  }
}
