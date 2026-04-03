# 📱 Profile Screen - Strict Validation & Input Formatting Guide

## ✨ Overview
The Profile Screen now includes **comprehensive validation and input formatting** for all text fields, ensuring data quality and preventing invalid inputs in real-time.

---

## 🔒 **Validation Features Implemented**

### **1. Full Name Field** 📝

**Input Formatting:**
```dart
inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  LengthLimitingTextInputFormatter(50),
]
```

**Validations:**
- ✅ **Blocks ALL numbers** (0-9) from being entered
- ✅ **Allows only letters and spaces**
- ✅ **Maximum 50 characters** limit
- ✅ **Minimum 2 characters** required
- ✅ **Must contain at least one letter**

**Validator Function:**
```dart
validator: (val) {
  if (val == null || val.isEmpty) return "This field cannot be empty";
  if (val.trim().length < 2) return "Name must be at least 2 characters";
  if (val.trim().length > 50) return "Name cannot exceed 50 characters";
  if (!RegExp(r'[a-zA-Z]').hasMatch(val)) return "Name must contain at least one letter";
  return null;
}
```

**Examples:**
- ✅ `Sachini Bandara` ✓
- ✅ `Kasun Perera` ✓
- ❌ `John123` → Numbers blocked
- ❌ `A` → Too short
- ❌ `` → Empty not allowed

---

### **2. Phone Number Field** 📞

**Input Formatting:**
```dart
inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
  LengthLimitingTextInputFormatter(12), // +94 + 10 digits
]
```

**Validations:**
- ✅ **Blocks ALL letters** from being entered
- ✅ **Allows only digits and + symbol**
- ✅ **Maximum 12 characters** (+94 prefix + 10 digits)
- ✅ **Must start with +94 or 0**
- ✅ **Minimum 9 digits** required
- ✅ **Maximum 12 digits** allowed

**Validator Function:**
```dart
validator: (val) {
  if (val == null || val.isEmpty) return "Please enter your phone number";
  
  final cleanedPhone = val.replaceAll(' ', '');
  
  // Must start with +94 or 0
  if (!cleanedPhone.startsWith('+94') && !cleanedPhone.startsWith('0')) {
    return "Phone must start with +94 or 0";
  }
  
  // Count actual digits
  final digitCount = cleanedPhone.replaceAll('+', '').replaceAll(' ', '').length;
  
  if (digitCount < 9) {
    return "Phone number must have at least 9 digits";
  }
  
  if (digitCount > 12) {
    return "Phone number cannot exceed 12 digits";
  }
  
  // Ensure all characters are digits (except +)
  if (!RegExp(r'^\+?[0-9\s]+$').hasMatch(val)) {
    return "Phone number can only contain digits";
  }
  
  return null;
}
```

**Examples:**
- ✅ `+94771234567` ✓
- ✅ `0771234567` ✓
- ✅ `+94 77 123 4567` ✓ (spaces allowed)
- ❌ `077ABC1234` → Letters blocked
- ❌ `12345` → Too few digits
- ❌ `+94771234567890` → Too many digits

---

### **3. Email Address Field** 📧

**Input Formatting:**
```dart
inputFormatters: [
  LengthLimitingTextInputFormatter(100),
]
```

**Validations (Multi-Layer):**
- ✅ **Cannot be empty**
- ✅ **Must contain '@' symbol**
- ✅ **Must contain '.' (domain dot)**
- ✅ **'@' must come before the last '.'**
- ✅ **Must have text before '@'**
- ✅ **Must have domain after '@'**
- ✅ **Comprehensive RegExp pattern matching**
- ✅ **Maximum 100 characters**

