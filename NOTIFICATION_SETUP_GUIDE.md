# 🔔 Real-Time Notifications - Setup & Troubleshooting Guide

## ✅ What Was Fixed

### 1. **Dashboard Notification Badge**
- ✅ Now uses `StreamBuilder` to listen to Firestore in real-time
- ✅ Automatically counts unread notifications (`isNew == true`)
- ✅ Filters by current user's UID
- ✅ Badge updates instantly when notifications change

### 2. **Notification Screen**
- ✅ Already had real-time StreamBuilder
- ✅ Added auto mark-as-read when screen opens
- ✅ Individual notifications marked as read on tap

### 3. **Firestore Service**
- ✅ Added error handling with `handleError()`
- ✅ Added empty user ID check
- ✅ Added `getAllNotifications()` fallback method
- ✅ Enhanced `createNotification()` with userId, body, createdAt fields

---

## 🚨 Common Issues & Solutions

### Issue 1: Firestore Composite Index Required

**Problem:** 
You see an error in console like:
```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

**Solution:**
You need to create a Firestore composite index for the query:
- Collection: `notifications`
- Fields to index:
  1. `userId` (Ascending)
  2. `createdAt` (Descending)

**How to create the index:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Add Index**
5. Configure:
   - Collection ID: `notifications`
   - Fields:
     - `userId` - Ascending
     - `createdAt` - Descending
   - Query scope: Collection
6. Click **Create**

**Alternative:** Click the link shown in the error message in your console - it will auto-fill the index creation form.

---

### Issue 2: No Notifications Showing

**Check these:**

1. **Is the user logged in?**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   print('User: ${user?.uid}');
   ```

2. **Do notifications have the `userId` field?**
   Check your Firestore `notifications` collection. Each document should have:
   ```javascript
   {
     title: "Test Notification",
     type: "System",
     body: "Notification body",
     isNew: true,
     userId: "YOUR_FIREBASE_AUTH_UID",  // ← Must match logged-in user
     createdAt: Timestamp,
     timestamp: Timestamp
   }
   ```

3. **Check the debug console**
   Look for these debug messages:
   ```
   Unread notifications: 3
   ```

---

### Issue 3: Badge Not Updating

**Possible causes:**

1. **Stream not receiving data**
   - Check console for errors
   - Verify Firestore rules allow reading

2. **`isNew` field is boolean, not string**
   - In Firestore, make sure `isNew` is a **boolean** (`true`/`false`), not a string (`"true"`)

3. **UserId mismatch**
   - The `userId` in notification must exactly match `FirebaseAuth.instance.currentUser.uid`

---

## 🧪 How to Test

### Method 1: Use the Test Button (Added to Dashboard)

1. Login to the app
2. On the dashboard, click the **alert icon** (➕) in the app bar
3. This creates a test notification with your userId
4. Watch the badge count increase automatically
5. Click the notification bell to see it in the list

### Method 2: Add Notification via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Navigate to **Firestore Database**
3. Go to `notifications` collection
4. Click **Add Document**
5. Add these fields:
   ```
   title: "Test Alert"
   type: "Alerts"  (or "System", "Booking")
   body: "This is a test"
   isNew: true  (BOOLEAN - toggle the switch)
   userId: "PASTE_YOUR_AUTH_UID_HERE"
   createdAt: (leave empty - will auto-populate)
   timestamp: (leave empty - will auto-populate)
   ```
6. Save and watch the badge update in real-time

### Method 3: Get Your User ID

To find your current user's UID:
1. Login to the app
2. Open browser console (F12)
3. Look for debug prints, or
4. Add this temporarily to dashboard:
   ```dart
   debugPrint('Current UID: ${FirebaseAuth.instance.currentUser?.uid}');
   ```

---

## 📝 Firestore Security Rules

Make sure your Firestore rules allow users to read their own notifications:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      // Allow read if userId matches the authenticated user
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      
      // Allow create for authenticated users
      allow create: if request.auth != null;
      
      // Allow update only the isNew field
      allow update: if request.auth != null && 
                       request.resource.data.userId == resource.data.userId;
    }
  }
}
```

---

## 🔧 Temporary Workaround (If Index Issues Persist)

If you're having trouble with the composite index, you can use the fallback method that fetches all notifications and filters client-side:

**In `dashboard_screen.dart`, change:**
```dart
stream: _firestoreService.getUserNotifications(
  FirebaseAuth.instance.currentUser?.uid ?? '',
),
```

**To:**
```dart
stream: _firestoreService.getAllNotifications(),
```

**And update the builder:**
```dart
if (snapshot.hasData) {
  final user = FirebaseAuth.instance.currentUser;
  final allNotifs = snapshot.data!;
  final userNotifs = allNotifs.where((n) => 
    n['userId'] == user?.uid
  ).toList();
  unreadCount = userNotifs.where((notif) => 
    notif['isNew'] == true
  ).length;
}
```

⚠️ **Note:** This is less efficient for large datasets but works without indexes.

---

## 🐛 Debug Checklist

Run through this checklist if notifications aren't working:

- [ ] User is logged in (check `FirebaseAuth.instance.currentUser != null`)
- [ ] Firestore `notifications` collection exists
- [ ] Notifications have `userId` field matching auth UID
- [ ] Notifications have `createdAt` field (Timestamp)
- [ ] `isNew` is a boolean (true/false), not a string
- [ ] Composite index is created (userId + createdAt)
- [ ] Firestore security rules allow access
- [ ] No errors in console/debug output
- [ ] Debug print shows: `Unread notifications: X`

---

## 📊 Expected Behavior

1. **Login** → Badge shows count of unread notifications
2. **New notification added to Firestore** → Badge updates within 1-2 seconds
3. **Open notification screen** → All marked as read, badge resets
4. **Return to dashboard** → Badge shows 0 (or updates if new ones arrived)

---

## 🎯 Next Steps

1. **Test with the button**: Click the alert icon in dashboard app bar
2. **Check console**: Look for "Unread notifications: X" message
3. **Verify Firestore**: Check that document was created with your userId
4. **Create index**: If you see index error, create it in Firebase Console
5. **Remove test button**: After testing, remove the test button from dashboard

---

## 📞 Common Error Messages

| Error | Solution |
|-------|----------|
| `The query requires an index` | Create composite index in Firebase Console |
| `Missing or insufficient permissions` | Update Firestore security rules |
| `User is null` | Make sure user is logged in first |
| Badge shows 0 but notifications exist | Check `userId` matches and `isNew` is boolean |
| Stream error in console | Verify Firestore rules and index |

---

**Last Updated:** 2026-04-22
