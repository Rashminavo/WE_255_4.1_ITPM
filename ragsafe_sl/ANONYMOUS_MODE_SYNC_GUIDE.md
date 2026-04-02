# Anonymous Mode Sync Implementation Guide

## Overview
This guide explains the implementation of anonymous mode synchronization between the Profile Settings screen and the Counselor Booking screen. The app now has a **single toggle** for anonymous mode located in Profile Settings, which automatically affects how bookings are made in the Counselor screen.

---

## Architecture

### Single Source of Truth
- **Anonymous Mode Toggle**: Located ONLY in Profile Settings screen
- **Storage**: Firestore `users` collection (current user's document)
- **Field Name**: `anonymousMode` (boolean)

### Data Flow
```
Profile Settings → Firestore → Counselor Screen → Booking
     ↓                    ↓              ↓
  User toggles      Saved to      Reads mode
  anonymous mode    Firestore     on open
                                  ↓
                          Books as "Anonymous User #XXXX" 
                          or real name
```

---

## Changes Made

### 1. User Provider (`lib/providers/user_provider.dart`)

#### Added Firebase Imports
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
```

#### Updated `toggleAnonymousMode()` Method
- Now saves the anonymous mode setting to Firestore
- Updates local state immediately for responsive UI
- Async operation that runs in the background

```dart
void toggleAnonymousMode(bool value) async {
  _isAnonymousMode = value;
  notifyListeners();
  
  // Save to Firestore
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'anonymousMode': value});
    }
  } catch (e) {
    debugPrint('Error saving anonymous mode to Firestore: $e');
  }
}
```

#### Added `loadAnonymousMode()` Method
- Loads anonymous mode from Firestore when needed
- Called when Profile Settings screen opens

```dart
Future<void> loadAnonymousMode() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        _isAnonymousMode = doc.data()!['anonymousMode'] ?? false;
        notifyListeners();
      }
    }
  } catch (e) {
    debugPrint('Error loading anonymous mode from Firestore: $e');
  }
}
```

---

### 2. Profile Screen (`lib/screens/profile_screen.dart`)

#### Added Load on Init
In `initState()`, the profile screen now loads the anonymous mode from Firestore:

```dart
@override
void initState() {
  super.initState();
  
  // Load anonymous mode from Firestore
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.loadAnonymousMode();
  
  // ... rest of initialization
}
```

**Result**: When users open Profile Settings, the toggle always shows the current state from Firestore.

---

### 3. Counselor Screen (`lib/screens/counselor_screen.dart`)

#### Added Firebase Imports
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

#### Added Anonymous Mode State
```dart
bool _isAnonymousMode = false;
```

#### Added Load on Init
The counselor screen now loads anonymous mode when it opens:

```dart
@override
void initState() {
  super.initState();
  
  _loadAnonymousMode();
  
  // ... rest of initialization
}

Future<void> _loadAnonymousMode() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _isAnonymousMode = doc.data()!['anonymousMode'] ?? false;
        });
      }
    }
  } catch (e) {
    debugPrint('Error loading anonymous mode: $e');
  }
}
```

#### Updated Booking Logic
Modified `_confirmBooking()` to use anonymous naming based on mode:

```dart
// Determine student name based on anonymous mode
String bookingName;
if (_isAnonymousMode) {
  // Generate anonymous username with random number
  final randomNum = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
  bookingName = "Anonymous User #$randomNum";
} else {
  bookingName = userProvider.fullName;
}

