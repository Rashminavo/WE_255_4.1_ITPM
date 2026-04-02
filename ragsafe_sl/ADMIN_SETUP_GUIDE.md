# Firebase Admin Account Setup Guide

## Overview
The app now uses Firebase Authentication with Firestore-based role management for admin authentication.

## Admin Login Credentials

### Primary Admin Account
- **Email:** `admin@ragsafe.com`
- **Password:** `Admin123`
- **Role:** `admin`

### Backup Admin Account
- **Email:** `admin@admin.com`
- **Password:** (Set in Firebase Console)
- **Role:** `admin`

---

## Setup Instructions

### Step 1: Create Admin User in Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **RagSafe SL**
3. Navigate to **Authentication** → **Users** tab
4. Click **"Add user"** button
5. Enter the following:
   - **Email:** `admin@ragsafe.com`
   - **Password:** `Admin123`
6. Click **"Add user"**

### Step 2: Create Admin Document in Firestore

1. In Firebase Console, navigate to **Firestore Database**
2. Go to the **`users`** collection (create it if it doesn't exist)
3. Click **"Add document"**
4. Set the **Document ID** to the admin user's UID (copy from Authentication tab)
5. Add the following fields:

| Field Name | Type | Value |
|------------|------|-------|
| `email` | string | `admin@ragsafe.com` |
| `role` | string | `admin` |
| `displayName` | string | `Admin` |
| `createdAt` | timestamp | (leave as server timestamp) |

**Alternative:** You can also run this in Firestore console:

```javascript
// In Firestore console, paste this with the actual UID from step 1
{
  "email": "admin@ragsafe.com",
  "role": "admin",
  "displayName": "Admin",
  "createdAt": new Date()
}
```

### Step 3: Verify Setup

1. Run the app
2. On login screen, enter:
   - **Email:** `admin@ragsafe.com`
   - **Password:** `Admin123`
3. Click "Sign In"
4. ✅ You should be redirected to the **Admin Dashboard**

---

## How Role-Based Routing Works

### Login Flow
```
User enters email/password
    ↓
Firebase Authentication validates credentials
    ↓
App fetches user role from Firestore 'users' collection
    ↓
If role == "admin" → Navigate to AdminDashboard
If role == "student" or "user" → Navigate to MainNavigation (Dashboard)
```

### Code Implementation

**File:** `lib/screens/login_screen.dart` (lines 62-76)
```dart
// Fetch Role
String role = await _authService.getUserRole(user.uid);

// Route based on role
if (role == 'admin' || 
    email.toLowerCase() == 'admin@admin.com' || 
    email.toLowerCase() == 'admin@ragsafe.com') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const AdminDashboard()),
  );
} else {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainNavigation()),
  );
}
```

**File:** `lib/services/auth_service.dart` (lines 77-87)
```dart
// Get user role from Firestore
Future<String> getUserRole(String uid) async {
  try {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return (doc.data() as Map<String, dynamic>)['role'] ?? 'student';
    }
  } catch (e) {
    debugPrint('Error getting user role: $e');
  }
  return 'student'; // Default fallback
}
```

---

## Adding More Admin Users

To add additional admin users:

1. **Create user in Firebase Authentication:**
   - Go to Authentication → Users → Add user
   - Enter their email and temporary password

2. **Get the user's UID:**
   - Click on the newly created user
   - Copy the "User UID"

3. **Add admin role in Firestore:**
   - Go to Firestore Database → users collection
   - Add document with the copied UID
   - Set these fields:
     ```json
     {
       "email": "newadmin@example.com",
       "role": "admin",
       "displayName": "Admin Name"
     }
     ```

4. **Test the login:**
   - Use the new credentials to verify admin access

---

## Troubleshooting

### Issue: Admin still goes to regular dashboard
**Solution:** Check Firestore document:
1. Verify the `role` field is exactly `"admin"` (case-sensitive)
2. Ensure the document UID matches the auth user UID
3. Check that the email field matches

### Issue: Cannot find users collection
**Solution:** The collection is created automatically when:
- First user registers through the app, OR
- You manually add the first document

To create manually:
1. Go to Firestore Database
2. Click "Start collection"
3. Collection ID: `users`
4. Document ID: (paste admin's UID)
5. Add the required fields

### Issue: Login fails with invalid credentials
**Solution:** 
1. Verify email is exactly `admin@ragsafe.com` (case-insensitive)
2. Verify password is exactly `Admin123` (case-sensitive)
3. Check Firebase Console → Authentication to confirm user exists

---

## Security Notes

⚠️ **Important Security Considerations:**

1. **Change default password** after initial setup
2. **Use Firebase Custom Claims** for production apps (more secure than Firestore roles)
3. **Implement admin verification** before allowing sensitive operations
4. **Enable Firebase App Check** to prevent unauthorized API access
5. **Set up Firestore Security Rules** to protect admin data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

---

## Testing Checklist

- [ ] Admin user created in Firebase Authentication
- [ ] Admin document added to Firestore with correct role
- [ ] Login with `admin@ragsafe.com` / `Admin123` works
- [ ] Admin is redirected to Admin Dashboard
- [ ] Regular users are redirected to Main Navigation
- [ ] Logout and re-login works correctly
- [ ] Dark mode works properly in Admin Dashboard

---

## Files Modified

1. **`lib/services/auth_service.dart`** - Updated signIn method to support both admin emails
2. **`lib/screens/login_screen.dart`** - Updated role-based routing logic
3. **`lib/main.dart`** - Enhanced dark theme configuration (previous fix)
4. **`lib/screens/admin_dashboard.dart`** - Added dark mode support (previous fix)

---

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review Flutter debug console output
3. Verify Firestore security rules
4. Ensure all dependencies are up to date
