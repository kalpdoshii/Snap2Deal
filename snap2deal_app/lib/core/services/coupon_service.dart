import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';
import 'package:uuid/uuid.dart';

class CouponService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available coupons
  static Future<List<Coupon>> getAllCoupons() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('coupons')
          .where('status', isEqualTo: 'approved')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<Coupon> coupons = snapshot.docs
          .map((doc) => Coupon.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      rethrow;
    }
  }

  // Get coupons by merchant
  static Future<List<Coupon>> getCouponsByMerchant(String merchantId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('coupons')
          .where('merchantId', isEqualTo: merchantId)
          .get();

      final List<Coupon> coupons = snapshot.docs
          .map((doc) => Coupon.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return coupons;
    } catch (e) {
      rethrow;
    }
  }

  // Create a new coupon (vendor action - requires approval)
  static Future<String?> createCoupon({
    required String vendorId,
    required String merchantId,
    required String title,
    required String description,
    required int discount,
    required String code,
    required DateTime expiryDate,
  }) async {
    try {
      final couponId = const Uuid().v4();
      
      await _firestore.collection('coupons').doc(couponId).set({
        'id': couponId,
        'vendorId': vendorId,
        'merchantId': merchantId,
        'title': title,
        'description': description,
        'discount': discount,
        'code': code,
        'expiryDate': expiryDate,
        'status': 'pending',
        'used': false,
        'createdAt': DateTime.now(),
        'redemptions': [],
      });

      return couponId;
    } catch (e) {
      print('Error creating coupon: $e');
      return null;
    }
  }

  // Get pending coupons (for admin approval)
  static Future<List<Coupon>> getPendingCoupons() async {
    try {
      final querySnapshot = await _firestore
          .collection('coupons')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Coupon.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching pending coupons: $e');
      return [];
    }
  }

  // Get vendor's coupons (all statuses)
  static Future<List<Coupon>> getVendorCoupons(String vendorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('coupons')
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Coupon.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching vendor coupons: $e');
      return [];
    }
  }

  // Approve coupon (admin action)
  static Future<bool> approveCoupon(
    String couponId, {
    String? qrCodeUrl,
    String? adminNotes,
  }) async {
    try {
      final updateData = {
        'status': 'approved',
        'approvedAt': DateTime.now(),
        'qrCode': qrCodeUrl,
        'adminNotes': adminNotes,
      };

      await _firestore.collection('coupons').doc(couponId).update(updateData);
      return true;
    } catch (e) {
      print('Error approving coupon: $e');
      return false;
    }
  }

  // Reject coupon (admin action)
  static Future<bool> rejectCoupon(
    String couponId, {
    required String adminNotes,
  }) async {
    try {
      await _firestore.collection('coupons').doc(couponId).update({
        'status': 'rejected',
        'adminNotes': adminNotes,
      });
      return true;
    } catch (e) {
      print('Error rejecting coupon: $e');
      return false;
    }
  }

  // Update coupon QR code after approval
  static Future<bool> updateCouponQrCode(
    String couponId,
    String qrCodeUrl,
  ) async {
    try {
      await _firestore
          .collection('coupons')
          .doc(couponId)
          .update({'qrCode': qrCodeUrl});
      return true;
    } catch (e) {
      print('Error updating coupon QR code: $e');
      return false;
    }
  }

  // Get coupon by ID
  static Future<Coupon?> getCouponById(String couponId) async {
    try {
      final doc = await _firestore.collection('coupons').doc(couponId).get();
      if (doc.exists) {
        return Coupon.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching coupon: $e');
      return null;
    }
  }

  // Get user's redeemed coupons
  static Future<List<dynamic>> getUserCoupons(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      return data['redeemedCoupons'] ?? [];
    } catch (e) {
      return [];
    }
  }

  // Scan coupon - create redemption record with 3-minute expiry
  static Future<CouponRedemption?> scanCoupon({
    required String couponId,
    required String userId,
  }) async {
    try {
      final redemptionId = const Uuid().v4();
      final scanTime = DateTime.now();
      final expiryTime = scanTime.add(const Duration(minutes: 3));

      final redemption = CouponRedemption(
        id: redemptionId,
        userId: userId,
        scannedAt: scanTime,
        expiresAt: expiryTime,
        status: 'pending',
      );

      // Add redemption to coupon
      await _firestore
          .collection('coupons')
          .doc(couponId)
          .update({
        'redemptions': FieldValue.arrayUnion([redemption.toJson()]),
      });

      return redemption;
    } catch (e) {
      print('Error scanning coupon: $e');
      return null;
    }
  }

  // Vendor confirms redemption (within 3-minute window)
  static Future<bool> confirmRedemption({
    required String couponId,
    required String redemptionId,
  }) async {
    try {
      final coupon = await getCouponById(couponId);
      if (coupon == null) return false;

      // Find the redemption
      final redemption = coupon.redemptions
          .firstWhere((r) => r.id == redemptionId, orElse: () {
        throw Exception('Redemption not found');
      });

      // Check if still within 3-minute window
      if (DateTime.now().isAfter(redemption.expiresAt!)) {
        // Mark as expired
        await _updateRedemptionStatus(couponId, redemptionId, 'expired');
        return false;
      }

      // Mark as redeemed
      await _updateRedemptionStatus(
        couponId,
        redemptionId,
        'redeemed',
        redeemedAt: DateTime.now(),
      );

      // Remove coupon from user's available coupons
      await _firestore
          .collection('users')
          .doc(redemption.userId)
          .update({
        'redeemedCoupons': FieldValue.arrayUnion([
          {
            'couponId': couponId,
            'redeemedAt': DateTime.now(),
          },
        ]),
      });

      return true;
    } catch (e) {
      print('Error confirming redemption: $e');
      return false;
    }
  }

  // Expire old redemption records (called by timer or scheduler)
  static Future<void> expireOldRedemptions(String couponId) async {
    try {
      final coupon = await getCouponById(couponId);
      if (coupon == null) return;

      final now = DateTime.now();
      for (final redemption in coupon.redemptions) {
        if (redemption.status == 'pending' &&
            now.isAfter(redemption.expiresAt!)) {
          await _updateRedemptionStatus(couponId, redemption.id, 'expired');
        }
      }
    } catch (e) {
      print('Error expiring redemptions: $e');
    }
  }

  // Helper method to update redemption status
  static Future<void> _updateRedemptionStatus(
    String couponId,
    String redemptionId,
    String status, {
    DateTime? redeemedAt,
  }) async {
    try {
      final coupon = await getCouponById(couponId);
      if (coupon == null) return;

      final updatedRedemptions = coupon.redemptions.map((r) {
        if (r.id == redemptionId) {
          return CouponRedemption(
            id: r.id,
            userId: r.userId,
            scannedAt: r.scannedAt,
            redeemedAt: redeemedAt,
            expiresAt: r.expiresAt,
            status: status,
          );
        }
        return r;
      }).toList();

      await _firestore
          .collection('coupons')
          .doc(couponId)
          .update({
        'redemptions': updatedRedemptions.map((r) => r.toJson()).toList(),
      });
    } catch (e) {
      print('Error updating redemption status: $e');
    }
  }

  // Redeem a coupon (old method - keep for compatibility)
  static Future<bool> redeemCoupon({
    required String userId,
    required String couponId,
    required String merchantQrToken,
  }) async {
    try {
      // Mark coupon as used
      await _firestore.collection('coupons').doc(couponId).update({
        'used': true,
      });

      // Add to user's redeemed coupons
      await _firestore.collection('users').doc(userId).update({
        'redeemedCoupons': FieldValue.arrayUnion([
          {
            'couponId': couponId,
            'redeemedAt': DateTime.now(),
            'merchantQrToken': merchantQrToken,
          },
        ]),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