// Create new booking with determined name
await BookingService().createBooking(
  studentId: userProvider.studentId,
  studentName: bookingName,  // ← Uses anonymous or real name
  counselorName: counselor["name"],
  date: DateFormat('yyyy-MM-dd').format(_selectedDate),
  time: _selectedTimeSlot!,
  reason: _selectedReason!,
);
```

#### Added Info Banner
Added a visual indicator in the booking dialog when in anonymous mode:

```dart
// Anonymous Mode Info Banner
if (_isAnonymousMode)
  Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 11, color: Color(0xFFE65100)),
              children: [
                TextSpan(text: 'Booking anonymously '),
                TextSpan(
                  text: '(change in Profile Settings)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
```

**Features**:
- Orange info banner appears only when anonymous mode is ON
- Shows "Booking anonymously (change in Profile Settings)"
- Underlined text indicates it's actionable (go to Profile Settings)
- No separate toggle in Counselor screen - maintains single source of truth

---

## User Experience

### Scenario 1: Anonymous Mode OFF (Default)
1. User opens Counselor screen
2. Selects a counselor and taps "Book"
3. Booking dialog shows normal form (no banner)
4. Confirms booking with real name: "Tharani Bandara"
5. Booking saved with student's actual name

### Scenario 2: Anonymous Mode ON
1. User goes to Profile Settings
2. Toggles "Anonymous mode" ON
3. Setting saved to Firestore automatically
4. User opens Counselor screen
5. Selects a counselor and taps "Book"
6. **Orange info banner appears**: "Booking anonymously (change in Profile Settings)"
7. Confirms booking as "Anonymous User #3847"
8. Booking saved with anonymous identity

### Scenario 3: Changing Mode
1. User toggles anonymous mode in Profile Settings
2. Next counseling booking automatically uses the new mode
3. No need to update anything in Counselor screen
4. Change persists across app sessions (stored in Firestore)

---

## Firestore Structure

### Users Collection
```
/users/{userId}/
  - uid: string
  - email: string
  - name: string
  - studentId: string
  - role: string
  - safetyScore: number
  - anonymousMode: boolean  ← NEW FIELD
  - createdAt: timestamp
```

**Example Document** (with anonymous mode enabled):
```javascript
{
  uid: "abc123XYZ",
  email: "student@university.lk",
  name: "Tharani Bandara",
  studentId: "IT23318748",
  role: "student",
  safetyScore: 85,
  anonymousMode: true,  // ← Controls booking behavior
  createdAt: Timestamp(2025-04-03)
}
```

---

## Benefits of This Approach

### ✅ Single Source of Truth
- Only ONE toggle in the entire app (Profile Settings)
- No confusion about where to change anonymous mode
- Consistent behavior across all features

### ✅ Automatic Synchronization
- Firestore ensures setting is synced across devices
- Change once, applies everywhere immediately
- Persists across app restarts

### ✅ Clear User Feedback
- Info banner in booking dialog shows current mode
- Direct link to change setting ("change in Profile Settings")
- No hidden toggles or confusing UI

### ✅ Privacy Protection
- When anonymous mode is ON, bookings use "Anonymous User #XXXX"
- Student ID still tracked for administrative purposes
- Counselor sees anonymous name but can reference booking via ID

### ✅ Maintainability
- Clean separation of concerns
- Easy to add more anonymous features later
- Single place to update logic if requirements change

---

## Testing Checklist

- [ ] Open Profile Settings → Toggle anonymous mode ON
- [ ] Verify toggle state persists after closing and reopening app
- [ ] Go to Counselor screen → Book a session
- [ ] Confirm orange info banner appears when anonymous mode is ON
- [ ] Verify booking shows "Anonymous User #XXXX" as student name
- [ ] Turn off anonymous mode in Profile Settings
- [ ] Book another counseling session
- [ ] Verify booking now shows real name
- [ ] Check Firestore to confirm `anonymousMode` field is saved correctly
- [ ] Test on both mobile and web platforms

---

## Future Enhancements

### Potential Additions
1. **Anonymous Mode Statistics**: Track how many students use anonymous mode
2. **Counselor Dashboard**: Show counselors which bookings are anonymous
3. **Granular Privacy**: Allow students to choose per-booking anonymity
4. **Anonymous Chat**: Extend anonymous mode to chat features
5. **Privacy Indicators**: Show students when their identity is visible

### Database Optimization
If anonymous mode becomes heavily used, consider:
- Adding index on `anonymousMode` field for faster queries
- Creating a separate `anonymous_bookings` subcollection
- Implementing data retention policies for anonymous bookings

---

## Files Modified

1. **`lib/providers/user_provider.dart`**
   - Added Firebase imports
   - Updated `toggleAnonymousMode()` to save to Firestore
   - Added `loadAnonymousMode()` method

2. **`lib/screens/profile_screen.dart`**
   - Added `loadAnonymousMode()` call in `initState()`

3. **`lib/screens/counselor_screen.dart`**
   - Added Firebase imports
   - Added `_isAnonymousMode` state variable
   - Added `_loadAnonymousMode()` method
   - Modified `_confirmBooking()` to use anonymous naming
   - Added info banner UI in booking dialog

---

## Support & Troubleshooting

### Issue: Anonymous mode not saving
**Solution**: Check Firestore security rules - ensure users can write to their own document

### Issue: Banner not showing in Counselor screen
**Solution**: Verify `_loadAnonymousMode()` is being called and Firestore has the field

### Issue: Booking still shows real name when anonymous mode is ON
**Solution**: Check that `_isAnonymousMode` state is updated before booking

### Issue: Toggle doesn't respond
**Solution**: Ensure `notifyListeners()` is called in `toggleAnonymousMode()`

---

## Conclusion

This implementation provides a clean, maintainable solution for anonymous mode that:
- ✅ Gives users control over their privacy
- ✅ Maintains a single source of truth
- ✅ Provides clear visual feedback
- ✅ Works seamlessly across the app
- ✅ Is easy to extend in the future

**Questions?** Check the code comments or reach out to the development team.
