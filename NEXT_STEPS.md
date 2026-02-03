# 🎯 NEXT STEPS - What You Need To Do

Your complete Admin & Vendor system is built and ready. Here are the exact steps to integrate it into your app.

---

## Phase 1: Prepare (5 minutes)

### Step 1.1: Install Dependencies
```bash
cd snap2deal_app
flutter pub get
```

This installs the 4 new packages:
- uuid (ID generation)
- qr_flutter (QR code generation)
- image_picker (image selection)
- firebase_storage (image upload)

**Expected output:** "Resolving dependencies..." → "Got dependencies"

---

## Phase 2: Setup Firebase (10 minutes)

### Step 2.1: Create Admin Account
1. Go to Firebase Console → Authentication
2. Create email/password user:
   - Email: `admin@snap2deal.com`
   - Password: (secure password)
3. Copy the UID
4. Go to Firestore Console
5. Create new document in `admins` collection:
   ```
   Document ID: {paste UID from step 3}
   Fields:
   - name: "Admin"
   - email: "admin@snap2deal.com"
   - phoneNumber: "+1234567890"
   - role: "admin"
   - isActive: true
   - createdAt: (current timestamp)
   ```

**Verification:** You should be able to login with email/password in admin_login_screen.dart

### Step 2.2: Deploy Firestore Rules
1. Go to Firestore Console → Rules tab
2. Replace existing rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Admin collection - only admins can read/write
    match /admins/{adminId} {
      allow read, write: if request.auth.uid in get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.keys();
    }

    // Vendors collection
    match /vendors/{vendorId} {
      // Vendor can read/write own data
      allow read, write: if request.auth.uid == vendorId;
      // Admin can read all
      allow read: if request.auth.uid in get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.keys();
    }

    // Coupons collection
    match /coupons/{couponId} {
      allow read, write: if request.auth.uid == resource.data.vendorId || 
                            request.auth.uid in get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.keys();
    }
  }
}
```

3. Click Publish

**Verification:** Should show "✓ Successfully published"

### Step 2.3: Deploy Firebase Storage Rules
1. Go to Firebase Console → Storage → Rules tab
2. Replace with these rules:

```storage
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /vendor_logos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /vendor_banners/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /qr_codes/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

3. Click Publish

**Verification:** Should show "✓ Successfully published"

---

## Phase 3: Update Main App Navigation (10 minutes)

### Step 3.1: Add AuthGate Class
Open `lib/main.dart` and add this before your main MaterialApp:

```dart
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return const RoleSelectionScreen();
        }

        // Logged in - determine role
        final userId = snapshot.data!.uid;
        
        return FutureBuilder<String?>(
          future: _getUserRole(userId),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;
            
            if (role == 'admin') {
              return const AdminDashboardScreen();
            } else if (role == 'vendor') {
              return const VendorDashboardScreen();
            } else {
              return const HomeScreen(); // Regular user
            }
          },
        );
      },
    );
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      // Check admin collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userId)
          .get();
      if (adminDoc.exists) return 'admin';

      // Check vendor collection
      final vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(userId)
          .get();
      if (vendorDoc.exists) return 'vendor';

      return 'user';
    } catch (e) {
      return 'user';
    }
  }
}
```

### Step 3.2: Update MaterialApp
Replace your MaterialApp with:

```dart
MaterialApp(
  home: const AuthGate(),
  routes: {
    '/admin-dashboard': (context) => const AdminDashboardScreen(),
    '/admin-vendor-approval': (context) => const VendorApprovalScreen(),
    '/admin-coupon-approval': (context) => const CouponApprovalScreen(),
    '/admin-users': (context) => const UsersListScreen(),
    '/vendor-dashboard': (context) => const VendorDashboardScreen(),
    '/vendor-upload-media': (context) => const UploadMediaScreen(),
    '/vendor-create-coupon': (context) => const CreateCouponScreen(),
    '/vendor-analytics': (context) => const VendorAnalyticsScreen(),
    '/redemption-timer': (context) => const CouponRedemptionTimerScreen(),
  },
)
```

### Step 3.3: Add Imports
Make sure these imports are in main.dart:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap2deal_app/screens/admin/admin_dashboard_screen.dart';
import 'package:snap2deal_app/screens/admin/vendor_approval_screen.dart';
import 'package:snap2deal_app/screens/admin/coupon_approval_screen.dart';
import 'package:snap2deal_app/screens/admin/users_list_screen.dart';
import 'package:snap2deal_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:snap2deal_app/screens/vendor/upload_media_screen.dart';
import 'package:snap2deal_app/screens/vendor/create_coupon_screen.dart';
import 'package:snap2deal_app/screens/vendor/vendor_analytics_screen.dart';
import 'package:snap2deal_app/screens/scan/coupon_redemption_timer_screen.dart';
```

**Verification:** main.dart should compile without errors

---

## Phase 4: Create Role Selection Screen (5 minutes)

Create new file: `lib/screens/role_selection_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'admin/admin_login_screen.dart';
import 'vendor/vendor_login_screen.dart';
import '../screens/home/home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, 
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen())
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Login as Admin', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VendorLoginScreen())
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Login as Vendor', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen())
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Continue as User', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Phase 5: Test Everything (varies)

