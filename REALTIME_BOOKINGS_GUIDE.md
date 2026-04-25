# 📅 Real-Time Bookings Display - Setup Guide

## ✅ What Was Fixed

### Problem:
When users booked a counselor session, the booking was saved to Firestore but **did NOT show** in the "My Bookings" list. The list was reading from local `BookingStorage` instead of Firestore.

### Root Cause:
1. **Local storage only**: `_showBookingsList()` was reading from `BookingStorage.bookings` (in-memory list)
2. **No Firestore connection**: Bookings saved to Firestore weren't being retrieved
3. **No real-time updates**: List didn't update when new bookings were added
4. **No notifications**: Users weren't notified when booking was created

---

## 🔧 Changes Made

### 1. **CounselorScreen (`lib/Screens/counselor_screen.dart`)**

#### ✅ Replaced `_showBookingsList()` method:

**Before:**
```dart
// Reading from local storage only
ListView.builder(
  itemCount: BookingStorage.bookings.length,
  itemBuilder: (context, index) {
    final booking = BookingStorage.bookings[index];
    // Display booking...
  },
)
```

**After:**
```dart
// Real-time Firestore stream
StreamBuilder<QuerySnapshot>(
  stream: BookingService().getUserBookingsStream(userProvider.studentId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final bookings = snapshot.data!.docs;
      // Display bookings from Firestore...
    }
  },
)
```

**Features:**
- ✅ Real-time updates via Firestore stream
- ✅ Loading state with spinner
- ✅ Error state with message
- ✅ Empty state with helpful message
- ✅ Displays all booking details (counselor, date, time, status, reason)
- ✅ Color-coded status badges (Pending/Confirmed/Cancelled)

### 2. **BookingService (`lib/services/booking_service.dart`)**

#### ✅ Updated `createBooking()` method:

**Added automatic notification:**
```dart
// Send notification to user when booking is created
if (user != null) {
  await sendBookingNotification(
    userId: user.uid,
    title: 'Booking Confirmed',
    body: 'Your session with $counselorName on $date at $time has been booked successfully.',
    type: 'Booking',
  );
}
```

**Now when a booking is created:**
1. Booking is saved to Firestore `bookings` collection
2. Notification is automatically sent to user
3. Notification appears in real-time on dashboard
4. Booking appears immediately in "My Bookings" list

---

## 📋 How It Works Now

### Booking Flow:

1. **User books a session:**
   - Selects counselor, date, time, and reason
   - Clicks "Confirm Booking"
   
2. **Booking is saved:**
   - Saved to Firestore `bookings` collection
   - Includes: studentId, counselorName, date, time, reason, status, userId
   
3. **Notification is sent:**
   - Auto-created in Firestore `notifications` collection
   - Type: "Booking"
   - Marked as unread (`isNew: true`)
   
4. **Real-time updates:**
   - Dashboard notification badge updates instantly
   - "My Bookings" list shows new booking immediately
   - No refresh needed!

### Viewing Bookings:

1. Click "View My Bookings" button
2. StreamBuilder connects to Firestore
3. Fetches all bookings where `studentId` matches current user
4. Displays in scrollable list with:
   - Counselor name
   - Reason for session
   - Status badge (color-coded)
   - Date and time
   - Booking creation date

---

## 🗄️ Firestore Document Structure

### Booking Document:
```javascript
bookings/{bookingId}
{
  studentId: "IT23318748",
  studentName: "John Doe",
  counselorName: "Dr. Priya Mendis",
  date: "2026-04-25",
  time: "10:00 AM",
  reason: "Anxiety / Stress",
  status: "Pending",  // Pending, Confirmed, Approved, Cancelled
  userId: "firebase_auth_uid",
  createdAt: Timestamp
}
```

### Notification Document (auto-created):
```javascript
notifications/{notificationId}
{
  userId: "firebase_auth_uid",
  title: "Booking Confirmed",
  body: "Your session with Dr. Priya Mendis on 2026-04-25 at 10:00 AM has been booked successfully.",
  type: "Booking",
  isNew: true,
  createdAt: Timestamp
}
```

---

## 🧪 Testing Instructions

### Test 1: Create a Booking
1. Go to Counselor Support screen
2. Select a counselor
3. Choose date, time, and reason
4. Click "Confirm Booking"
5. **Expected**: 
   - Success dialog appears
   - Notification badge increases by 1
   - Click bell icon → see booking notification

