# Implementation Checklist - Admin & Vendor System

## Phase 1: Setup & Configuration ✓

### Firebase Configuration
- [ ] Firebase project created
- [ ] Firestore database enabled
- [ ] Firebase Storage bucket configured
- [ ] Authentication enabled (Email/Password)

### Project Setup
- [ ] Run `flutter pub get`
- [ ] All new dependencies installed:
  - [ ] uuid: ^4.0.0
  - [ ] qr_flutter: ^4.1.0
  - [ ] image_picker: ^1.0.4
  - [ ] firebase_storage: ^11.2.0
- [ ] No compilation errors
- [ ] Project builds successfully

---

## Phase 2: Database Setup

### Firestore Collections & Security Rules
- [ ] Copy Firestore rules from INTEGRATION_GUIDE.md
- [ ] Deploy rules to Firebase
- [ ] Create collections (auto-created on first write):
  - [ ] vendors
  - [ ] coupons
  - [ ] admins
  - [ ] users

### Firebase Storage
- [ ] Copy Storage rules from INTEGRATION_GUIDE.md
- [ ] Deploy Storage rules
- [ ] Create folders:
  - [ ] vendor_logos/
  - [ ] vendor_banners/
  - [ ] qr_codes/

### Admin Account Creation
- [ ] Go to Firebase Console → Authentication
- [ ] Create user:
  - Email: `admin@snap2deal.com`
  - Password: `[secure password]`
- [ ] Copy the UID
- [ ] Go to Firestore → admins collection
- [ ] Create new document with ID = UID
- [ ] Add fields:
  ```
  name: "Admin"
  email: "admin@snap2deal.com"
  phoneNumber: "+91 9876543210"
  role: "super_admin"
  isActive: true
  createdAt: [current timestamp]
  profileImage: null
  ```
- [ ] Verify document created successfully

---

## Phase 3: Navigation Setup

### Update main.dart
- [ ] Import all new screens
- [ ] Create AuthGate class
- [ ] Add named routes
- [ ] Test splash → role selection flow
- [ ] No navigation errors

### Create Role Selection Screen (Optional)
- [ ] Create screens/auth/role_selection_screen.dart
- [ ] Add User, Vendor, Admin options
- [ ] Test navigation between roles
- [ ] Design looks good

---

## Phase 4: Admin Panel Testing

### Admin Login Screen
- [ ] [ ] Login page displays correctly
- [ ] [ ] Email field accepts input
- [ ] [ ] Password field toggles visibility
- [ ] [ ] Login button disabled until filled
- [ ] [ ] Error message shows for wrong credentials
- [ ] [ ] Navigates to dashboard on success
- [ ] [ ] Firebase Auth integration working

### Admin Dashboard
- [ ] [ ] Displays all 6 stat cards
- [ ] [ ] Stats load from Firestore
- [ ] [ ] Initial values are 0 or correct
- [ ] [ ] Quick action buttons display
- [ ] [ ] Logout button works
- [ ] [ ] No console errors
- [ ] [ ] Refresh works (reload stats)

### Vendor Approval Screen
- [ ] [ ] Shows list of pending vendors
- [ ] [ ] Vendor details display correctly
- [ ] [ ] Approve button works
- [ ] [ ] Approve updates Firestore
- [ ] [ ] Vendor disappears from pending list
- [ ] [ ] Reject button shows dialog
- [ ] [ ] Reject requires notes
- [ ] [ ] Reject updates Firestore
- [ ] [ ] Admin notes save correctly
- [ ] [ ] List refreshes after action

### Coupon Approval Screen
- [ ] [ ] Shows list of pending coupons
- [ ] [ ] Coupon details display correctly
- [ ] [ ] Vendor name shows
- [ ] [ ] Approve button works
- [ ] [ ] Coupon status updates to "approved"
- [ ] [ ] Reject button works with notes
- [ ] [ ] Admin notes saved
- [ ] [ ] Coupon removed from pending
- [ ] [ ] No errors during approval

### Users List Screen
- [ ] [ ] Displays all users
- [ ] [ ] User details show correctly
- [ ] [ ] Email and phone display
- [ ] [ ] Join date shows
- [ ] [ ] Subscription status shows (if applicable)
- [ ] [ ] List scrolls without errors
- [ ] [ ] Data loads quickly

---

## Phase 5: Vendor Panel Testing

### Vendor Registration
- [ ] [ ] Create test vendor in Firestore manually
  ```
  id: "vendor_test_123"
  name: "Test Vendor"
  email: "vendor@test.com"
  phoneNumber: "+91 1234567890"
  status: "pending"
  // ... other required fields
  ```
- [ ] [ ] Verify document structure

### Vendor Login Screen
- [ ] [ ] Step 1: Email entry field works
- [ ] [ ] Continue button validates email
- [ ] [ ] Step 2: Phone number entry
- [ ] [ ] Back button returns to Step 1
- [ ] [ ] Login button validates data
- [ ] [ ] Incorrect email/phone shows error
- [ ] [ ] Correct credentials navigate to dashboard
- [ ] [ ] VendorId saved to SharedPreferences

