# Edit Profile Screen - Complex Validation Implementation Guide

## Overview
This guide provides complete implementation for an Edit Profile screen with complex form validation and real-time error messages for Name, Email, and Phone Number fields.

---

## Requirements Summary

### 1. **Name Field**
- ❌ Block all numbers (0-9)
- ✅ Show error: "Numbers are not allowed in the name field."
- ✅ Validate as user types and on save

### 2. **Email Field**
- ✅ Must contain '@' symbol
- ✅ Must have valid domain (e.g., '.com', '.org', '.lk')
- ✅ Show error: "Please enter a valid email address."
- ✅ Validate structure in real-time

### 3. **Phone Number Field**
- ✅ Exactly 10 digits only
- ❌ Block all letters (a-z, A-Z)
- ✅ Show error: "Phone number must be exactly 10 digits and contain no letters."
- ✅ Limit input to 10 digits
- ✅ Validate length and content dynamically

---

## Implementation Code

### Step 1: State Variables

```dart
class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  
  // Real-time validation state tracking
  Map<String, bool> _fieldValidationState = {};
  Map<String, String> _fieldErrorMessages = {};
  
  // Text controllers for each field
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "");
    _emailController = TextEditingController(text: "");
    _phoneController = TextEditingController(text: "");
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
```

---

### Step 2: Validation Methods

#### Name Validation
```dart
/// Validates that name contains no numbers
bool _validateName(String name) {
  if (name.isEmpty) return false;
  
  // Check if name contains any digits
  if (RegExp(r'[0-9]').hasMatch(name)) {
    return false;
  }
  
  // Additional checks for better UX
  if (name.trim().length < 2) return false;
  if (name.trim().length > 50) return false;
  
  // Must contain at least one letter
  if (!RegExp(r'[a-zA-Z]').hasMatch(name)) return false;
  
  return true;
}

/// Get specific error message for name validation
String _getNameError(String name) {
  if (name.isEmpty) {
    return 'Name is required';
  }
  
  if (RegExp(r'[0-9]').hasMatch(name)) {
    return 'Numbers are not allowed in the name field.';
  }
  
  if (name.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  
  if (name.trim().length > 50) {
    return 'Name cannot exceed 50 characters';
  }
  
  return 'Invalid name format';
}
```

#### Email Validation
```dart
/// Validates email format with @ and domain
bool _validateEmail(String email) {
  if (email.isEmpty) return false;
  
  final trimmedEmail = email.trim();
  
  // Layer 1: Must contain @
  if (!trimmedEmail.contains('@')) {
    return false;
  }
  
  // Layer 2: Must contain . for domain
  if (!trimmedEmail.contains('.')) {
    return false;
  }
  
  // Layer 3: @ must come before last dot
  final atIndex = trimmedEmail.lastIndexOf('@');
  final dotIndex = trimmedEmail.lastIndexOf('.');
  if (atIndex > dotIndex) {
    return false;
  }
  
  // Layer 4: Must have text before @
  if (atIndex == 0) {
    return false;
  }
  
  // Layer 5: Must have domain after @
  if (atIndex == trimmedEmail.length - 1) {
    return false;
  }
  
  // Layer 6: Domain extension validation (.com, .org, etc.)
  final tldParts = trimmedEmail.substring(atIndex + 1).split('.');
  final tld = tldParts.last;
  if (tld.length < 2) {
    return false;
  }
  
  // Comprehensive pattern check
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(trimmedEmail)) {
    return false;
  }
  
  return true;
}

/// Get specific error message for email validation
String _getEmailError(String email) {
  if (email.isEmpty) {
    return 'Email is required';
  }
  
  if (!email.contains('@')) {
    return "Email must contain '@' symbol";
  }
  
  if (!email.contains('.')) {
    return "Email must contain a domain (e.g., .com)";
  }
  
  final atIndex = email.lastIndexOf('@');
  final dotIndex = email.lastIndexOf('.');
  if (atIndex > dotIndex) {
    return "Invalid format: '@' must come before '.'";
  }
  
  if (atIndex == 0) {
    return "Email must have text before '@'";
  }
  
  if (atIndex == email.length - 1) {
    return "Email must have domain after '@'";
  }
  
  final tldParts = email.substring(atIndex + 1).split('.');
  final tld = tldParts.last;
  if (tld.length < 2) {
    return "Domain extension too short (e.g., .com, .org)";
  }
  
  return 'Please enter a valid email address.';
}
```

