import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📦 COLLECTIONS
  static const String usersCollection = 'users';
  static const String couponsCollection = 'coupons';
  static const String merchantsCollection = 'merchants';
  static const String userCouponsCollection = 'userCoupons';
  static const String subscriptionsCollection = 'subscriptions';
  static const String scansCollection = 'scans';

  // 🛍️ GET COUPONS BY MERCHANT
  static Future<Map<String, dynamic>> getCouponsByMerchant(
    String merchantId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      // Get all coupons for this merchant
      final couponsSnapshot = await _firestore
          .collection(couponsCollection)
          .where('merchantId', isEqualTo: merchantId)
          .get();

      List<Map<String, dynamic>> coupons = [];

      // Get used coupons for this user (only if logged in)
      List<String> usedCouponIds = [];
      if (userId != null) {
        final usedSnapshot = await _firestore
            .collection(userCouponsCollection)
            .where('userId', isEqualTo: userId)
            .get();

        usedCouponIds = usedSnapshot.docs
            .map((doc) => doc['couponId'] as String)
            .toList();
      }

      // Filter out used coupons
      for (var doc in couponsSnapshot.docs) {
        if (!usedCouponIds.contains(doc.id)) {
          coupons.add({'id': doc.id, ...doc.data()});
        }
      }

      return {'isSubscribed': userId != null, 'coupons': coupons};
    } catch (e) {
      print('❌ Error getting coupons: $e');
      return {'isSubscribed': false, 'coupons': []};
    }
  }

  // 🧾 GET USER PROFILE STATS
  static Future<Map<String, dynamic>?> getProfileStats(String userId) async {
    try {
      // Get user subscription status
      DocumentSnapshot userDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};

      // Get total coupons count
      final allCouponsSnapshot = await _firestore
          .collection(couponsCollection)
          .get();
      int totalCoupons = allCouponsSnapshot.docs.length;

      // Get used coupons for this user
      final usedCouponsSnapshot = await _firestore
          .collection(userCouponsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      int usedCoupons = usedCouponsSnapshot.docs.length;
      int couponsLeft = totalCoupons - usedCoupons;

      return {
        'couponsLeft': couponsLeft,
        'usedCoupons': usedCoupons,
        'totalSaved': totalCoupons,
        'isSubscribed': userData['isSubscribed'] ?? false,
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print(
          '❌ ERROR: Permission denied accessing Firestore. Follow the FIRESTORE_SECURITY_RULES_SETUP.md guide to deploy rules in Firebase Console.',
        );
      } else if (e.code == 'unavailable') {
        print(
          '❌ ERROR: Firestore unavailable. Check internet connection and that Firebase initialized properly.',
        );
      } else {
        print('❌ Error getting profile stats: $e');
      }
      return null;
    } catch (e) {
      print('❌ Error getting profile stats: $e');
      return null;
    }
  }

  // ✅ REDEEM COUPON
  static Future<bool> redeemCoupon({
    required String userId,
    required String couponId,
    required String merchantQrToken,
  }) async {
    try {
      // Verify merchant QR token (optional security check)
      final couponDoc = await _firestore
          .collection(couponsCollection)
          .doc(couponId)
          .get();

      if (!couponDoc.exists) {
        print('❌ Coupon not found');
        return false;
      }

      Map<String, dynamic> couponData = couponDoc.data() ?? {};

      // Create scan log
      await _firestore.collection(scansCollection).add({
        'userId': userId,
        'couponId': couponId,
        'merchantId': couponData['merchantId'],
        'merchantQrToken': merchantQrToken,
        'scannedAt': DateTime.now(),
      });

      // Create user coupon record (to track usage)
      await _firestore.collection(userCouponsCollection).add({
        'userId': userId,
        'couponId': couponId,
        'redeemedAt': DateTime.now(),
      });

      print('✅ Coupon redeemed successfully');
      return true;
    } catch (e) {
      print('❌ Error redeeming coupon: $e');
      return false;
    }
  }

  // 🎟️ GET USER COUPONS
  static Future<List<dynamic>> getUserCoupons(String userId) async {
    try {
      final userCouponsSnapshot = await _firestore
          .collection(userCouponsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      List<dynamic> coupons = [];
      for (var doc in userCouponsSnapshot.docs) {
        final couponId = doc['couponId'];
        final couponDoc = await _firestore
            .collection(couponsCollection)
            .doc(couponId)
            .get();

        if (couponDoc.exists) {
          coupons.add({
            'id': couponId,
            ...couponDoc.data() as Map<String, dynamic>,
          });
        }
      }

      return coupons;
    } catch (e) {
      print('❌ Error getting user coupons: $e');
      return [];
    }
  }

  // 📝 UPDATE USER PROFILE
  static Future<bool> updateUserProfile({
    required String userId,
    required String name,
    String? email,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'name': name,
        'email': email,
      });

      print('✅ Profile updated');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  // 🏪 GET MERCHANTS LIST
  static Future<List<Map<String, dynamic>>> getMerchants() async {
    try {
      final snapshot = await _firestore
          .collection(merchantsCollection)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('❌ Error getting merchants: $e');
      return [];
    }
  }

  // 💳 GET SUBSCRIPTION STATUS
  static Future<Map<String, dynamic>?> getSubscriptionStatus(
    String userId,
  ) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};

      return {
        'isSubscribed': userData['isSubscribed'] ?? false,
        'subscriptionExpiry': userData['subscriptionExpiry'],
        'subscriptionId': userData['subscriptionId'],
      };
    } catch (e) {
      print('❌ Error getting subscription: $e');
      return null;
    }
  }

  // 💰 UPDATE SUBSCRIPTION
  static Future<bool> updateSubscription({
    required String userId,
    required String subscriptionId,
    required DateTime expiryDate,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'subscriptionId': subscriptionId,
        'subscriptionExpiry': expiryDate,
        'isSubscribed': true,
      });

      print('✅ Subscription updated');
      return true;
    } catch (e) {
      print('❌ Error updating subscription: $e');
      return false;
    }
  }
}
