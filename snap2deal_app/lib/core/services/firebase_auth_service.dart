import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📲 SEND OTP - Returns verificationId via callback
  static Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    try {
      // ✅ VALIDATE PHONE NUMBER
      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

      if (cleanPhone.isEmpty) {
        onError('❌ Phone number is empty');
        return;
      }

      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.length != 10) {
          onError(
            '❌ Invalid phone format: Must be 10 digits (e.g., 9876543210)',
          );
          return;
        }
        cleanPhone = '+91$cleanPhone';
      } else {
        if (cleanPhone.length < 10) {
          onError('❌ Invalid phone format: Phone number too short');
          return;
        }
      }

      print('📞 Sending OTP to: $cleanPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: cleanPhone,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verified phone');
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          } else {
            await _auth.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ OTP Verification Failed');
          print('   Error Code: ${e.code}');
          print('   Message: ${e.message}');

          String userMessage = _getErrorMessage(e.code, e.message);
          onError(userMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP Sent Successfully');
          print('   Phone: $cleanPhone');
          print('   Verification ID: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto retrieval timeout. User must enter OTP manually.');
        },
      );
    } catch (e) {
      print('❌ Error sending OTP: $e');
      onError('❌ Error sending OTP: $e');
    }
  }

  // 🔍 MAP FIREBASE ERROR CODES TO USER-FRIENDLY MESSAGES
  static String _getErrorMessage(String code, String? message) {
    switch (code) {
      case 'invalid-phone-number':
        return '❌ Invalid phone number format.\n\nExpected: 10-digit number (9876543210)\nor +country-code format (+919876543210)';
      case 'missing-phone-number':
        return '❌ Phone number is missing or empty';
      case 'too-many-requests':
        return '❌ Too many attempts. Try again later (5+ minutes)';
      case 'network-request-failed':
        return '❌ Network error. Check internet connection';
      case 'internal-error':
        return '❌ Firebase internal error. Try again shortly';
      case 'quota-exceeded':
        return '❌ SMS quota exceeded for this project. Contact Firebase support';
      case 'unsupported-first-factor':
        return '❌ Phone authentication not supported in your Firebase project';
      case 'billing-not-enabled':
        return '❌ Phone authentication requires billing account.\n\n✅ FIX:\n1. Go to Firebase Console\n2. Click "Billing" (left sidebar)\n3. Attach a billing account\n4. Wait 5 mins, retry';
      case 'operation-not-allowed':
        return '❌ Phone sign-in is disabled.\n\n✅ FIX:\n1. Go to Firebase Console → Authentication\n2. Click "Sign-in method"\n3. Enable "Phone" provider\n4. Click Save, wait 1 min';
      default:
        return '❌ ${message ?? "OTP verification failed. Please try again"}';
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