### Vendor Dashboard
- [ ] [ ] Pending vendor shows approval view
- [ ] [ ] Admin notes display if rejected
- [ ] [ ] Approved vendor shows menu
- [ ] [ ] Vendor info card displays logo, name, category
- [ ] [ ] Menu buttons navigate correctly
- [ ] [ ] Logout works
- [ ] [ ] Status badge shows current state

### Upload Media Screen
- [ ] [ ] Logo section displays
- [ ] [ ] Logo card clickable
- [ ] [ ] Image picker opens for logo
- [ ] [ ] Selected logo shows in card
- [ ] [ ] Banner section displays
- [ ] [ ] Banner image picker works
- [ ] [ ] Upload button enabled when images selected
- [ ] [ ] Upload button disabled with no images
- [ ] [ ] Firebase Storage upload works
- [ ] [ ] Images appear in Firebase Storage
- [ ] [ ] Firestore updated with image URLs
- [ ] [ ] Success message shows
- [ ] [ ] Navigates back to dashboard

### Create Coupon Screen - Create Tab
- [ ] [ ] Title field accepts input
- [ ] [ ] Description field multi-line input
- [ ] [ ] Discount field numeric input only
- [ ] [ ] Code field accepts input
- [ ] [ ] Date picker opens on calendar click
- [ ] [ ] Date selection works
- [ ] [ ] Create button disabled until all filled
- [ ] [ ] Create button validates input
- [ ] [ ] Coupon saved to Firestore
- [ ] [ ] Status saved as "pending"
- [ ] [ ] Success message shows
- [ ] [ ] Form clears after creation
- [ ] [ ] Date resets to 30 days ahead

### Create Coupon Screen - My Coupons Tab
- [ ] [ ] Lists all vendor's coupons
- [ ] [ ] Status badges show colors
- [ ] [ ] Coupon details display
- [ ] [ ] Code shows correctly
- [ ] [ ] Discount displays with %
- [ ] [ ] Expiry date formatted correctly
- [ ] [ ] Admin notes show if present
- [ ] [ ] Approved coupons show "View QR Code"
- [ ] [ ] QR code dialog opens
- [ ] [ ] Tab refreshes after new coupon
- [ ] [ ] Empty state shows if no coupons

### Vendor Analytics Screen
- [ ] [ ] All stat cards display
- [ ] [ ] Total coupons count correct
- [ ] [ ] Active count correct (approved only)
- [ ] [ ] Pending count correct
- [ ] [ ] Rejected count correct
- [ ] [ ] Redemption counts correct
- [ ] [ ] Coupon details list shows all coupons
- [ ] [ ] Per-coupon breakdown accurate
- [ ] [ ] Scan/redemption numbers match
- [ ] [ ] No data errors
- [ ] [ ] Page scrolls smoothly

---

## Phase 6: User Redemption Flow Testing

### Setup Test Coupon
- [ ] [ ] Create coupon as vendor
- [ ] [ ] Approve coupon as admin
- [ ] [ ] Verify QR code appears
- [ ] [ ] QR code is valid/scannable

### Scan & Redemption Timer
- [ ] [ ] QR code scans successfully
- [ ] [ ] Redemption screen navigates
- [ ] [ ] Timer displays correctly
- [ ] [ ] Timer countdown works (1 sec intervals)
- [ ] [ ] Coupon details display
- [ ] [ ] "3-minute window" message shows
- [ ] [ ] Waiting message displays
- [ ] [ ] No back navigation during active

### Timer Expiry Test
- [ ] [ ] Let timer count down to 0
- [ ] [ ] "Time Expired" screen shows
- [ ] [ ] "Expired" icon displays
- [ ] [ ] Return button works
- [ ] [ ] Navigates to home
- [ ] [ ] Coupon returned to available
- [ ] [ ] Redemption marked "expired" in Firestore

### Successful Redemption Test
- [ ] [ ] Vendor confirms redemption
- [ ] [ ] Success screen shows
- [ ] [ ] Success icon displays
- [ ] [ ] Auto-navigates after 2 seconds
- [ ] [ ] Redemption marked "redeemed"
- [ ] [ ] Coupon removed from user's list
- [ ] [ ] Firestore updated correctly

---

## Phase 7: Firebase Integration Verification

### Firestore Data Verification
- [ ] [ ] Vendor approval updates status field
- [ ] [ ] Coupon approval updates status field
- [ ] [ ] Timestamps saved correctly
- [ ] [ ] Admin notes saved correctly
- [ ] [ ] Redemptions array created
- [ ] [ ] Redemption objects have all fields
- [ ] [ ] Image URLs saved correctly
- [ ] [ ] No orphaned documents

