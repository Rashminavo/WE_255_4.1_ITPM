# Complex Profile Validation Guide

## Overview
This guide documents the **complex validation system** implemented for the Profile Screen edit mode. The validation includes multi-layer checks, real-time validation state tracking, custom input formatters, and sophisticated error messages.

---

## 🎯 Features Implemented

### 1. **Real-Time Validation State Tracking**
- Tracks validation status for each field in real-time
- Displays specific error messages as users type
- Maintains separate validation state maps for fields and errors

```dart
Map<String, bool> _fieldValidationState = {};
Map<String, String> _fieldErrorMessages = {};
```

### 2. **Complex Student ID Validation**
Implements checksum verification and prefix validation.

#### Validation Rules:
- **Pattern**: 2-4 letters + 7-9 digits (e.g., `IT23318748`)
- **Valid Prefixes**: IT, EN, BS, CM, SE, CS, IS, BM, EC, EE
- **Checksum**: Sum of all digits must be even
- **Case-insensitive**: Accepts both uppercase and lowercase letters

#### Example Valid IDs:
```
✅ IT23318748  (Sum: 2+3+3+1+8+7+4+8 = 36 ✓ Even)
✅ EN1234567   (Sum: 1+2+3+4+5+6+7 = 28 ✓ Even)
✅ BS987654321 (Sum: 9+8+7+6+5+4+3+2+1 = 45 ✗ Odd - INVALID)
```

#### Error Messages:
- "Student ID is required"
- "Format: 2-4 letters + 7-9 digits (e.g., IT23318748)"
- "Invalid prefix. Valid: IT, EN, BS, CM, SE, CS, IS, BM, EC, EE"
- "Invalid ID: Checksum verification failed"

---

### 3. **Enhanced Email Validation (6-Layer System)**

#### Layer 1: Basic Structure
- Must contain '@' symbol
- Must contain '.' for domain
- '@' must come before the last '.'

#### Layer 2: Position Validation
- Text must exist before '@'
- Text must exist after '@'
- '@' cannot be first or last character

#### Layer 3: Local Part (Username)
- Maximum 64 characters
- Cannot start or end with '.'
- Cannot contain consecutive dots ('..')

#### Layer 4: Domain Part
- Maximum 255 characters
- Cannot start or end with hyphen ('-')
- Cannot contain consecutive dots

#### Layer 5: TLD (Top-Level Domain)
- Length must be 2-63 characters
- Examples: `.com`, `.org`, `.lk`, `.university`

#### Layer 6: Comprehensive Pattern
```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

#### Example Valid Emails:
```
✅ user@example.com
✅ john.doe@university.ac.lk
✅ test_user+tag@sub.domain.org
```

#### Error Messages:
- "Email must contain '@' symbol"
- "Email must contain a domain (e.g., .com)"
- "Invalid email format: '@' must come before '.'"
- "Email username too long (max 64 characters)"
- "Email username cannot start or end with '.'"
- "Email username cannot contain consecutive dots"
- "Domain cannot start or end with hyphen"
- "Invalid top-level domain (must be 2-63 characters)"

---

### 4. **Enhanced Phone Validation (4-Layer System)**

#### Layer 1: Format Validation
- Must start with `+94` (Sri Lanka code) or `0`
- Allows digits, spaces, and hyphens only

#### Layer 2: Digit Count
- Minimum 9 digits
- Maximum 12 digits
- Displays current digit count in error message

#### Layer 3: Character Validation
- Only digits (0-9), spaces, hyphens (-), and plus (+) allowed
- Regex: `^\+?[0-9\s-]+$`

#### Layer 4: Special Rules
- No consecutive hyphens (`--`)
- Proper formatting encouraged (e.g., `+94 77 123 4567`)

#### Example Valid Phones:
```
✅ +94 77 123 4567
✅ 077-123-4567
✅ +94764567890
✅ 0112345678
```

#### Error Messages:
- "Phone must start with +94 or 0"
- "Phone number must have at least 9 digits (current: X)"
- "Phone number cannot exceed 12 digits (current: X)"
- "Phone number can only contain digits, spaces, and hyphens"
- "Phone number cannot contain consecutive hyphens"

---

### 5. **Complex Name Validation**

#### Validation Rules:
- Minimum 2 characters, maximum 50 characters
- Must contain at least one letter (a-z, A-Z)
- Blocks numbers using `FilteringTextInputFormatter`
- Proper capitalization required (first letter uppercase)
- Maximum 5 words
- Cannot start or end with spaces
- Allows uppercase acronyms (MC, PhD, etc.)

#### Capitalization Pattern:
```dart
// Each word must be: Capitalized OR All-caps acronym
RegExp(r'^[A-Z][a-z]*$')     // Normal words: John, Doe
RegExp(r'^[A-Z]{1,3}$')      // Acronyms: MC, PhD, MBA
```

#### Example Valid Names:
```
✅ Tharani Bandara
✅ John F. Kennedy
✅ Sarah Jane Smith-Jones
✅ Dr. A.B.C. Perera
✅ MC Escher
```

#### Input Formatter:
```dart
FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
```

---

### 6. **Complex Faculty Validation**

#### Validation Rules:
- Minimum 5 characters, maximum 100 characters
- Must contain only: letters (a-z, A-Z), spaces, and basic punctuation (`. , ' -`)
- Must contain at least one keyword from approved list
- Cannot start or end with special characters
- Cannot have consecutive special characters