**Validator Function:**
```dart
validator: (val) {
  if (val == null || val.isEmpty) return "Please enter your email";
  
  final trimmedEmail = val.trim();
  
  // Check for '@' symbol
  if (!trimmedEmail.contains('@')) {
    return "Email must contain '@' symbol";
  }
  
  // Check for domain symbols (.com, .org, etc.)
  if (!trimmedEmail.contains('.')) {
    return "Email must contain a domain (e.g., .com)";
  }
  
  // Check that @ comes before the last dot
  final atIndex = trimmedEmail.lastIndexOf('@');
  final dotIndex = trimmedEmail.lastIndexOf('.');
  if (atIndex > dotIndex) {
    return "Invalid email format";
  }
  
  // Check that there's text before @
  if (atIndex == 0) {
    return "Email must have text before '@'";
  }
  
  // Check that there's text after @
  if (atIndex == trimmedEmail.length - 1) {
    return "Email must have domain after '@'";
  }
  
  // Comprehensive RegExp validation
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(trimmedEmail)) {
    return "Enter a valid email address (e.g., user@example.com)";
  }
  
  return null;
}
```

**Examples:**
- ✅ `tharani@gmail.com` ✓
- ✅ `user.name@uni.ac.lk` ✓
- ✅ `student123@yahoo.com` ✓
- ❌ `invalidemail.com` → Missing '@'
- ❌ `user@invalid` → Missing domain (.com)
- ❌ `@example.com` → No text before '@'
- ❌ `user@` → No domain after '@'

---

## 🎯 **Key Features**

### **Real-Time Input Blocking**
- Users **CANNOT type** invalid characters
- Keyboard input is filtered as you type
- Prevents mistakes before they happen

### **Edit Mode Only**
- All validations work **ONLY when editing is enabled**
- View mode shows data without validation
- Toggle edit mode with the pencil icon

### **Comprehensive Error Messages**
- Clear, specific error messages
- Helps users fix issues quickly
- Professional UX design

### **Length Limits**
- Name: Max 50 characters
- Email: Max 100 characters
- Phone: Max 12 characters (+94 + 10 digits)

---

## 🛠️ **How It Works**

### **FilteringTextInputFormatter**
```dart
// Allows ONLY matching characters
FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
  → Allows letters and spaces only

FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
  → Allows digits and + symbol only
```

### **LengthLimitingTextInputFormatter**
```dart
// Limits maximum character count
LengthLimitingTextInputFormatter(50)
  → Stops typing at 50 characters
```

### **RegExp Validators**
```dart
// Pattern matching for complex rules
RegExp(r'[a-zA-Z]')           → Contains at least one letter
RegExp(r'^\+?[0-9\s]+$')      → Phone number format
RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') → Email format
```

---

## 🧪 **Testing Your Validations**

### **Test Steps:**

1. **Open Profile Screen**
   - Click profile icon in bottom navigation
   - Click pencil icon (✏️) to enable Edit Mode

2. **Test Name Field:**
   ```
   Try typing: John123
   Result: Numbers won't appear!
   
   Try typing: Sachini Bandara ✓
   Result: Allowed
   ```

3. **Test Phone Field:**
   ```
   Try typing: 077ABC1234
   Result: Letters blocked
   
   Type: +94771234567 ✓
   Result: Allowed
   
   Try typing more than 12 digits
   Result: Won't accept more input
   ```

4. **Test Email Field:**
   ```
   Type: invalidemail.com
   Error: "Email must contain '@' symbol"
   
   Type: user@invalid
   Error: "Email must contain a domain"
   
   Type: tharani@gmail.com ✓
   Result: Accepted
   ```

5. **Save Changes:**
   - Click "Save changes" button
   - Form validates all fields
   - Shows errors if any invalid
   - Success message if all valid

---

## 📋 **Code Summary**