### Test 5.1: Admin Panel
1. Run app: `flutter run`
2. Select "Login as Admin"
3. Enter admin email/password (from Step 2.1)
4. Should see dashboard with 6 stats
5. Try navigating to approvals

**Expected:** Dashboard loads with stats

### Test 5.2: Vendor Registration
1. Go back to role selection
2. Select "Login as Vendor"
3. Try to login (should fail - no approved vendors)
4. Go back
5. Go to Admin Dashboard → Vendor Approval
6. (You need to manually add a vendor to Firestore to test)

**To manually add a vendor for testing:**
1. Firestore Console
2. Create document in `vendors` collection:
   ```
   Document ID: vendor123
   Fields:
   - name: "Test Vendor"
   - email: "vendor@test.com"
   - phoneNumber: "+9876543210"
   - status: "pending"
   - category: "Food"
   - location: "City"
   ```
3. In admin panel, click Approve
4. Now vendor can login with email + phone

### Test 5.3: Coupon Flow
1. Login as vendor (from test 5.2)
2. Click "Create Coupon"
3. Fill form and create coupon
4. Go to Admin Dashboard → Coupon Approval
5. Approve coupon
6. Go to user QR scanning
7. Scan (note: you'll need to generate QR for testing)

**Expected:** 3-minute timer starts, countdown works

### Test 5.4: Redemption Timer
1. From test 5.3, when timer is running:
2. Watch countdown (should tick every second)
3. Wait for vendor to "Confirm Redemption"
4. Coupon should mark as redeemed
5. Or wait 3 minutes for timer to expire

**Expected:** Timer counts down, status updates correctly

---

## Phase 6: Verify Firestore (5 minutes)

Check these collections exist and have data:

```
Firestore Collections:
├── admins/ ✓ (1 document - your admin account)
├── vendors/ ✓ (documents created/updated)
├── coupons/ ✓ (documents created/updated)
├── users/ ✓ (existing user accounts)
```

**How to check:**
1. Firestore Console
2. Look for collections list on left
3. Click each to verify data

---

## Phase 7: Deploy to Real Device

### For iOS:
```bash
flutter build ios
# Then use Xcode to deploy
```

### For Android:
```bash
flutter build apk
# Install on device
flutter install
```

---

## ✅ Completion Checklist

- [ ] Phase 1: Dependencies installed
- [ ] Phase 2: Firebase rules deployed
- [ ] Phase 2: Admin account created
- [ ] Phase 3: main.dart updated with AuthGate
- [ ] Phase 3: Routes added
- [ ] Phase 4: RoleSelectionScreen created
- [ ] Phase 5: Admin panel tested
- [ ] Phase 5: Vendor flow tested
- [ ] Phase 5: Coupon creation tested
- [ ] Phase 5: Redemption timer tested
- [ ] Phase 6: Firestore verified
- [ ] Phase 7: Deployed to real device

---

## 🆘 Common Issues & Fixes

### Issue: Admin Can't Login
**Solution:**
1. Check admin email in Firebase Auth
2. Check admin document in Firestore (should have role: "admin")
3. Check security rules are deployed
4. Check Firestore has data

### Issue: Vendor Can't Login
**Solution:**
1. Check vendor status = "approved" in Firestore
2. Check email + phone match exactly
3. Check vendor was approved by admin
4. Check SharedPreferences is working

### Issue: Timer Not Working
**Solution:**
1. Check redemption.expiresAt is set to scanTime + 3 min
2. Check Timer starts in initState
3. Check DateTime.now() comparisons are correct
4. Check Firestore updates when vendor confirms

### Issue: Images Not Uploading
**Solution:**
1. Check Firebase Storage rules are deployed
2. Check permissions on device
3. Check Firebase Storage bucket exists
4. Check internet connection

### Issue: Compilation Errors
**Solution:**
1. Run `flutter pub get`
2. Run `flutter clean`
3. Check all imports are correct
4. Check file names match exactly

---

## 📞 Reference Documents

- **Setup Issues?** → INTEGRATION_GUIDE.md
- **Need Details?** → ADMIN_VENDOR_IMPLEMENTATION.md
- **Quick Answers?** → QUICK_REFERENCE.md
- **Full Testing?** → TESTING_CHECKLIST.md
- **Where is What?** → FILE_INVENTORY.md

---

## 🚀 You're Ready!

Follow these steps and your app will have a complete admin & vendor system with:
✅ Admin approval workflows
✅ Vendor management
✅ Coupon creation & approval
✅ 3-minute redemption timer
✅ Analytics dashboards
✅ Complete security

**Start with Phase 1 and work through Phase 7.**

Good luck! 🎉

