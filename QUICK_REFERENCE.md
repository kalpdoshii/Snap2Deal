# Quick Reference Guide - Admin & Vendor System

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd snap2deal_app
flutter pub get
```

### 2. Set Firebase Rules
Copy Firestore and Storage rules from INTEGRATION_GUIDE.md

### 3. Create Admin Account
- Go to Firebase Console
- Create user with email/password
- Create matching document in admins collection

### 4. Run App
```bash
flutter run
```

---

## 📋 Key Features at a Glance

### Admin Features ✓
- Login with email/password
- View dashboard statistics
- Approve/reject vendors with notes
- Approve/reject coupons with notes
- View all users
- Logout

### Vendor Features ✓
- Login with email + phone
- Upload logo and banner
- Create coupons (auto-pending)
- View all created coupons
- See approval status and notes
- View QR codes for approved coupons
- Analytics dashboard
  - Coupon statistics
  - Redemption tracking
  - Performance metrics

### User Features ✓
- Scan QR codes
- 3-minute redemption timer
- Auto-return if timer expires
- Redeem coupons instantly

---

## 📱 Screen Navigation Map

```
ADMIN PATH:
AdminLoginScreen
  ↓ (valid login)
AdminDashboardScreen
  ├→ VendorApprovalScreen
  ├→ CouponApprovalScreen
  └→ UsersListScreen

VENDOR PATH:
VendorLoginScreen (email + phone)
  ↓ (approved vendor)
VendorDashboardScreen
  ├→ UploadMediaScreen (logo/banner)
  ├→ CreateCouponScreen
  │  ├→ Create Tab
  │  └→ My Coupons Tab
  └→ VendorAnalyticsScreen

USER PATH:
ScanScreen (QR code)
  ↓
CouponRedemptionTimerScreen
  ├→ Expired (return)
  └→ Redeemed (success)