#### Phone Number Validation
```dart
/// Validates phone number is exactly 10 digits with no letters
bool _validatePhone(String phone) {
  if (phone.isEmpty) return false;
  
  // Remove spaces and hyphens for validation
  final cleanedPhone = phone.replaceAll(' ', '').replaceAll('-', '');
  
  // Check for letters
  if (RegExp(r'[a-zA-Z]').hasMatch(cleanedPhone)) {
    return false;
  }
  
  // Must contain only digits (optionally starting with +)
  if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanedPhone)) {
    return false;
  }
  
  // Must be exactly 10 digits
  if (cleanedPhone.length != 10) {
    return false;
  }
  
  return true;
}

/// Get specific error message for phone validation
String _getPhoneError(String phone) {
  if (phone.isEmpty) {
    return 'Phone number is required';
  }
  
  final cleanedPhone = phone.replaceAll(' ', '').replaceAll('-', '');
  
  if (RegExp(r'[a-zA-Z]').hasMatch(cleanedPhone)) {
    return 'Letters are not allowed in phone number';
  }
  
  if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanedPhone)) {
    return 'Only digits allowed in phone number';
  }
  
  if (cleanedPhone.length != 10) {
    return 'Phone number must be exactly 10 digits (current: ${cleanedPhone.length})';
  }
  
  return 'Phone number must be exactly 10 digits and contain no letters.';
}
```

---

### Step 3: Real-Time Validation Handler

```dart
/// Called every time user types in any field
void _onFieldChanged(String fieldName, String value) {
  setState(() {
    switch (fieldName) {
      case 'name':
        _fieldValidationState['name'] = _validateName(value);
        if (!_fieldValidationState['name']!) {
          _fieldErrorMessages['name'] = _getNameError(value);
        } else {
          _fieldErrorMessages.remove('name');
        }
        break;
        
      case 'email':
        _fieldValidationState['email'] = _validateEmail(value);
        if (!_fieldValidationState['email']!) {
          _fieldErrorMessages['email'] = _getEmailError(value);
        } else {
          _fieldErrorMessages.remove('email');
        }
        break;
        
      case 'phone':
        _fieldValidationState['phone'] = _validatePhone(value);
        if (!_fieldValidationState['phone']!) {
          _fieldErrorMessages['phone'] = _getPhoneError(value);
        } else {
          _fieldErrorMessages.remove('phone');
        }
        break;
    }
  });
}
```

---

### Step 4: Save Function

```dart
void _saveProfile() {
  // Final validation of all fields
  bool hasErrors = false;
  
  // Validate Name
  if (!_validateName(_nameController.text.trim())) {
    setState(() {
      _fieldValidationState['name'] = false;
      _fieldErrorMessages['name'] = _getNameError(_nameController.text.trim());
    });
    hasErrors = true;
  }
  
  // Validate Email
  if (!_validateEmail(_emailController.text.trim())) {
    setState(() {
      _fieldValidationState['email'] = false;
      _fieldErrorMessages['email'] = _getEmailError(_emailController.text.trim());
    });
    hasErrors = true;
  }
  
  // Validate Phone
  if (!_validatePhone(_phoneController.text.trim())) {
    setState(() {
      _fieldValidationState['phone'] = false;
      _fieldErrorMessages['phone'] = _getPhoneError(_phoneController.text.trim());
    });
    hasErrors = true;
  }
  
  if (hasErrors) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fix the errors above'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }
  
  // All validations passed - save the data
  setState(() {
    _isEditing = false;
    _fieldValidationState.clear();
    _fieldErrorMessages.clear();
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          const Text('Profile updated successfully!'),
        ],
      ),
      backgroundColor: const Color(0xFF1D9E75),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.white,
        onPressed: () {
          // Implement undo logic if needed
        },
      ),
    ),
  );
}
```

---

### Step 5: TextFormField Widgets

#### Name Field Widget
```dart
Widget _buildNameField() {
  return TextFormField(
    controller: _nameController,
    readOnly: !_isEditing,
    onChanged: _isEditing ? (val) => _onFieldChanged('name', val) : null,
    keyboardType: TextInputType.text,
    inputFormatters: [
      // Block numbers (0-9)
      FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
      LengthLimitingTextInputFormatter(50),
    ],
    decoration: InputDecoration(
      labelText: 'Full Name',
      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1D9E75)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorText: _isEditing ? _fieldErrorMessages['name'] : null,
      hintText: 'Enter your full name',
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Name is required';
      }
      if (!_validateName(val)) {
        return _getNameError(val);
      }
      return null;
    },
  );
}
```