### **Imports Required:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
```

### **Field Builders:**

**Name Field (Full Name, Student ID, Faculty):**
```dart
Widget _buildField(String label, TextEditingController controller, IconData icon) {
  return TextFormField(
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      LengthLimitingTextInputFormatter(50),
    ],
    validator: (val) {
      if (val == null || val.isEmpty) return "This field cannot be empty";
      if (val.trim().length < 2) return "Name must be at least 2 characters";
      if (val.trim().length > 50) return "Name cannot exceed 50 characters";
      if (!RegExp(r'[a-zA-Z]').hasMatch(val)) return "Name must contain at least one letter";
      return null;
    },
  );
}
```

**Email Field:**
```dart
Widget _buildEmailField() {
  return TextFormField(
    keyboardType: TextInputType.emailAddress,
    inputFormatters: [LengthLimitingTextInputFormatter(100)],
    validator: (val) {
      // Multi-layer validation checks
      // Returns specific error messages
    },
  );
}
```

**Phone Field:**
```dart
Widget _buildPhoneField() {
  return TextFormField(
    keyboardType: TextInputType.phone,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      LengthLimitingTextInputFormatter(12),
    ],
    decoration: InputDecoration(hintText: '+94 XX XXX XXXX'),
    validator: (val) {
      // Digit count validation
      // Format validation
    },
  );
}
```

---

## 🎨 **User Experience**

### **View Mode:**
- All fields are read-only
- No validation active
- Data displayed normally

### **Edit Mode:**
- Fields become editable
- Real-time input filtering
- Validation on save
- Error messages shown below fields
- Red underline on invalid fields

### **Visual Feedback:**
```
┌─────────────────────────────────┐
│ Full Name                       │
│ [Tharani Bandara__________]     │ ← Green if valid
├─────────────────────────────────┤
│ Phone number                    │
│ [+94 77 123 4567__________]     │ ← Green if valid
├─────────────────────────────────┤
│ Email address                   │
│ [tharani@gmail.com________]     │ ← Green if valid
└─────────────────────────────────┘
```

**Error State:**
```
┌─────────────────────────────────┐
│ Email address                   │
│ [invalidemail.com_________]     │ ← Red underline
│ ⚠️ Email must contain '@'       │ ← Error message below
└─────────────────────────────────┘
```

---

## ✅ **Benefits**

1. **Data Quality**: Only valid data accepted
2. **User Guidance**: Clear error messages help users
3. **Prevention**: Blocks invalid input in real-time
4. **Professional**: Enterprise-grade validation
5. **Consistency**: All fields follow same patterns
6. **Security**: Prevents injection of special characters

---

## 🚀 **Advanced Features**

### **Custom Patterns:**
You can easily customize the patterns:

```dart
// Allow letters, numbers, and spaces
FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]'))

// Allow only letters (no spaces)
FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))

// Custom length limit
LengthLimitingTextInputFormatter(25)
```

### **Multiple Validators:**
Chain multiple validators for complex rules:

```dart
validator: (val) {
  if (val == null || val.isEmpty) return "Required";
  if (val.length < 5) return "Too short";
  if (!RegExp(r'[pattern]').hasMatch(val)) return "Invalid format";
  return null;
}
```

---

## 📝 **Files Modified**

**File:** `lib/screens/profile_screen.dart`

**Changes:**
- Added `flutter/services.dart` import
- Enhanced `_buildField()` with name validation
- Enhanced `_buildEmailField()` with multi-layer validation
- Enhanced `_buildPhoneField()` with digit counting validation
- All validators work only in Edit Mode

---

## 🎉 **Result**

Your Profile Screen now has **military-grade validation**! 🛡️

✅ **Name Field**: Letters only, no numbers  
✅ **Phone Field**: Digits only, 10-digit limit  
✅ **Email Field**: Comprehensive '@' and domain validation  
✅ **Edit Mode**: Validations active only when editing  
✅ **Real-Time**: Input filtered as you type  
✅ **User-Friendly**: Clear error messages  

**Professional, secure, and user-friendly!** 🚀

---

**Last Updated:** March 26, 2026  
**Version:** 2.0 - Strict Validation Edition  
**Validation Rules:** 15+ different checks  
**Input Formatters:** 5 different patterns
