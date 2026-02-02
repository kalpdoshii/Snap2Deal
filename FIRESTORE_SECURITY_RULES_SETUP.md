# ⚠️ FIRESTORE SECURITY RULES SETUP (URGENT)

## Problem
Your app is getting these errors:
- `[cloud_firestore/permission-denied] Missing or insufficient permissions`
- `[cloud_firestore/unavailable] Failed to get document because the client is offline`

**Root Cause:** Firestore security rules are NOT set in Firebase Console. Without rules, all database access is denied by default.

---

## Solution: Deploy Firestore Rules

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select project **snap2deal-492a4**

### Step 2: Navigate to Firestore Rules
1. Click **Build** in left sidebar
2. Click **Firestore Database**
3. Click **Rules** tab (at the top)

### Step 3: Copy & Paste Security Rules
Replace all text in the Rules editor with these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ✅ Users Collection - Only user can read/write their own document
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
      allow create: if request.auth.uid != null;
    }
    
    // ✅ Coupons Collection - Public read, admin only write
    match /coupons/{couponId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }
    
    // ✅ Merchants Collection - Public read, admin only write
    match /merchants/{merchantId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }
    
    // ✅ User Coupons Collection - Users access their own, admins access all
    match /userCoupons/{docId} {
      allow read: if request.auth.uid == resource.data.userId || request.auth.token.admin == true;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;
    }
    
    // ✅ Scans Collection - Users access their own, admins access all
    match /scans/{scanId} {
      allow read: if request.auth.uid == resource.data.userId || request.auth.token.admin == true;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // ✅ Subscriptions Collection - Users access their own, admins access all
    match /subscriptions/{subId} {
      allow read: if request.auth.uid == resource.data.userId || request.auth.token.admin == true;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### Step 4: Publish Rules
1. Click **Publish** button (top right)
2. Confirm the dialog
3. Wait for deployment to complete (usually 1-2 minutes)

---

## ✅ Verification

After publishing, test if it works:

1. Stop the app (terminate from terminal)
2. Run `flutter pub get` to ensure dependencies are fresh
3. Run `flutter run` (for web) or on Android/iOS
4. Try to view your profile again

You should see:
- ✅ Profile stats loading successfully
- ✅ No "permission-denied" errors
- ✅ Stats display correctly (coupons count, etc.)

---

## 🚨 If you get "Missing or insufficient permissions" AFTER publishing rules:

### Option 1: Verify You're Logged In
- Make sure you've completed phone OTP verification
- Check that `userId` is stored in SharedPreferences
- Sign out and sign in again

### Option 2: Check Firebase Authentication
1. Go to **Build → Authentication** in Firebase Console
2. Go to **Sign-in method** tab
3. Ensure **Phone** is enabled
4. Check your test phone numbers (should include your test number)

### Option 3: Reset Firestore (Development Only)
If testing with dummy data:
1. Go to **Firestore Database**
2. Click menu (⋮) next to database name
3. Delete database
4. Create new database
5. Deploy rules again
6. Create test data via console or app

---

## 📝 Understanding the Rules

| Collection | User Access | Admin Access | Public Read |
|-----------|-----------|-----------|-----------|
| users | Own profile only | All | No |
| coupons | - | Write only | ✅ Yes |
| merchants | - | Write only | ✅ Yes |
| userCoupons | Own records | All | No |
| scans | Own records | All | No |
| subscriptions | Own records | All | No |

---

## 🔐 Important Security Notes

- Rules are **case-sensitive**
- Rules check both **read** and **write** permissions separately
- `request.auth.uid` = current user's Firebase UID
- `request.auth.token.admin = true` = custom claims (set via Admin SDK, not used here yet)
- Without explicit allow, all access is denied (default deny)

---

## ❓ Still Getting Errors?

**If offline error persists:**
- Check internet connection
- Ensure Firebase has initialized in your app (`main.dart` has `Firebase.initializeApp()`)
- Check browser console for Firebase initialization errors

**If permission error persists:**
- Verify rules were published (check timestamp)
- Check user is authenticated (logged in)
- Check userId matches document name in Firestore Console
- Try deleting app cache: `flutter clean && flutter pub get`

---

## Next Steps After Rules Are Deployed

1. ✅ Test profile stats loading
2. Add sample merchants/coupons to Firestore (for testing)
3. Create admin scripts to populate data
4. Deploy app to Android/iOS devices
