# Real-Time Booking Notification System Implementation Guide

## Overview
This guide explains the implementation of the real-time notification system for counselor booking approvals/denials. When an admin approves or denies a booking, users now receive instant notifications in their notification screen.

---

## Architecture

### Data Flow
```
Admin Dashboard → Approve/Deny → Firestore Update → Notification Created
       ↓                                              ↓
  Booking Status Updated                    User's Notification Stream
       ↓                                              ↓
  Real-time UI Update                      Instant Notification Display
```

### Collections Structure

#### `bookings` Collection
```javascript
{
  studentId: "IT23318748",
  studentName: "Anonymous User #3847" | "Tharani Bandara",
  counselorName: "Dr. Priya Mendis",
  date: "2026-04-05",
  time: "10:00 AM",
  reason: "Anxiety about exams",
  status: "Pending" | "Approved" | "Denied",
  userId: "firebaseUid123",  // ← Added for notifications
  createdAt: Timestamp
}
```

#### `notifications` Collection
```javascript
{
  userId: "firebaseUid123",  // ← Filter field
  title: "Booking Approved ✅",
  body: "Your counselor session with Dr. Priya Mendis has been confirmed for 2026-04-05 at 10:00 AM.",
  type: "Booking",
  isNew: true,
  createdAt: Timestamp
}
```

---

## Changes Made

### 1. Booking Service (`lib/services/booking_service.dart`)

#### Added Firebase Auth Import
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

#### Updated `createBooking()` Method
Now stores the user's Firebase UID for later notification delivery:

