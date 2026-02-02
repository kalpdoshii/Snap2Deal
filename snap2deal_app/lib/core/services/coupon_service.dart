import 'package:snap2deal_app/core/services/firestore_service.dart';

class CouponService {
  // Get user's redeemed coupons
  static Future<List<dynamic>> getUserCoupons(String userId) async {
    return FirestoreService.getUserCoupons(userId);
  }

  // Redeem a coupon
  static Future<bool> redeemCoupon({
    required String userId,
    required String couponId,
    required String merchantQrToken,
  }) async {
    return FirestoreService.redeemCoupon(
      userId: userId,
      couponId: couponId,
      merchantQrToken: merchantQrToken,
    );
  }

  // Get coupons by merchant
  static Future<Map<String, dynamic>> fetchCouponsByMerchant(
    String merchantId,
  ) async {
    return FirestoreService.getCouponsByMerchant(merchantId);
  }
}
