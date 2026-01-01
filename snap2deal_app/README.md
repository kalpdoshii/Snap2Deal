# Snap2Deal – Offline Deals & Membership Platform

Snap2Deal is a mobile application that helps users discover and redeem **exclusive offline coupons** from nearby restaurants, salons, and local shops through a **membership-based model**.

The app focuses on **offline businesses**, enabling QR-based coupon redemption with controlled access via subscriptions.

---

## 🚀 Features

### 👤 User
- Mobile number login with OTP verification
- Browse approved vendors (restaurants, salons, shops)
- View available coupons per vendor
- Redeem coupons via QR scan
- Subscription-based access (freemium model)
- Profile management (name, email, phone)

### 🔒 Subscription Logic
- Non-members can **see coupons (locked)**
- Members can **redeem coupons**
- Subscription status validated at backend
- Coupons disappear after use

### 🏪 Vendor & Coupon
- Vendors managed via backend
- Coupons linked to vendors
- Coupon usage tracked per user

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- Flutter
- Dart
- Mobile Scanner (QR scanning)
- Shared Preferences

### Backend
- Node.js
- Express.js
- MongoDB (Mongoose)
- REST APIs
- JWT-like header-based authentication

### Database
- MongoDB
  - Users
  - Merchants
  - Coupons
  - UserCoupons (tracking usage)

---

## 🧩 App Flow

1. User logs in via OTP
2. User browses vendors
3. User opens vendor → sees coupons
4. If not subscribed → coupons are locked
5. If subscribed → user scans QR to redeem
6. Coupon marked as USED in backend

---

## 🏗️ Architecture Overview

Flutter App  
⬇  
Node.js / Express REST APIs  
⬇  
MongoDB Database  

Key layers:
- Auth Service
- Vendor Service
- Coupon Service
- Subscription Logic
- Scan & Redemption Logic

---

## ▶️ How to Run the Project

### Backend
```bash
cd backend
npm install
npm start
