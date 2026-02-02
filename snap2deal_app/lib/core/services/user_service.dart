import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class UserService {
  static Future<bool> updateProfile({
    required String name,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return false;
      }

      final success = await FirestoreService.updateUserProfile(
        userId: userId,
        name: name,
        email: email,
      );

      if (success) {
        // Update local storage
        await prefs.setString('userName', name);
        if (email != null) {
          await prefs.setString('userEmail', email);
        }
      }

      return success;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchProfileStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return null;

      return await FirestoreService.getProfileStats(userId);
    } catch (e) {
      print('❌ Error fetching profile stats: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return null;
      }

      return await FirestoreService.getSubscriptionStatus(userId);
    } catch (e) {
      print('❌ Error getting subscription status: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getMerchants() async {
    return FirestoreService.getMerchants();
  }
}
