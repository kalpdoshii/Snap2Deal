# Integration Guide - Adding Admin & Vendor Panels to Main App

## Step 1: Update main.dart with Navigation

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/vendor/vendor_login_screen.dart';
import 'screens/vendor/vendor_dashboard_screen.dart';
import 'core/services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Snap2DealApp());
}

class Snap2DealApp extends StatelessWidget {
  const Snap2DealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap2Deal',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/vendor-login': (context) => const VendorLoginScreen(),
        '/vendor-dashboard': (context) => const VendorDashboardScreen(),
      },
    );
  }
}

// Auth Gate - Routes user to correct dashboard
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<String?> _checkUserType;

  @override
  void initState() {
    super.initState();
    _checkUserType = _determineUserType();
  }

  Future<String?> _determineUserType() async {
    final adminUser = FirebaseAuth.instance.currentUser;
    
    if (adminUser != null) {
      // Check if admin
      final isAdmin = await AdminService.isUserAdmin(adminUser.uid);
      if (isAdmin) {
        return 'admin';
      }
    }

    // For vendor, check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getString('vendorId');
    if (vendorId != null) {
      return 'vendor';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _checkUserType,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data == 'admin') {
            return const AdminDashboardScreen();
          } else if (snapshot.data == 'vendor') {
            return const VendorDashboardScreen();
          }
        }

        return const SplashScreen();
      },
    );
  }
}
```

## Step 2: Add Role Selection Screen (Optional)

Create a new screen to let users choose their role:

```dart
// screens/auth/role_selection_screen.dart

import 'package:flutter/material.dart';
import '../admin/admin_login_screen.dart';
import '../vendor/vendor_login_screen.dart';
import '../splash/splash_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Snap2Deal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildRoleCard(
              'User',
              'Browse and redeem coupons',
              Icons.shopping_bag,
              Colors.blue,
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              'Vendor',
              'Manage your store and coupons',
              Icons.storefront,
              Colors.orange,
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const VendorLoginScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              'Admin',
              'Manage vendors and coupons',
              Icons.admin_panel_settings,
              Colors.red,
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
```

## Step 3: Update Splash Screen

Modify your splash screen to route to the role selection:

```dart
// In splash_screen.dart, after logo animation:

Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
);
```

## Step 4: Firebase Firestore Security Rules

Set up these security rules in Firebase Console:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Admins collection
    match /admins/{document=**} {
      allow read, write: if request.auth.uid == document;
      allow read: if get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null;
    }
    
    // Vendors collection
    match /vendors/{vendorId} {
      allow read: if true; // Public read for discovery
      allow create: if request.auth.uid != null; // Anyone can request vendor status
      allow update, delete: if request.auth.uid == vendorId
                           || get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null;
      allow read, write: if get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null; // Admins can do anything
    }
    
    // Coupons collection
    match /coupons/{couponId} {
      allow read: if resource.data.status == 'approved' || request.auth.uid == resource.data.vendorId;
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.vendorId
                           || get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null;
    }
    
    // Users collection (existing)
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## Step 5: Firebase Storage Rules

Set up storage rules:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Vendor logos and banners
    match /vendor_logos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid != null;
    }
    
    match /vendor_banners/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid != null;
    }
    
    // QR codes
    match /qr_codes/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid != null;
    }
  }
}
```

## Step 6: Create Initial Admin Account

1. Go to Firebase Console
2. Authentication → Users
3. Click "Add User"
4. Create admin with email/password
5. Go to Firestore → Create "admins" collection
6. Create document with ID = admin's UID
7. Set fields: name, email, phoneNumber, role: "super_admin", isActive: true, createdAt: now()

## Step 7: Testing the System

### Test Admin Panel:
1. Open app
2. Select "Admin" role
3. Login with admin credentials
4. Should see dashboard with stats
5. Test: Approve vendors, approve coupons

### Test Vendor Panel:
1. First, register vendor through Firebase
2. Approve vendor through admin panel
3. Open app, select "Vendor" role
4. Login with vendor email + phone
5. Upload logo/banner
6. Create coupon (should go to pending)
7. Approve coupon through admin panel
8. See QR code appear

### Test User Panel:
1. Open app, select "User" role
2. Scan QR code from approved coupon
3. Should see 3-minute timer
4. Timer counts down
5. Test expiry and redemption scenarios

## Step 8: Add Required Imports

Make sure to add these imports to your main.dart:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/role_selection_screen.dart';
```

## Troubleshooting

### Admin Can't Login
- Check Firebase project has Authentication enabled
- Verify admin UID matches document ID in admins collection
- Check Firestore security rules allow admin access

### Vendor Can't Login  
- Verify vendor email + phone exist and match vendor document
- Check vendor status is "approved"
- Verify vendorId is being saved to SharedPreferences

### QR Code Not Showing
- Ensure coupon status is "approved"
- Check qr_flutter dependency is installed
- Verify approvalCoupon() is saving QR data

### 3-Minute Timer Not Working
- Check DateTime.now() is accurate
- Verify redemption.expiresAt is calculated correctly
- Check timer is being started in initState

---

## Deployment Checklist

- [ ] Run `flutter pub get`
- [ ] Update main.dart with navigation
- [ ] Create FirebaseStorage/Rules
- [ ] Create Firestore Security Rules
- [ ] Create admin account in Firebase
- [ ] Test all three user flows
- [ ] Test vendor approval workflow
- [ ] Test coupon approval workflow
- [ ] Test redemption timer
- [ ] Deploy to test device/emulator
- [ ] Monitor Firestore for data integrity