### Firebase Storage Verification
- [ ] [ ] Logo images upload successfully
- [ ] [ ] Banner images upload successfully
- [ ] [ ] Images accessible by URL
- [ ] [ ] Images are right size (optimized)
- [ ] [ ] QR codes save if implemented
- [ ] [ ] No large files taking space

### Authentication Verification
- [ ] [ ] Admin Firebase Auth works
- [ ] [ ] Admin UID matches Firestore doc
- [ ] [ ] Vendor email+phone verification works
- [ ] [ ] No auth errors in console
- [ ] [ ] Logout clears session
- [ ] [ ] Refresh works without re-login

---

## Phase 8: Performance & UX Testing

### Loading States
- [ ] [ ] Loading spinners show during API calls
- [ ] [ ] No freezing during Firestore operations
- [ ] [ ] Image loading shows placeholder
- [ ] [ ] Buttons disabled during operation
- [ ] [ ] No double-click issues

### Error Handling
- [ ] [ ] Network errors show messages
- [ ] [ ] Invalid data shows validation errors
- [ ] [ ] Firebase errors show user-friendly messages
- [ ] [ ] No crashes on errors
- [ ] [ ] No console errors/warnings

### UI/UX Quality
- [ ] [ ] All screens look good
- [ ] [ ] Colors are consistent
- [ ] [ ] Text is readable
- [ ] [ ] Buttons are clickable
- [ ] [ ] Forms are intuitive
- [ ] [ ] Spacing is appropriate
- [ ] [ ] No text overflow
- [ ] [ ] Images load correctly
- [ ] [ ] Scrolling works smoothly

### Navigation Testing
- [ ] [ ] Back button works everywhere
- [ ] [ ] Pop navigation safe
- [ ] [ ] No navigation loops
- [ ] [ ] Routes work from different paths
- [ ] [ ] Deep linking works if needed

---

## Phase 9: Integration with Existing App

### Compatibility
- [ ] [ ] New code doesn't break existing screens
- [ ] [ ] User screen still works (home, scan, etc.)
- [ ] [ ] No package conflicts
- [ ] [ ] Existing services not affected
- [ ] [ ] Models updated without breaking

### Data Consistency
- [ ] [ ] Existing users unaffected
- [ ] [ ] Existing coupons still work
- [ ] [ ] Migration strategy planned (if needed)
- [ ] [ ] Data models backward compatible

---

## Phase 10: Documentation & Deployment

### Documentation
- [ ] [ ] README updated with new features
- [ ] [ ] Admin user creation guide provided
- [ ] [ ] Setup instructions clear
- [ ] [ ] Firebase rules documented
- [ ] [ ] API usage documented
- [ ] [ ] Common issues documented

### Deployment Preparation
- [ ] [ ] Code reviewed for quality
- [ ] [ ] No console errors/warnings
- [ ] [ ] Tests passed all phases
- [ ] [ ] Performance acceptable
- [ ] [ ] Data backup configured
- [ ] [ ] Rollback plan ready

### Final Testing (Pre-Launch)
- [ ] [ ] Full end-to-end vendor flow
- [ ] [ ] Full end-to-end admin flow
- [ ] [ ] Full end-to-end user flow
- [ ] [ ] Stress test with multiple users
- [ ] [ ] Test on real devices
- [ ] [ ] Test on different Android/iOS versions
- [ ] [ ] Network conditions tested (slow, offline)
- [ ] [ ] Battery usage acceptable
- [ ] [ ] No memory leaks

---

## Test Data Creation Script

```dart
// Run this once to create test data
Future<void> createTestData() async {
  // Create test vendor
  await VendorService.registerVendor(
    vendorId: 'vendor_test_001',
    name: 'Test Store',
    email: 'vendor@test.com',
    phoneNumber: '+91 9876543210',
    category: 'Food',
    description: 'Test Store Description',
    location: 'Test Location',
    address: 'Test Address',
  );
  
  // Create test coupon
  await CouponService.createCoupon(
    vendorId: 'vendor_test_001',
    merchantId: 'vendor_test_001',
    title: 'Test Coupon',
    description: 'Test Description',
    discount: 20,
    code: 'TEST20',
    expiryDate: DateTime.now().add(Duration(days: 30)),
  );
  
  print('Test data created!');
}
```

---

## Rollback Procedure (If Issues)

1. [ ] Revert code changes
2. [ ] Clear Firestore test data
3. [ ] Clear Firebase Storage uploads
4. [ ] Remove admin test accounts
5. [ ] Redeploy previous version
6. [ ] Verify app works

---

## Success Criteria

✅ All admin functions working
✅ All vendor functions working
✅ All user redemption functions working
✅ 3-minute timer accurate
✅ Firestore data consistent
✅ No console errors
✅ Performance acceptable
✅ Data persists correctly
✅ Navigation smooth
✅ Ready for production

---

## Sign-Off

- [ ] Developer: Tested and verified
- [ ] QA: All test cases passed
- [ ] Product Owner: Feature approved
- [ ] Ready for deployment

**Date**: ___________
**Version**: 1.0.0

