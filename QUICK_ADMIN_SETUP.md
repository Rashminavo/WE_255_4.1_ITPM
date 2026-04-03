# 🚀 Quick Start: Admin Login Setup

## 3 Simple Steps to Setup Admin Account

### Step 1️⃣: Create Firebase User
```
Firebase Console → Authentication → Add User
Email: admin@ragsafe.com
Password: Admin123
```

### Step 2️⃣: Copy User UID
```
Click on the user → Copy "User UID" (looks like: abc123XYZ...)
```

### Step 3️⃣: Add Firestore Document
```
Firestore Database → users collection → Add Document
Document ID: [Paste the UID from Step 2]

Fields:
- email (string): admin@ragsafe.com
- role (string): admin  
- displayName (string): Admin
```

---

## ✅ Test Login

**Login Screen:**
- Email: `admin@ragsafe.com`
- Password: `Admin123`

**Expected Result:** Redirects to **Admin Dashboard** 🎉

---

## 🔍 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Goes to regular dashboard | Check Firestore `role` field = `"admin"` |
| Invalid credentials error | Verify password is exactly `Admin123` |
| Can't find users collection | It's created automatically when you add first document |

---

## 📱 How It Works

```
Login → Firebase Auth → Get Role from Firestore → Route to Dashboard
                                                ↓
                                    admin = AdminDashboard
                                    student/user = MainNavigation
```

---

## 🎯 What Changed?

✅ Updated `auth_service.dart` - Supports `admin@ragsafe.com`  
✅ Updated `login_screen.dart` - Checks role from Firestore  
✅ Role-based routing - Automatic navigation based on user type  

---

## 📞 Need Help?

See full details in: **`ADMIN_SETUP_GUIDE.md`**
