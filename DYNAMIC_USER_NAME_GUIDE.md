# 👤 Dynamic User Name in Dashboard - Setup Guide

## ✅ What Was Fixed

### Problem:
The dashboard was showing a static name "Tharani Bandara" instead of the logged-in user's actual name from registration/login.

### Root Cause:
1. **Field name mismatch**: Registration saved name as `'name'` but dashboard looked for `'fullName'`
2. **Profile not syncing**: Profile updates weren't being saved to Firestore
3. **No auto-refresh**: Dashboard didn't reload data after profile edits

---

## 🔧 Changes Made

### 1. **UserProvider (`lib/providers/user_provider.dart`)**

#### ✅ Updated `loadUserData()` method:
- Now supports both `'fullName'` and `'name'` fields for backward compatibility
- Added debug logging to track data loading
- Falls back to 'User' if no name is found

```dart
_fullName = data['fullName'] ?? data['name'] ?? 'User';
```

#### ✅ Updated `updateProfile()` method:
- Now **automatically saves to Firestore** when profile is updated
- Saves both `fullName` and `name` fields for compatibility
- Includes `updatedAt` timestamp
- Added error handling and debug logging

```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
  'fullName': fullName,
  'name': fullName,
  'email': email,
  'phone': phone,
  'studentId': studentId,
  'faculty': faculty,
  'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
```

### 2. **AuthService (`lib/services/auth_service.dart`)**

#### ✅ Updated `signUp()` method:
- Now saves **both** `fullName` and `name` fields during registration
- Ensures consistency across the app

```dart
await _firestore.collection('users').doc(user.uid).set({
  'uid': user.uid,
  'email': email,
  'fullName': name,  // New field for consistency
  'name': name,       // Keep for backward compatibility
  'studentId': studentId,
  'role': 'student',
  'safetyScore': 85,
  'createdAt': FieldValue.serverTimestamp(),
});
```

### 3. **DashboardScreen (`lib/Screens/dashboard_screen.dart`)**

#### ✅ Added `didChangeDependencies()` method:
- Automatically reloads user data when screen becomes visible
- Ensures name updates after returning from profile screen
- Keeps dashboard in sync with latest user data

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _loadUserData();
}
```

---

## 📋 How It Works Now

### Registration Flow:
1. User registers with name, email, password
2. Name is saved to Firestore as **both** `fullName` and `name`
3. User logs in successfully

### Login Flow:
1. User logs in with email/password
2. Dashboard loads and calls `loadUserData()`
3. Fetches user document from Firestore using UID
4. Extracts `fullName` (or `name` for older users)
5. Displays the name in the dashboard header

### Profile Update Flow:
1. User edits profile and clicks "Save"
2. `updateProfile()` is called
3. Updates local state in UserProvider
4. **Automatically saves to Firestore**
5. User returns to dashboard
6. `didChangeDependencies()` triggers reload
7. Dashboard shows updated name immediately

---

## 🗄️ Firestore Document Structure

Each user document in the `users` collection now looks like this:

```javascript
users/{userId}
{
  uid: "abc123xyz",
  email: "user@example.com",
  fullName: "John Doe",        // ← New standard field
  name: "John Doe",            // ← Kept for backward compatibility
  studentId: "IT23318748",
  phone: "0771234567",
  faculty: "Faculty of Computing",
  role: "student",
  safetyScore: 85,
  anonymousMode: false,
  createdAt: Timestamp,
  updatedAt: Timestamp         // ← Updated on profile save
}
```

---

## 🧪 Testing Instructions

### Test 1: New User Registration
1. Register a new account with name "Test User"
2. Login with the new account
3. **Expected**: Dashboard shows "Test User" in the header

### Test 2: Existing User Login
1. Login with an existing account
2. **Expected**: Dashboard shows the name from Firestore

### Test 3: Profile Update
1. Go to Profile screen
2. Change the name to "New Name"
3. Click "Save"
4. Navigate back to Dashboard
5. **Expected**: Dashboard immediately shows "New Name"

### Test 4: Debug Console
Check the console for these debug messages:
```
Loaded user data: John Doe, user@example.com
Profile saved to Firestore: New Name
```

---

## 🐛 Troubleshooting

### Issue: Dashboard still shows old name

**Solutions:**
1. **Check Firestore**: Verify the user document has `fullName` or `name` field
2. **Check console**: Look for "Loaded user data:" debug message
3. **Hot reload**: Press `r` in terminal to reload the app
4. **Clear cache**: Logout and login again

### Issue: Profile changes not saving

**Solutions:**
1. **Check Firestore rules**: Ensure user has write permission to their document
2. **Check console**: Look for "Error saving profile" message
3. **Verify user is logged in**: `FirebaseAuth.instance.currentUser` should not be null

### Issue: Name shows as "User"

**Causes:**
- User document doesn't exist in Firestore
- Document exists but has no `fullName` or `name` field
- User is not logged in

**Solution:**
1. Check Firestore `users` collection
2. Manually add the `fullName` field if missing
3. Or update profile to trigger auto-save

---

## 📝 Firestore Security Rules

Make sure your rules allow users to read/write their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow read/write if userId matches authenticated user
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
  }
}
```

---

## ✅ Verification Checklist

After making these changes, verify:

- [ ] New users see their name on dashboard after registration
- [ ] Existing users see their name from Firestore
- [ ] Profile updates sync to dashboard automatically
- [ ] Console shows debug messages confirming data load/save
- [ ] Firestore documents have both `fullName` and `name` fields
- [ ] No errors in console related to user data

---

## 🎯 Summary

**Before:**
- ❌ Static hardcoded name "Tharani Bandara"
- ❌ Field name mismatch between registration and dashboard
- ❌ Profile updates not saved to Firestore
- ❌ No auto-refresh after profile edits

**After:**
- ✅ Dynamic name from Firestore
- ✅ Compatible with both `fullName` and `name` fields
- ✅ Profile updates automatically saved to Firestore
- ✅ Dashboard auto-refreshes when returning from profile
- ✅ Debug logging for easy troubleshooting
- ✅ Backward compatible with existing users

---

**Last Updated:** 2026-04-22