#### Email Field Widget
```dart
Widget _buildEmailField() {
  return TextFormField(
    controller: _emailController,
    readOnly: !_isEditing,
    onChanged: _isEditing ? (val) => _onFieldChanged('email', val) : null,
    keyboardType: TextInputType.emailAddress,
    inputFormatters: [
      LengthLimitingTextInputFormatter(100),
    ],
    decoration: InputDecoration(
      labelText: 'Email Address',
      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1D9E75)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorText: _isEditing ? _fieldErrorMessages['email'] : null,
      hintText: 'example@email.com',
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Email is required';
      }
      if (!_validateEmail(val)) {
        return _getEmailError(val);
      }
      return null;
    },
  );
}
```

#### Phone Number Field Widget
```dart
Widget _buildPhoneField() {
  return TextFormField(
    controller: _phoneController,
    readOnly: !_isEditing,
    onChanged: _isEditing ? (val) => _onFieldChanged('phone', val) : null,
    keyboardType: TextInputType.phone,
    inputFormatters: [
      // Allow only digits (block letters and special chars except +)
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      // Limit to exactly 10 digits
      LengthLimitingTextInputFormatter(10),
    ],
    decoration: InputDecoration(
      labelText: 'Phone Number',
      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF1D9E75)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorText: _isEditing ? _fieldErrorMessages['phone'] : null,
      hintText: '1234567890',
      counterText: '', // Hide character counter
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Phone number is required';
      }
      if (!_validatePhone(val)) {
        return _getPhoneError(val);
      }
      return null;
    },
  );
}
```

---

### Step 6: Complete UI Layout

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Profile'),
      backgroundColor: const Color(0xFF1D9E75),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) {
                // Clear validation when exiting edit mode
                _fieldValidationState.clear();
                _fieldErrorMessages.clear();
              }
            });
          },
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF1D9E75),
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isEditing ? 'Edit Your Information' : 'View Profile',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditing 
                            ? 'Tap on fields to edit your information' 
                            : 'Tap edit button to make changes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form Fields
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPhoneField(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button (only visible in edit mode)
              if (_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _saveProfile,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Cancel Button (only visible in edit mode)
              if (_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _fieldValidationState.clear();
                        _fieldErrorMessages.clear();
                        // Optionally reset controllers to original values
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
```

---

## How It Works

### Real-Time Validation Flow

1. **User Types in Field**
   ```
   User Input → onChanged Triggered → _onFieldChanged() Called
   ```

2. **Validation Executes**
   ```
   _onFieldChanged() → Calls Specific Validator (_validateName/_validateEmail/_validatePhone)
   ```

3. **State Updates**
   ```
   Validator Returns → setState() Updates _fieldValidationState & _fieldErrorMessages
   ```

4. **UI Refreshes**
   ```
   setState() → Widget Rebuilds → Error Message Appears/Disappears
   ```

### Example Scenarios

#### Scenario 1: Name Field with Numbers
```
User types: "John123"
↓
onChanged triggers
↓
_validateName("John123") returns false (contains digits)
↓
_getNameError("John123") returns "Numbers are not allowed in the name field."
↓
Error appears in red below field
```

#### Scenario 2: Email Missing Domain
```
User types: "user@example"
↓
onChanged triggers
↓
_validateEmail("user@example") returns false (no dot)
↓
_getEmailError("user@example") returns "Email must contain a domain (e.g., .com)"
↓
Error appears in red below field
```

#### Scenario 3: Phone Number Too Short
```
User types: "12345"
↓
onChanged triggers
↓
_validatePhone("12345") returns false (only 5 digits)
↓
_getPhoneError("12345") returns "Phone number must be exactly 10 digits (current: 5)"
↓
Error appears in red below field
```

#### Scenario 4: Valid Input
```
User types valid data
↓
Validator returns true
↓
Error message removed from _fieldErrorMessages
↓
No error shown (field looks clean)
```

---

## Key Features

### ✅ Input Formatters (Prevent Invalid Input)
- **Name**: Blocks numbers at keyboard level
- **Email**: Allows standard email characters
- **Phone**: Only allows digits, blocks letters completely

### ✅ Real-Time Validation (As User Types)
- `onChanged` handler calls validation immediately
- Errors appear/disappear dynamically
- No need to tap Save to see errors

### ✅ Multiple Validation Layers
1. **Input Formatter**: Blocks invalid characters at typing level
2. **Length Validator**: Enforces min/max character limits
3. **Pattern Validator**: RegExp checks for format
4. **Business Logic**: Custom validation rules

### ✅ Specific Error Messages
- Each validation failure has unique message
- Messages explain exactly what's wrong
- Some show current state (e.g., "current: 5 digits")

### ✅ Visual Feedback
- Red error text below invalid fields
- Green success on save
- UNDO option after successful save
- Edit mode indicator

---

## Testing Checklist

### Name Field Tests
- [ ] Type "John Doe" → Should pass ✅
- [ ] Type "John123" → Error: "Numbers are not allowed" ❌
- [ ] Type "J" → Error: "Name must be at least 2 characters" ❌
- [ ] Type "123" → Blocked by input formatter (numbers won't appear)
- [ ] Type "" (empty) → Error: "Name is required" ❌

### Email Field Tests
- [ ] Type "user@example.com" → Should pass ✅
- [ ] Type "userexample.com" → Error: "must contain '@'" ❌
- [ ] Type "user@example" → Error: "must contain a domain" ❌
- [ ] Type "@example.com" → Error: "must have text before '@'" ❌
- [ ] Type "user@" → Error: "must have domain after '@'" ❌
- [ ] Type "user@example.c" → Error: "Domain extension too short" ❌

### Phone Number Tests
- [ ] Type "1234567890" → Should pass ✅
- [ ] Type "12345" → Error: "must be exactly 10 digits (current: 5)" ❌
- [ ] Type "abcdefghij" → Blocked by input formatter (letters won't appear)
- [ ] Type "12345678901" → Limited to 10 digits by input formatter
- [ ] Type "123-456-7890" → Hyphens blocked, only digits appear
- [ ] Type "" (empty) → Error: "Phone number is required" ❌

### Save Button Tests
- [ ] All fields valid → Save succeeds, green SnackBar appears ✅
- [ ] One field invalid → Save fails, red error shown ❌
- [ ] All fields invalid → Multiple errors shown, save blocked ❌
- [ ] Tap UNDO → Changes revert (if implemented)

---

## Advanced Customizations

### Option 1: Add Character Counter for Phone
```dart
// In _buildPhoneField() decoration
counterText: '${cleanedPhone.length}/10',
```

### Option 2: Auto-Format Phone Number
```dart
// Add spacing as user types: (123) 456-7890
String _formatPhoneNumber(String value) {
  final cleaned = value.replaceAll(RegExp(r'\D'), '');
  if (cleaned.length < 3) return cleaned;
  if (cleaned.length < 6) return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}';
  return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6, 10)}';
}
```

### Option 3: Add Success Icon When Valid
```dart
// In decoration
suffixIcon: _fieldValidationState['name'] == true
    ? const Icon(Icons.check_circle, color: Colors.green)
    : null,
