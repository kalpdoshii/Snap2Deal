import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_model.dart';
import '../models/vendor_model.dart';
import '../models/coupon_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register admin (super admin creates other admins)
  static Future<bool> registerAdmin({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String role = 'admin',
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin document in Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role,
        'isActive': true,
        'createdAt': DateTime.now(),
        'profileImage': null,
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print('Error registering admin: ${e.message}');
      return false;
    } catch (e) {
      print('Error registering admin: $e');
      return false;
    }
  }

  // Login admin
  static Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify it's an admin
      final doc = await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();
      if (!doc.exists) {
        await _auth.signOut();
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      print('Error logging in admin: ${e.message}');
      return false;
    } catch (e) {
      print('Error logging in admin: $e');
      return false;
    }
  }

  // Get current admin
  static Future<Admin?> getCurrentAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('admins').doc(user.uid).get();
      if (!doc.exists) return null;

      return Admin.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching current admin: $e');
      return null;
    }
  }

  // Get admin by ID
  static Future<Admin?> getAdminById(String adminId) async {
    try {
      final doc = await _firestore.collection('admins').doc(adminId).get();
      if (doc.exists) {
        return Admin.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching admin: $e');
      return null;
    }
  }

  // Get all admins
  static Future<List<Admin>> getAllAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('admins')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Admin.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final vendorStats = await _firestore.collection('vendors').count().get();

      final pendingVendors = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final users = await _firestore.collection('users').count().get();

      final totalCoupons = await _firestore.collection('coupons').count().get();

      final pendingCoupons = await _firestore
          .collection('coupons')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final approvedCoupons = await _firestore
          .collection('coupons')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();

      return {
        'totalVendors': vendorStats.count,
        'pendingVendors': pendingVendors.count,
        'totalUsers': users.count,
        'totalCoupons': totalCoupons.count,
        'pendingCoupons': pendingCoupons.count,
        'approvedCoupons': approvedCoupons.count,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'totalVendors': 0,
        'pendingVendors': 0,
        'totalUsers': 0,
        'totalCoupons': 0,
        'pendingCoupons': 0,
        'approvedCoupons': 0,
      };
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Get all vendors with details
  static Future<List<Vendor>> getAllVendorsWithDetails() async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Vendor.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  // Get all pending coupons
  static Future<List<Coupon>> getAllPendingCoupons() async {
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

  // Logout admin
  static Future<void> logoutAdmin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out admin: $e');
    }
  }

  // Check if user is admin
  static Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('admins').doc(userId).get();
      return doc.exists && doc.get('isActive') == true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is vendor
  static Future<bool> isUserVendor(String userId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(userId).get();
      return doc.exists && doc.get('status') == 'approved';
    } catch (e) {
      return false;
    }
  }
}
