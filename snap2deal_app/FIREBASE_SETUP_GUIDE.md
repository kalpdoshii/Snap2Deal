# Firebase Migration Setup Guide

## ✅ Completed Setup

Your Flutter app is now configured for Firebase with the following:

### Files Created/Updated:
1. ✅ `lib/firebase_options.dart` - Firebase configuration
2. ✅ `lib/main.dart` - Firebase initialization
3. ✅ `lib/core/services/firebase_auth_service.dart` - Phone OTP authentication
4. ✅ `lib/core/services/firestore_service.dart` - Database operations
5. ✅ `lib/core/services/coupon_service.dart` - Updated for Firestore
6. ✅ `lib/core/services/user_service.dart` - Updated for Firestore
7. ✅ `pubspec.yaml` - Firebase dependencies added
8. ✅ `FIRESTORE_RULES.txt` - Security rules

---

## 🚀 Next Steps

### Step 1: Configure Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your `snap2deal-492a4` project
3. In **Build** section:
   - **Authentication**: Enable "Phone" provider
   - **Firestore Database**: Create in `production` mode, region `us-central1`
   - **Storage**: Create bucket (for future image uploads)

### Step 2: Set Firestore Security Rules

1. In Firebase Console → Firestore Database → **Rules** tab
2. Delete default rules
3. Copy entire content from `FIRESTORE_RULES.txt` and paste
4. Click **Publish**

### Step 3: Create Firestore Collections & Add Sample Data

Run this in Firebase Console (Firestore → Start a collection):

**Collection: `merchants`**
```
Document ID: merchant_001
{
  "id": "merchant_001",
  "name": "Spice Garden",
  "category": "restaurant",
  "address": "123 Main St",
  "description": "Indian restaurant with exclusive deals",
  "image": "https://example.com/image.jpg"
}
```

**Collection: `coupons`**
```
Document ID: coupon_001
{
  "id": "coupon_001",
  "merchantId": "merchant_001",
  "title": "50% Off on Appetizers",
  "description": "Get 50% discount on all appetizers",
  "discount": "50%",
  "validity": "30 days",
  "isLocked": false,
  "createdAt": (current timestamp)
}
```

### Step 4: Download Firebase Config Files

#### For Android:
1. Firebase Console → Project Settings → Your Apps → Android app
2. Download `google-services.json`
3. Place in: `snap2deal_app/android/app/`

#### For iOS:
1. Firebase Console → Project Settings → Your Apps → iOS app
2. Download `GoogleService-Info.plist`
3. Place in: `snap2deal_app/ios/Runner/`

### Step 5: Update Android Configuration

Edit `snap2deal_app/android/build.gradle`:
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

Edit `snap2deal_app/android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation 'com.google.firebase:firebase-auth-ktx'
  implementation 'com.google.firebase:firebase-firestore-ktx'
}
```

### Step 6: Update iOS Configuration (if needed)

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Add `GoogleService-Info.plist` to Runner
3. Ensure it's added to target `Runner`

### Step 7: Run Flutter App

```bash
cd snap2deal_app

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on Android
flutter run

# Or run on iOS
flutter run -d ios
```

### Step 8: Enable Phone Authentication

In Firebase Console:
1. Go to **Authentication** → **Sign-in method**
2. Enable **Phone** provider
3. Add your testing number (optional, for development)

---

## 📱 OTP Flow Now Works Like This:

1. User enters name, email, phone
2. Clicks "Send OTP"
3. Firebase sends OTP via SMS
4. User enters 6-digit OTP
5. OTP verified → User created in Firestore
6. User data saved to SharedPreferences & Firestore
7. User navigated to MainScreen

---

## 🗑️ Delete Old Backend (Optional)

Since we're fully on Firebase now, you can delete the Node.js backend:

```powershell
Remove-Item -Recurse -Force "C:\Users\kalpd\OneDrive\Desktop\Snap2Deal\backend"
```

---

## 🔒 Important Security Notes

1. **Phone Authentication**: Firebase handles OTP securely
2. **Firestore Rules**: Restrict access to user's own data
3. **Admin Claims**: Set custom claims for admin users (for managing coupons)
4. **API Keys**: The web API key in `firebase_options.dart` is public (expected in client apps)

---

## 🧪 Testing the Setup

1. **Test OTP Login**:
   - App should accept any 10-digit number
   - Firebase sends OTP (check SMS or Firebase Console logs)
   - Enter OTP to verify

2. **Test Firestore**:
   - Profile should show saved name/phone/email
   - Vendors/Coupons should load from Firestore
   - Redeeming coupons creates records in `userCoupons` collection

3. **Test Security Rules**:
   - Logged-in user can only read their own profile
   - Anyone can read coupons/merchants
   - Only admins can create/edit coupons

---

## ❓ Troubleshooting

**OTP not sending?**
- Check Firebase Console → Authentication → Phone provider enabled
- Verify phone number format (+91 for India)
- Check Firebase quota limits

**"User not found" after login?**
- Check Firestore → users collection
- Ensure security rules allow read/write

**App crashes on startup?**
- Run `flutter pub get`
- Clear build: `flutter clean && flutter pub get`
- Check for missing imports

---

## 📞 Support

For Firebase issues, check:
- [Firebase Docs](https://firebase.flutter.dev/)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Firestore Docs](https://firebase.google.com/docs/firestore)