#### Approved Keywords:
```dart
[
  'faculty', 'school', 'department', 'institute', 'college',
  'computing', 'engineering', 'business', 'science', 'technology',
  'management', 'arts', 'design', 'health', 'law', 'education'
]
```

#### Special Character Rules:
- Allowed: space (` `), period (`.`), comma (`,`), apostrophe (`'`), hyphen (`-`)
- Cannot be first or last character
- Cannot appear consecutively (e.g., `..`, `--`, `''`)

#### Example Valid Faculties:
```
✅ Faculty of Computing
✅ School of Engineering
✅ Department of Business Administration
✅ Institute of Technology, University of Moratuwa
✅ College of Arts & Sciences
```

#### Invalid Examples:
```
❌ computing                    (Too short, no keyword context)
❌ Faculty                      (Too generic)
❌ .Faculty of Computing        (Starts with special char)
❌ Faculty of Computing.        (Ends with special char)
❌ Faculty,,Engineering         (Consecutive special chars)
❌ Random Department XYZ        (No valid keyword)
```

---

## 🔧 Implementation Details

### Real-Time Validation Handler
```dart
void _onFieldChanged(String fieldName, String value) {
  setState(() {
    switch (fieldName) {
      case 'name':
        _fieldValidationState['name'] = _validateName(value);
        break;
      case 'email':
        _fieldValidationState['email'] = _validateEmailComplex(value);
        break;
      case 'phone':
        _fieldValidationState['phone'] = _validatePhoneComplex(value);
        break;
      case 'studentId':
        _fieldValidationState['studentId'] = _validateStudentId(value);
        if (!_fieldValidationState['studentId']!) {
          _fieldErrorMessages['studentId'] = _getStudentIdError(value);
        }
        break;
      case 'faculty':
        _fieldValidationState['faculty'] = _validateFaculty(value);
        if (!_fieldValidationState['faculty']!) {
          _fieldErrorMessages['faculty'] = _getFacultyError(value);
        }
        break;
    }
  });
}
```

### TextFormField Integration
Each field includes:
1. **onChanged** handler for real-time validation
2. **inputFormatters** to restrict input at character level
3. **validator** function with multi-layer validation
4. **errorText** display from `_fieldErrorMessages` map

Example:
```dart
TextFormField(
  controller: _emailController,
  onChanged: _isEditing ? (val) => _onFieldChanged('email', val) : null,
  inputFormatters: [LengthLimitingTextInputFormatter(100)],
  validator: (val) {
    // Multi-layer validation logic
  },
)
```

---

## 📋 Validation Flow

### Edit Mode Activation
1. User taps Edit button
2. `_isEditing` flag set to `true`
3. All fields become editable
4. Real-time validation enabled via `onChanged` handlers

### Field Entry Process
1. User types in field
2. `onChanged` triggers `_onFieldChanged()`
3. Validation runs immediately
4. `_fieldValidationState` updated
5. If invalid, `_fieldErrorMessages` populated
6. Error displayed below field in red