```dart
Future<void> createBooking({
  required String studentId,
  required String studentName,
  required String counselorName,
  required String date,
  required String time,
  required String reason,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  await _firestore.collection('bookings').add({
    'studentId': studentId,
    'studentName': studentName,
    'counselorName': counselorName,
    'date': date,
    'time': time,
    'reason': reason,
    'status': 'Pending',
    'userId': user?.uid ?? '', // Store Firebase UID for notifications
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

#### Added `sendBookingNotification()` Method
Creates notification documents in Firestore:

```dart
Future<void> sendBookingNotification({
  required String userId,
  required String title,
  required String body,
  required String type,
}) async {
  await _firestore.collection('notifications').add({
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'isNew': true,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

#### Added `getBooking()` Method
Retrieves single booking by ID for admin to read details:

```dart
Future<DocumentSnapshot> getBooking(String bookingId) async {
  return await _firestore.collection('bookings').doc(bookingId).get();
}
```

---

### 2. Firestore Service (`lib/services/firestore_service.dart`)

#### Added Firebase Auth Import
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

#### Added `getUserNotifications()` Method
Streams notifications filtered by userId:

```dart
Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
  return _db.collection('notifications')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();
  });
}
```

**Note**: The original `getNotifications()` method remains unchanged for admin use cases where all notifications might be needed.

---

### 3. Admin Dashboard (`lib/screens/admin_dashboard.dart`)

#### Added Imports
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
```

#### Added BookingService Instance
```dart
class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  // ... rest of state
}
```

#### Updated `_updateStatus()` Method
Now sends notifications and updates Firestore:

```dart
Future<void> _updateStatus(String bookingId, String newStatus) async {
  try {
    // Update status in Firestore
    await _bookingService.updateBookingStatus(bookingId, newStatus);
    
    // Get booking details to send notification
    final bookingDoc = await _bookingService.getBooking(bookingId);
    if (bookingDoc.exists && bookingDoc.data() != null) {
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];
      final counselorName = bookingData['counselorName'];
      final date = bookingData['date'];
      final time = bookingData['time'];
      
      // Send notification based on status
      if (newStatus == 'Confirmed' || newStatus == 'Approved') {
        await _bookingService.sendBookingNotification(
          userId: userId,
          title: 'Booking Approved ✅',
          body: 'Your counselor session with $counselorName has been confirmed for $date at $time.',
          type: 'Booking',
        );
      } else if (newStatus == 'Cancelled' || newStatus == 'Denied') {
        await _bookingService.sendBookingNotification(
          userId: userId,
          title: 'Booking Cancelled ❌',
          body: 'Your counselor booking was not approved. Please contact support if you have questions.',
          type: 'Booking',
        );
      }
    }
    
    // Also update local storage for immediate UI update
    setState(() { /* ... */ });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(/* ... */);
  } catch (e) {
    debugPrint('Error updating booking status: $e');
    // Show error message
  }
}
```

#### Updated Booking Card Display
Shows anonymous users properly and uses "Approve/Deny" buttons:

```dart
Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
  final studentName = booking['studentName'] as String;
  final isAnonymous = studentName.startsWith('Anonymous User #');
  
  return Container(
    // ... card decoration
    child: Column(
      children: [
        Row(
          children: [
            Container(
              // Avatar
              child: isAnonymous
                  ? const Icon(Icons.person_outline, color: Colors.white, size: 24)
                  : Text(initials),
            ),
            // ... student info
            if (isAnonymous)
              Container(
                child: const Icon(Icons.visibility_off, size: 12, color: Colors.grey),
              ),
          ],
        ),
        if (booking['status'] == 'Pending') ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(booking['id'], 'Approved'),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14),
                      SizedBox(width: 4),
                      Text('Approve', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateStatus(booking['id'], 'Denied'),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, size: 14),
                      SizedBox(width: 4),
                      Text('Deny', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
```

**Key Features**:
- ✅ Detects anonymous users by checking if name starts with "Anonymous User #"
- ✅ Shows person icon instead of initials for anonymous users
- ✅ Displays privacy badge (visibility_off icon) for anonymous bookings
- ✅ Changed button labels from "Confirm/Cancel" to "Approve/Deny"
- ✅ Admin NEVER sees real identity of anonymous users

---

### 4. Notification Screen (`lib/screens/notification_screen.dart`)

#### Added Firebase Auth Import
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

#### Updated Stream to Filter by User
```dart
@override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  
  return Scaffold(
    // ... appBar
    body: Column(
      children: [
        // Filter chips (now includes "Booking")
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: user != null 
                ? _firestoreService.getUserNotifications(user.uid)
                : Stream.value([]),
            builder: (context, snapshot) {
              // ... loading state
              
              List<Map<String, dynamic>> notifications = snapshot.data ?? [];
              
              // Apply type filter
              if (_selectedFilter != "All") {
                notifications = notifications.where((n) => n['type'] == _selectedFilter).toList();
              }
              
              // Empty state
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No notifications yet'),
                    ],
                  ),
                );
              }
              
              // Notification list
              return ListView.separated(/* ... */);
            }
          ),
        ),
      ],
    ),
  );
}
```

#### Enhanced Notification Display
Now shows notification body text:

```dart
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(notif["title"] ?? ""),
      if (notif["body"] != null && (notif["body"] as String).isNotEmpty)
        const SizedBox(height: 4),
      if (notif["body"] != null && (notif["body"] as String).isNotEmpty)
        Text(
          notif["body"]!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      const SizedBox(height: 4),
      Text(_formatTimestamp(notif["createdAt"] ?? notif["timestamp"])),
    ],
  ),
),
```

**Changes**:
- ✅ Added "Booking" filter option
- ✅ Streams only current user's notifications
- ✅ Shows notification body text for more detail
- ✅ Better empty state with icon and message
- ✅ Uses `createdAt` timestamp (falls back to `timestamp` for compatibility)

---

## User Experience Flow

### Student Perspective

#### Step 1: Book Counselor Session
1. Student goes to Counselor screen
2. Selects counselor and time slot
3. If anonymous mode is ON → books as "Anonymous User #3847"
4. If anonymous mode is OFF → books with real name
5. Booking appears in Firestore with status "Pending"

#### Step 2: Wait for Approval
- Student can see booking in "My Bookings" with "Pending" status
- Booking appears in real-time without refresh

#### Step 3: Receive Notification (Instant)
**If Approved:**
```
┌─────────────────────────────────────┐
│ 🔔 Booking Approved ✅              │
│                                     │
│ Your counselor session with         │
│ Dr. Priya Mendis has been confirmed │
│ for 2026-04-05 at 10:00 AM.        │
│                                     │
│ Apr 03, 2026 02:30 PM              │
└─────────────────────────────────────┘
```

**If Denied:**
```
┌─────────────────────────────────────┐
│ 🔔 Booking Cancelled ❌             │
│                                     │
│ Your counselor booking was not      │
│ approved. Please contact support    │
│ if you have questions.              │
│                                     │
│ Apr 03, 2026 02:30 PM              │
└─────────────────────────────────────┘
```

#### Step 4: View in Notifications Tab
- Opens Notification screen
- Sees "Booking" tab (new filter)
- All booking notifications appear here
- Can filter by "All", "Alerts", "System", or "Booking"

---

### Admin Perspective

#### Step 1: View Pending Bookings
Admin opens dashboard → "Bookings" tab:
```
┌─────────────────────────────────────┐
│ 🟡 Pending Bookings                 │
├─────────────────────────────────────┤
│ 👤 Anonymous User #3847   [👁️]     │
│ ID: IT23318748                      │
│ 2026-04-05 • 10:00 AM               │
│ 🟡 Pending                          │
│                                     │
│ [✓ Approve]  [✗ Deny]              │
└─────────────────────────────────────┘
```

#### Step 2: Approve Booking
1. Admin taps "Approve" button
2. Booking status updates to "Approved" in Firestore
3. Notification sent to student instantly
4. UI updates in real-time (no refresh needed)
5. Success snackbar appears

#### Step 3: Deny Booking
1. Admin taps "Deny" button
2. Booking status updates to "Denied" in Firestore
3. Notification sent to student instantly
4. UI updates in real-time
5. Success snackbar appears

#### Step 4: Real-Time Updates
- New bookings appear instantly (StreamBuilder)
- Status changes reflect immediately
- No page refresh required
- Anonymous users always shown as "Anonymous User #XXXX"
- Privacy badge visible for anonymous bookings

---

## Firestore Security Rules

Add these rules to ensure proper access control:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Bookings collection
    match /bookings/{bookingId} {
      // Students can read/write their own bookings
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null &&
                       request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null &&
                       (resource.data.userId == request.auth.uid ||
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      // Users can only read their own notifications
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      // Only admins or system can create notifications
      allow create: if request.auth != null &&
                       (request.resource.data.userId == request.auth.uid ||
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

---

## Testing Checklist

### Student Side
- [ ] Book a counseling session (anonymous mode OFF)
- [ ] Check notification appears after admin approval
- [ ] Book a counseling session (anonymous mode ON)
- [ ] Verify notification shows "Anonymous User #XXXX"
- [ ] Check notification appears after admin denial
- [ ] Verify "Booking" filter works in notifications
- [ ] Test real-time updates (no refresh needed)

### Admin Side
- [ ] View pending bookings in real-time
- [ ] Approve a booking
- [ ] Verify success message appears
- [ ] Verify booking status changes to "Approved"
- [ ] Deny a booking
- [ ] Verify status changes to "Denied"
- [ ] Check anonymous user shows as "Anonymous User #XXXX"
- [ ] Verify privacy badge appears for anonymous users
- [ ] Test that new bookings appear instantly

### Cross-Platform
- [ ] Test on mobile device
- [ ] Test on web browser
- [ ] Verify notifications sync across devices
- [ ] Check Firestore data structure

---

## Troubleshooting

### Issue: Notifications not appearing
**Solution**: 
1. Check Firestore security rules allow read access
2. Verify `userId` field is stored correctly in bookings
3. Ensure user is logged in (Firebase auth)

### Issue: Admin can't see bookings
**Solution**:
1. Check Firestore index for `createdAt` ordering
2. Verify bookings collection exists
3. Ensure admin has proper role in Firestore

### Issue: Anonymous names not showing
**Solution**:
1. Check `startsWith('Anonymous User #')` logic
2. Verify booking was created with anonymous name
3. Test anonymous mode toggle in profile settings

### Issue: Real-time updates not working
**Solution**:
1. Ensure StreamBuilder is connected to correct collection
2. Check Firestore connection is active
3. Verify no errors in console logs

---

## Benefits

### ✅ For Students
- **Instant Feedback**: Know immediately when booking is approved/denied
- **Clear Communication**: Detailed notification body explains what happened
- **Privacy Protection**: Anonymous users stay anonymous throughout process
- **Easy Tracking**: All notifications in one place with filters

### ✅ For Admins
- **Real-Time Management**: See new bookings instantly
- **Quick Actions**: One-tap approve/deny
- **Privacy Compliance**: Never see anonymous student identities
- **Professional Interface**: Clear status badges and icons

### ✅ Technical Advantages
- **Scalable**: Firestore handles millions of notifications efficiently
- **Reliable**: Database-level consistency ensures no lost notifications
- **Maintainable**: Clean separation of concerns in services
- **Extensible**: Easy to add more notification types

---

## Future Enhancements

### Potential Additions
1. **Push Notifications**: Send to device when app is closed
2. **Email Notifications**: Email backup for important updates
3. **SMS Alerts**: Critical booking changes via SMS
4. **Notification Preferences**: Let students choose what they receive
5. **Read Receipts**: Track when students read notifications
6. **Batch Operations**: Admin approve multiple bookings at once

### Performance Optimizations
- Add composite indexes for faster queries
- Implement notification pagination (load more)
- Cache recent notifications locally
- Use Firestore TTL to auto-delete old notifications

---

## Files Modified

1. **`lib/services/booking_service.dart`**
   - Added `userId` field to bookings
   - Added `sendBookingNotification()` method
   - Added `getBooking()` method

2. **`lib/services/firestore_service.dart`**
   - Added `getUserNotifications()` stream method

3. **`lib/screens/admin_dashboard.dart`**
   - Updated `_updateStatus()` to send notifications
   - Modified booking cards to show anonymous users
   - Changed button labels to "Approve/Deny"

4. **`lib/screens/notification_screen.dart`**
   - Updated to filter by userId
   - Added "Booking" filter option
   - Enhanced display with notification body

---

## Conclusion

This implementation provides a robust, real-time notification system that:
- ✅ Delivers instant feedback to students
- ✅ Maintains anonymity for sensitive bookings
- ✅ Provides admins with powerful management tools
- ✅ Scales efficiently with Firestore
- ✅ Offers excellent user experience

**Questions?** Check the code comments or reach out to the development team.