### Test 2: View Bookings List
1. After booking, click "View My Bookings"
2. **Expected**: 
   - Your booking appears in the list
   - Shows counselor name, date, time, status
   - Status badge shows "Pending" (orange)

### Test 3: Real-Time Updates
1. Open "My Bookings" list
2. In another browser/tab, book another session
3. **Expected**: 
   - New booking appears automatically without closing the list
   - No manual refresh needed

### Test 4: Check Firestore
1. Go to Firebase Console → Firestore
2. Check `bookings` collection
3. **Expected**: 
   - New document created with all fields
   - `studentId` matches your profile
   - `status` is "Pending"

### Test 5: Check Notifications
1. Go to Firebase Console → Firestore
2. Check `notifications` collection
3. **Expected**: 
   - New notification created
   - `type` is "Booking"
   - `userId` matches your auth UID
   - `isNew` is true

---

## 🎨 Status Badge Colors

The booking list uses color-coded status badges:

| Status | Color | Meaning |
|--------|-------|---------|
| **Pending** | 🟠 Orange | Waiting for counselor confirmation |
| **Confirmed/Approved** | 🟢 Green | Session confirmed by counselor |
| **Cancelled** | 🔴 Red | Session cancelled |
| **Completed** | 🔵 Blue | Session completed |

---

## 🐛 Troubleshooting

### Issue: "No bookings yet" message shows

**Possible causes:**
1. No bookings created for this studentId
2. Firestore query not matching
3. User not logged in

**Solutions:**
- Create a test booking
- Check console for errors
- Verify `studentId` in booking matches profile

### Issue: Bookings not appearing in real-time

**Solutions:**
1. Check Firestore rules allow reading
2. Verify `studentId` field is correct
3. Check console for stream errors
4. Hot reload app (`r` in terminal)

### Issue: Booking created but no notification

**Solutions:**
1. Check if user is logged in (`FirebaseAuth.instance.currentUser`)
2. Verify notification was created in Firestore
3. Check notification screen shows it
4. Ensure `userId` in notification matches auth UID

### Issue: Stream error in console

**Common errors:**
```
Error: The query requires an index
```
**Solution:** This shouldn't happen since we removed `orderBy()` to avoid index requirement.

```
Error: Missing or insufficient permissions
```
**Solution:** Update Firestore security rules (see below)

---

## 📝 Firestore Security Rules

Make sure your rules allow users to read their own bookings:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Bookings
    match /bookings/{bookingId} {
      // Allow read if studentId matches
      allow read: if request.auth != null && 
                     resource.data.studentId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.studentId;
      
      // Allow create for authenticated users
      allow create: if request.auth != null;
    }
    
    // Notifications
    match /notifications/{notificationId} {
      // Allow read if userId matches
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      
      // Allow create for authenticated users
      allow create: if request.auth != null;
    }
    
    // Users
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🎯 Key Improvements

**Before:**
- ❌ Bookings stored in local memory only
- ❌ Lost on app restart
- ❌ No real-time updates
- ❌ No notifications when booking
- ❌ Different users saw same bookings

**After:**
- ✅ Bookings stored in Firestore
- ✅ Persistent across sessions
- ✅ Real-time updates via streams
- ✅ Automatic notifications on booking
- ✅ Each user sees only their bookings
- ✅ Loading, error, and empty states
- ✅ Color-coded status badges
- ✅ Complete booking details display

---

## 📊 Stream Architecture

```
User Books Session
       ↓
BookingService.createBooking()
       ↓
   Firestore (bookings collection)
       ↓
   StreamBuilder listens
       ↓
   UI updates automatically
       ↓
User sees booking instantly
```

---

## ✅ Verification Checklist

After making these changes, verify:

- [ ] Booking saves to Firestore successfully
- [ ] Notification is created automatically
- [ ] Notification badge updates on dashboard
- [ ] "My Bookings" shows the new booking
- [ ] Booking displays all details correctly
- [ ] Status badge shows correct color
- [ ] Real-time updates work (book from another device)
- [ ] Empty state shows when no bookings
- [ ] Loading state shows while fetching
- [ ] Error state shows if something fails
- [ ] Console has no errors

---

## 🔍 Debug Console Messages

Look for these messages to verify everything works:

**Success:**
```
Booking saved to Firestore
Notification sent to user
```

**Errors:**
```
Bookings stream error: [error message]
Firestore Error creating booking: [error message]
```

---

**Last Updated:** 2026-04-22