```

---

## 🔑 Database Schema Quick Reference

### Collections

| Collection | Document Structure |
|---|---|
| `vendors` | vendorId → {name, email, phone, status, logo, banner, ...} |
| `coupons` | couponId → {vendorId, title, code, status, redemptions[], ...} |
| `admins` | adminId → {name, email, phone, role, isActive, ...} |
| `users` | userId → {name, email, phone, redeemedCoupons[], ...} |

### Key Fields

| Field | Purpose | Values |
|---|---|---|
| vendor.status | Approval stage | pending / approved / rejected |
| coupon.status | Approval stage | pending / approved / rejected |
| redemption.status | Redemption stage | pending / redeemed / expired |
| admin.role | Admin level | admin / super_admin |

---

## 🎯 Common Tasks

### How to: Approve a Vendor
1. Admin Dashboard → "Approve Vendors"
2. Review vendor details
3. Click "Approve" button
4. (Optional) Add approval notes
5. Done! Vendor can now login

### How to: Create and Approve Coupon
**Vendor Side:**
1. Vendor Dashboard → "Create Coupon"
2. Fill in details (title, code, discount, expiry)
3. Click "Create Coupon"
4. Status shows "pending"

**Admin Side:**
1. Admin Dashboard → "Approve Coupons"
2. Review coupon details
3. Click "Approve"
4. Coupon now available for users

### How to: Upload Media
1. Vendor Dashboard → "Upload Logo & Banner"
2. Select logo image (square)
3. Select banner image (landscape)
4. Click "Upload Media"
5. Images saved to Firebase Storage

### How to: View Analytics
1. Vendor Dashboard → "Analytics Dashboard"
2. See coupon statistics
3. View redemption breakdown
4. Track performance per coupon

### How to: Redeem Coupon (User)
1. Scan QR code from vendor
2. Timer starts (3 minutes)
3. Vendor confirms
4. Coupon marked as redeemed
5. Removed from available coupons

---

## 🔧 Services & Methods

### AdminService
```dart
AdminService.loginAdmin(email, password)        // → bool
AdminService.getCurrentAdmin()                   // → Admin?
AdminService.getDashboardStats()                 // → Map<String, int>
AdminService.getAllUsers()                       // → List<User>
AdminService.getAllVendorsWithDetails()          // → List<Vendor>
AdminService.getAllPendingCoupons()              // → List<Coupon>
AdminService.logoutAdmin()                       // → void
AdminService.isUserAdmin(uid)                    // → bool
```

### VendorService
```dart
VendorService.registerVendor(...)                // → bool
VendorService.getPendingVendors()                // → List<Vendor>
VendorService.getApprovedVendors()               // → List<Vendor>
VendorService.getVendorById(id)                  // → Vendor?
VendorService.approveVendor(id, notes)           // → bool
VendorService.rejectVendor(id, notes)            // → bool
VendorService.updateVendorImages(id, ...)        // → bool
VendorService.getAllVendors()                    // → List<Vendor>
VendorService.getVendorStats()                   // → Map<String, int>
```

### CouponService
```dart
CouponService.createCoupon(...)                  // → String? (couponId)
CouponService.getPendingCoupons()                // → List<Coupon>
CouponService.getVendorCoupons(vendorId)        // → List<Coupon>
CouponService.approveCoupon(id, qrUrl)          // → bool
CouponService.rejectCoupon(id, notes)           // → bool
CouponService.updateCouponQrCode(id, url)       // → bool
CouponService.scanCoupon(couponId, userId)      // → CouponRedemption?
CouponService.confirmRedemption(couponId, redemptionId) // → bool
CouponService.expireOldRedemptions(couponId)    // → void
```

---

## 🐛 Debugging Tips

### Check Admin Login Issue
```dart
// In Firebase Console, verify:
1. Admin user exists in Authentication
2. Admin document exists in Firestore
3. Document has required fields: name, email, phoneNumber, role, isActive
```

### Check Vendor Login Issue
```dart
// Verify vendor in Firestore:
1. Vendor status = "approved"
2. Email and phone match input
3. VendorId saved to SharedPreferences
```

### Check Coupon Not Showing
```dart
// Verify coupon in Firestore:
1. Coupon status = "approved"
2. Coupon createdAt is valid timestamp
3. expiryDate is in future
```

### Timer Not Working
```dart
// Check:
1. Timer started in initState()
2. setState() called in timer
3. Duration calculations correct
4. expiresAt = scanTime + 3 minutes
```

---

## 📊 Sample Data for Testing

### Test Admin Account
```json
{
  "uid": "admin123",
  "name": "Admin User",
  "email": "admin@snap2deal.com",
  "phoneNumber": "+91 98765 43210",
  "role": "super_admin",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "profileImage": null
}
```

### Test Vendor
```json
{
  "id": "vendor123",
  "name": "Test Store",
  "email": "vendor@snap2deal.com",
  "phoneNumber": "+91 98765 43211",
  "category": "Food",
  "status": "approved",
  "isApproved": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "approvedAt": "2024-01-02T00:00:00Z"
}
```

### Test Coupon
```json
{
  "id": "coupon123",
  "vendorId": "vendor123",
  "title": "20% OFF",
  "code": "SAVE20",
  "discount": 20,
  "status": "approved",
  "createdAt": "2024-01-03T00:00:00Z",
  "approvedAt": "2024-01-04T00:00:00Z",
  "expiryDate": "2024-12-31T23:59:59Z",
  "redemptions": []
}
```

---

## ⚠️ Important Notes

1. **3-Minute Timer**: Starts from scan time, not from redemption confirmation
2. **Vendor Login**: Uses email + phone, not Firebase Auth
3. **Admin Login**: Uses Firebase Auth with email/password
4. **QR Codes**: Generated/updated after admin approval
5. **Redemptions**: Tracked in array within coupon document
6. **Admin Notes**: Can be added during approval/rejection
7. **Status Fields**: Always "pending", "approved", or "rejected"
8. **Timestamps**: Use Firestore timestamps for consistency

---

## 📞 Contact for Support

For issues or questions:
1. Check ADMIN_VENDOR_IMPLEMENTATION.md for detailed docs
2. Review INTEGRATION_GUIDE.md for setup issues
3. Check debugging tips section above
4. Review Firebase console logs

---

## 📦 Deployment Checklist

Before going live:
- [ ] Firebase rules configured correctly
- [ ] Admin account created and tested
- [ ] All screens tested
- [ ] Timer logic verified
- [ ] QR code generation working
- [ ] Image upload functioning
- [ ] Analytics showing data
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Data backup configured

