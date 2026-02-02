import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📲 SEND OTP
  static Future<bool> sendOtp(String phone) async {
    try {
      // Format phone with country code if needed
      String formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ OTP Verification Failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP Sent to $phone. Verification ID: $verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto retrieval timeout');
        },
      );
      return true;
    } catch (e) {
      print('❌ Error sending OTP: $e');
      return false;
    }
  }

  // ✅ VERIFY OTP + CREATE USER
  static Future<bool> verifyOtp(
    String phone,
    String otp,
    String name,
    String? email,
    String verificationId,
  ) async {
    try {
      // Create credential from OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user == null) {
        return false;
      }

      String formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user document
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'phone': formattedPhone,
          'email': email ?? '',
          'isVerified': true,
          'createdAt': DateTime.now(),
          'subscriptionId': null,
          'subscriptionExpiry': null,
          'isSubscribed': false,
        });
      } else {
        // Update existing user
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'email': email ?? '',
          'isVerified': true,
        });
      }

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.uid);
      await prefs.setString('userPhone', formattedPhone);
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email ?? '');

      print('✅ USER SAVED: ${user.uid}');
      return true;
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return false;
    }
  }

  // 🚪 LOGOUT
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ User logged out');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  // 🔍 GET CURRENT USER
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }
}
