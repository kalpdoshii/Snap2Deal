# Admin & Vendor Panel Implementation Guide

## Overview
This document describes the complete admin and vendor panel system implemented for Snap2Deal, including vendor registration, approval workflow, coupon management, and redemption system.

## System Architecture

### User Roles
1. **Regular User** - Can browse coupons, scan QR codes, and redeem coupons
2. **Vendor** - Can upload media, create coupons, and manage their store
3. **Admin** - Can approve vendors, approve coupons, and view analytics

### Database Structure

#### Collections

**vendors/**
```
├── vendorId
│   ├── id: string
│   ├── name: string
│   ├── email: string
│   ├── phoneNumber: string
│   ├── category: string
│   ├── description: string
│   ├── location: string
│   ├── address: string
│   ├── status: string (pending, approved, rejected)
│   ├── isApproved: boolean
│   ├── logo: string (URL)
│   ├── banner: string (URL)
│   ├── rating: number
│   ├── reviews: number
│   ├── timing: string
│   ├── minOrder: number
│   ├── createdAt: timestamp
│   ├── approvedAt: timestamp
│   ├── adminNotes: string
│   ├── totalCoupons: number
│   └── redeemedCoupons: number
```

**coupons/**
```
├── couponId
│   ├── id: string
│   ├── vendorId: string
│   ├── merchantId: string
│   ├── title: string
│   ├── description: string
│   ├── discount: number
│   ├── code: string
│   ├── expiryDate: timestamp
│   ├── status: string (pending, approved, rejected)
│   ├── used: boolean
│   ├── qrCode: string (URL or data)
│   ├── createdAt: timestamp
│   ├── approvedAt: timestamp
│   ├── adminNotes: string
│   └── redemptions: array
│       ├── id: string
│       ├── userId: string
│       ├── scannedAt: timestamp
│       ├── redeemedAt: timestamp
│       ├── expiresAt: timestamp (3 minutes from scan)
│       └── status: string (pending, redeemed, expired)
```

**admins/**
```
├── adminId
│   ├── id: string
│   ├── name: string
│   ├── email: string
│   ├── phoneNumber: string
│   ├── role: string (admin, super_admin)
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   └── profileImage: string (URL)
```

## Workflow

### Vendor Registration & Approval
1. Vendor registers with email, phone, and basic info
2. Document created with status: "pending"
3. Admin reviews vendor details
4. Admin approves/rejects vendor
5. Once approved, vendor can login and access dashboard

### Coupon Creation & Approval
1. Vendor creates coupon (pending approval)
2. Coupon saved with status: "pending"
3. Admin reviews and approves/rejects
4. Once approved, vendor gets QR code
5. Coupons become available for users to scan

### Coupon Redemption Flow
1. User scans QR code from vendor
2. System creates redemption record with 3-minute timer
3. Timer shows remaining time to vendor
4. Vendor confirms redemption within 3 minutes
5. If timer expires: coupon returns to user, redemption marked "expired"
6. If redeemed: coupon removed from user's list, marked "redeemed"

## Admin Screens

### Admin Login (`admin_login_screen.dart`)
- Email and password authentication
- Firebase Auth integration
- Validates user is in admins collection

### Admin Dashboard (`admin_dashboard_screen.dart`)
**Shows statistics:**
- Total vendors
- Pending vendor approvals
- Total users
- Total coupons
- Pending coupon approvals
- Approved coupons

**Quick actions:**
- Approve Vendors
- Approve Coupons
- View Users

### Vendor Approval (`vendor_approval_screen.dart`)
- Lists all pending vendors
- Shows vendor details (name, email, phone, category, location)
- Actions: Approve with optional notes, Reject with required reason

### Coupon Approval (`coupon_approval_screen.dart`)
- Lists all pending coupons
- Shows coupon details and vendor name
- Actions: Approve, Reject with reason

### Users List (`users_list_screen.dart`)
- Shows all registered users
- User details: name, email, phone, join date, subscription status

## Vendor Screens

### Vendor Login (`vendor_login_screen.dart`)
- Step 1: Enter email
- Step 2: Enter phone number
- Verifies vendor email + phone combination
- Local storage of vendorId, vendorName, vendorEmail

### Vendor Dashboard (`vendor_dashboard_screen.dart`)
- Shows vendor info (logo, name, category, status)
- Menu options:
  - Upload Logo & Banner
  - Create Coupon
  - Analytics Dashboard
- Handles pending/approved status display
- Shows admin notes if rejected

### Upload Media (`upload_media_screen.dart`)
- Upload vendor logo (square format)
- Upload banner (landscape format)
- Firebase Storage integration
- Image preview and selection from gallery

### Create Coupon (`create_coupon_screen.dart`)
**Two tabs:**
1. **Create New**
   - Fields: Title, Description, Discount %, Code, Expiry Date
   - Saves coupon with status: "pending"
   - Validation and error handling

2. **My Coupons**
   - Lists all vendor's coupons (all statuses)
   - Shows: Title, Status badge, Code, Discount, Expiry, Admin notes
   - For approved coupons: View QR code button

### Vendor Analytics (`vendor_analytics_screen.dart`)
**Statistics:**
- Total coupons created
- Active (approved) coupons
- Pending approval
- Rejected coupons
- Total scans/redemptions
- Completed redemptions

**Detailed Coupon List:**
- Per-coupon breakdown
- Total scans, Completed, Pending redemptions
- Visual progress indicators

## User Screens

### Coupon Redemption Timer (`coupon_redemption_timer_screen.dart`)
- 3-minute countdown timer
- Shows coupon details (title, code, discount)
- Message explaining 3-minute window
- Status handling:
  - **Active**: Timer counting down
  - **Expired**: Shows "Time Expired" message
  - **Redeemed**: Shows success message

## Services

### AdminService (`admin_service.dart`)
- `registerAdmin()` - Create new admin account
- `loginAdmin()` - Firebase Auth login
- `getCurrentAdmin()` - Get logged-in admin
- `getDashboardStats()` - Fetch all statistics
- `getAllUsers()` - List all users
- `getAllVendorsWithDetails()` - List vendors
- `getAllPendingCoupons()` - List pending coupons
- `isUserAdmin()` / `isUserVendor()` - Role check

### VendorService (`vendor_service.dart`)
- `registerVendor()` - Create pending vendor
- `getPendingVendors()` - Admin view
- `getApprovedVendors()` - Public vendors
- `getVendorById()` - Get vendor details
- `approveVendor()` / `rejectVendor()` - Admin actions
- `updateVendorImages()` - Upload logo/banner URLs
- `getAllVendors()` - Full vendor list
- `getVendorStats()` - Vendor statistics

### CouponService (`coupon_service.dart`)
- `createCoupon()` - Vendor creates coupon
- `getPendingCoupons()` - Admin view
- `getVendorCoupons()` - Vendor's coupons
- `approveCoupon()` / `rejectCoupon()` - Admin actions
- `updateCouponQrCode()` - Add QR after approval
- `scanCoupon()` - Create redemption with 3-min timer
- `confirmRedemption()` - Vendor confirms within window
- `expireOldRedemptions()` - Cleanup expired records

## Firebase Setup Required

### Authentication
- Enable Email/Password auth in Firebase Console
- Create admin accounts with email/password

### Firestore Collections
Create these collections with appropriate security rules:

```javascript
// Allow vendors to read/write their own document
match /vendors/{document=**} {
  allow read, write: if request.auth.uid == resource.data.vendorId
                        || get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null;
}

// Allow admins to read all vendors
match /admins/{document=**} {
  allow read, write: if request.auth.uid == document;
}

// Allow users and vendors to read approved coupons
match /coupons/{document=**} {
  allow read: if resource.data.status == 'approved'
                || request.auth.uid == resource.data.vendorId;
  allow write: if request.auth.uid == resource.data.vendorId
                  || get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role != null;
}
```

### Firebase Storage
Create folders:
- `vendor_logos/` - For vendor logos
- `vendor_banners/` - For vendor banners
- `qr_codes/` - For generated QR codes

## Navigation Flow

```
App Start
├── Splash Screen
└── Auth Check
    ├── User → Home Screen (existing flow)
    ├── Vendor (approved) → Vendor Dashboard
    ├── Vendor (pending) → Vendor Dashboard (pending view)
    ├── Admin → Admin Dashboard
    └── No Auth → Login Screen
```

## Features Implemented

✅ Vendor Registration & Approval
✅ Admin & Vendor Authentication
✅ Logo & Banner Upload
✅ Coupon Creation & Approval
✅ QR Code Generation & Display
✅ Coupon Scanning
✅ 3-Minute Redemption Timer
✅ Vendor Analytics Dashboard
✅ Admin Dashboard with Statistics
✅ User Management (Admin view)
✅ Approval Workflow with Notes
✅ Firebase Integration

## Dependencies Added

```yaml
uuid: ^4.0.0
qr_flutter: ^4.1.0
image_picker: ^1.0.4
firebase_storage: ^11.2.0
```

## Next Steps

1. Generate QR codes for approved coupons (using qr_flutter package)
2. Set up Firestore security rules
3. Create admin accounts in Firebase Console
4. Test complete workflow
5. Add more analytics metrics as needed
