import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';

class VendorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Vendor>> fetchVendors() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('merchants')
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No vendors available');
      }

      final List<Vendor> vendors = snapshot.docs
          .map((doc) => Vendor.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return vendors;
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Register a new vendor (creates pending approval document)
  static Future<bool> registerVendor({
    required String vendorId,
    required String name,
    required String email,
    required String phoneNumber,
    required String category,
    required String description,
    required String location,
    required String address,
  }) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).set({
        'id': vendorId,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'category': category,
        'description': description,
        'location': location,
        'address': address,
        'status': 'pending',
        'isApproved': false,
        'createdAt': DateTime.now(),
        'image': '',
        'logo': null,
        'banner': null,
        'rating': 0.0,
        'reviews': 0,
        'timing': '',
        'minOrder': 0,
        'totalCoupons': 0,
        'redeemedCoupons': 0,
      });
      return true;
    } catch (e) {
      print('Error registering vendor: $e');
      return false;
    }
  }

  // Get all pending vendors (for admin approval)
  static Future<List<Vendor>> getPendingVendors() async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Vendor.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching pending vendors: $e');
      return [];
    }
  }

  // Get all approved vendors
  static Future<List<Vendor>> getApprovedVendors() async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Vendor.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching approved vendors: $e');
      return [];
    }
  }

  // Get vendor by ID
  static Future<Vendor?> getVendorById(String vendorId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(vendorId).get();
      if (doc.exists) {
        return Vendor.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching vendor: $e');
      return null;
    }
  }

  // Approve vendor (admin action)
  static Future<bool> approveVendor(
    String vendorId, {
    String? adminNotes,
  }) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).update({
        'status': 'approved',
        'isApproved': true,
        'approvedAt': DateTime.now(),
        'adminNotes': adminNotes,
      });
      return true;
    } catch (e) {
      print('Error approving vendor: $e');
      return false;
    }
  }

  // Reject vendor (admin action)
  static Future<bool> rejectVendor(
    String vendorId, {
    required String adminNotes,
  }) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).update({
        'status': 'rejected',
        'isApproved': false,
        'adminNotes': adminNotes,
      });
      return true;
    } catch (e) {
      print('Error rejecting vendor: $e');
      return false;
    }
  }

  // Update vendor logo and banner
  static Future<bool> updateVendorImages(
    String vendorId, {
    String? logoUrl,
    String? bannerUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (logoUrl != null) updateData['logo'] = logoUrl;
      if (bannerUrl != null) updateData['banner'] = bannerUrl;

      await _firestore.collection('vendors').doc(vendorId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating vendor images: $e');
      return false;
    }
  }

  // Update vendor basic info
  static Future<bool> updateVendor(
    String vendorId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).update(data);
      return true;
    } catch (e) {
      print('Error updating vendor: $e');
      return false;
    }
  }

  // Get all vendors (for admin dashboard)
  static Future<List<Vendor>> getAllVendors() async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Vendor.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all vendors: $e');
      return [];
    }
  }

  // Get vendor statistics
  static Future<Map<String, int>> getVendorStats() async {
    try {
      final all = await _firestore.collection('vendors').count().get();
      final pending = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final approved = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();
      final rejected = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();

      return {
        'total': all.count ?? 0,
        'pending': pending.count ?? 0,
        'approved': approved.count ?? 0,
        'rejected': rejected.count ?? 0,
      };
    } catch (e) {
      print('Error fetching vendor stats: $e');
      return {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }
}