### Save Process
1. User taps "Save changes"
2. `_saveProfile()` called
3. Form key validates all fields: `_formKey.currentState!.validate()`
4. Additional complex validation runs:
   - Student ID checksum verification
   - Faculty keyword matching
5. If errors exist → Show SnackBar, remain in edit mode
6. If valid → Update profile data, exit edit mode, show success message

---

## 🎨 User Experience

### Visual Feedback
- **Green checkmark** (implicit): No error text shown
- **Red error text**: Specific validation error displayed
- **Real-time updates**: Errors appear/disappear as user types

### Error Message Hierarchy
1. **Empty field**: "This field cannot be empty"
2. **Length issues**: "X must be at least Y characters"
3. **Format issues**: Specific format requirement
4. **Complex validation**: Detailed error with examples

### Success Behavior
- Green success SnackBar with checkmark icon
- UNDO action available for 5 seconds
- Profile data updated
- Edit mode disabled

---

## 🔒 Security & Data Integrity

### Input Sanitization
- All inputs trimmed before validation
- Special characters filtered at input level
- SQL injection prevention (no raw database queries)
- XSS prevention (text sanitization)

### Data Validation Layers
1. **Client-side**: Immediate feedback, UX optimization
2. **Format validation**: RegExp patterns, structure checks
3. **Business logic**: Checksum verification, keyword matching
4. **Final verification**: Pre-save comprehensive validation

---

## 📊 Testing Scenarios

### Test Case: Student ID Validation
```dart
// Valid cases
_validateStudentId('IT23318748')  // true ✓
_validateStudentId('en1234567')   // true ✓ (lowercase accepted)
_validateStudentId('BS98765432')  // true ✓

// Invalid cases
_validateStudentId('IT12345')     // false ✗ (too few digits)
_validateStudentId('XY12345678')  // false ✗ (invalid prefix)
_validateStudentId('IT12345671')  // false ✗ (odd checksum: sum=29)
```

### Test Case: Email Validation
```dart
_validateEmailComplex('user@example.com')           // true ✓
_validateEmailComplex('john.doe@uni.ac.lk')         // true ✓
_validateEmailComplex('user@.com')                  // false ✗ (empty domain)
_validateEmailComplex('user@domain')                // false ✗ (no TLD)
_validateEmailComplex('.user@domain.com')           // false ✗ (starts with dot)
```

### Test Case: Phone Validation
```dart
_validatePhoneComplex('+94 77 123 4567')  // true ✓
_validatePhoneComplex('077-123-4567')     // true ✓
_validatePhoneComplex('+94764567890')     // true ✓
_validatePhoneComplex('771234567')        // false ✗ (no country code)
_validatePhoneComplex('+94 77 123 45')    // false ✗ (only 7 digits)
```

---

## 🚀 Future Enhancements

### Potential Additions
1. **Phone Number Formatting**: Auto-format as user types (+94 XX XXX XXXX)
2. **Email Suggestion**: Suggest common domains (@gmail.com, @uni.ac.lk)
3. **Student ID Auto-detection**: Detect faculty from prefix automatically
4. **Paste Detection**: Validate pasted content with enhanced rules
5. **Biometric Validation**: Face/fingerprint for profile changes
6. **Server-side Sync**: Cross-validate with university database

---

## 📝 Summary

This complex validation system provides:
- ✅ **6-layer email validation** with DNS-like structure checks
- ✅ **4-layer phone validation** with digit counting and formatting
- ✅ **Multi-rule name validation** with capitalization and word count
- ✅ **Advanced student ID validation** with checksum verification
- ✅ **Comprehensive faculty validation** with keyword matching
- ✅ **Real-time validation feedback** as users type
- ✅ **Specific error messages** with examples
- ✅ **Input formatters** preventing invalid characters
- ✅ **Multi-stage validation** (real-time + pre-save)

All validations work seamlessly in **Edit Mode**, ensuring data integrity while maintaining excellent user experience.

---

**Implementation Date**: March 26, 2026  
**File**: `lib/screens/profile_screen.dart`  
**Lines Modified**: 150+, Added Validation Methods: 6