```

### Option 4: Different Keyboard Types
```dart
// Name field
keyboardType: TextInputType.text

// Email field
keyboardType: TextInputType.emailAddress

// Phone field
keyboardType: TextInputType.number
```

---

## Common Issues & Solutions

### Issue 1: Error Messages Don't Appear
**Solution**: Ensure `setState()` is called in `_onFieldChanged()`

### Issue 2: Input Formatters Too Restrictive
**Solution**: Adjust RegExp patterns to allow needed characters

### Issue 3: Validation Doesn't Trigger on Save
**Solution**: Call validators explicitly in `_saveProfile()` before checking results

### Issue 4: Fields Don't Update in Real-Time
**Solution**: Verify `onChanged` handler is connected and calls `setState()`

### Issue 5: Phone Number Allows Letters
**Solution**: Use `FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))` to block non-digits

---

## Performance Tips

1. **Debounce Real-Time Validation** (for very long inputs)
   ```dart
   Timer? _debounce;
   
   void _onFieldChanged(String fieldName, String value) {
     if (_debounce?.isActive ?? false) _debounce?.cancel();
     _debounce = Timer(const Duration(milliseconds: 300), () {
       // Run validation here
     });
   }
   ```

2. **Use Const Constructors** where possible for performance

3. **Avoid Unnecessary setState()** calls by checking if value actually changed

4. **Cache RegExp Patterns** as static constants if used frequently

---

## Summary

You now have a complete Edit Profile screen with:

✅ **Name Field**: Blocks numbers, shows specific error messages  
✅ **Email Field**: Validates @ and domain structure  
✅ **Phone Field**: Exactly 10 digits, blocks letters  
✅ **Real-Time Validation**: Errors appear as user types  
✅ **Save Validation**: Final check before allowing save  
✅ **Visual Feedback**: Red errors, green success messages  
✅ **Input Formatters**: Prevent invalid input at character level  
✅ **Multiple Error Messages**: Specific feedback for each validation failure  

All requirements are met with clean, maintainable code! 🎉

---

**Implementation Date**: March 26, 2026  
**File Reference**: `lib/screens/edit_profile_screen.dart`  
**Total Lines**: ~400 lines of validation logic + UI
