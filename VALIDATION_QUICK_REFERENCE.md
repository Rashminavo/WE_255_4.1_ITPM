# Profile Validation Quick Reference

## 📋 Validation Rules Summary Table

| Field | Min Length | Max Length | Allowed Characters | Special Rules | Example Valid |
|-------|------------|------------|-------------------|---------------|---------------|
| **Full Name** | 2 | 50 | `a-z A-Z space` | • No numbers<br>• Proper capitalization<br>• Max 5 words<br>• No leading/trailing spaces | `Tharani Bandara` |
| **Student ID** | 9-13 | 13 | `A-Z 0-9` | • 2-4 letters + 7-9 digits<br>• Valid prefix required<br>• Digit sum must be even<br>• Case-insensitive | `IT23318748` |
| **Email** | N/A | 100 (local: 64, domain: 255) | Standard email chars | • Must have @ and .<br>• No double dots<br>• TLD 2-63 chars<br>• 6-layer validation | `user@example.com` |
| **Phone** | 9 digits | 12 digits | `0-9 + space -` | • Start with +94 or 0<br>• Max 12 digits<br>• No consecutive hyphens | `+94 77 123 4567` |
| **Faculty** | 5 | 100 | `a-z A-Z space . , ' -` | • Must contain keyword<br>• No start/end special chars<br>• No consecutive special chars | `Faculty of Computing` |

---

## ✅ Valid Prefixes for Student ID

```
IT  - Information Technology
EN  - Engineering
BS  - Business Studies
CM  - Computational Mathematics
SE  - Software Engineering
CS  - Computer Science
IS  - Information Systems
BM  - Business Management
EC  - Electronic Commerce
EE  - Electrical Engineering
```

---

## 🔑 Required Keywords for Faculty

Must contain at least ONE:
```
faculty      school       department   institute    college
computing    engineering  business     science      technology
management   arts         design       health       law        education
```

---

## ❌ Common Validation Errors & Solutions

### Student ID Errors
| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Format: 2-4 letters + 7-9 digits" | Wrong pattern | Use format: `XX1234567` |
| "Invalid prefix" | Letters not in valid list | Use: IT, EN, BS, CM, SE, CS, IS, BM, EC, EE |
| "Checksum verification failed" | Sum of digits is odd | Change last digit to make sum even |

### Email Errors
| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Email must contain '@' symbol" | Missing @ | Add @ between username and domain |
| "Email username too long" | > 64 chars before @ | Shorten username part |
| "Invalid top-level domain" | TLD < 2 or > 63 chars | Use valid TLD: .com, .org, .lk, etc. |

### Phone Errors
| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Phone must start with +94 or 0" | Wrong country code | Add +94 or replace 0 at start |
| "must have at least 9 digits" | Too short | Add more digits (need 9-12 total) |
| "cannot contain consecutive hyphens" | Has `--` | Remove extra hyphen |

### Name Errors
| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Name must be at least 2 characters" | Single character | Add more letters |
| "Name cannot exceed 50 characters" | Too long | Shorten name |
| "Invalid name format" | Wrong capitalization | Capitalize first letter of each word |

### Faculty Errors
| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Faculty name too short" | < 5 characters | Add more text (min 5 chars) |
| "Invalid characters in faculty name" | Contains numbers/symbols | Remove invalid characters |
| "Must contain faculty/school/..." | Missing keyword | Add: faculty, school, department, etc. |

---

## 🔧 Technical Implementation

### Validation Methods Location
**File**: `lib/screens/profile_screen.dart`

| Method Name | Line Range | Purpose |
|-------------|-----------|---------|
| `_validateName()` | ~283-307 | Name validation with capitalization |
| `_validateStudentId()` | ~153-177 | Student ID with checksum |
| `_validateEmailComplex()` | ~310-348 | 6-layer email validation |
| `_validatePhoneComplex()` | ~351-371 | Phone format validation |
| `_validateFaculty()` | ~180-215 | Faculty keyword matching |
| `_getStudentIdError()` | ~247-263 | Student ID error messages |
| `_getFacultyError()` | ~266-280 | Faculty error messages |
| `_onFieldChanged()` | ~218-244 | Real-time validation handler |

### Widget Builders
| Widget Method | Lines | Field Type |
|--------------|-------|------------|
| `_buildField()` | ~895-920 | Name, Student ID, Faculty |
| `_buildEmailField()` | ~922-979 | Email |
| `_buildPhoneField()` | ~981-1055 | Phone |

---

## 🎯 Testing Checklist

### Before Save (Edit Mode)
- [ ] All fields filled
- [ ] No red error messages visible
- [ ] Green success SnackBar appears
- [ ] Edit mode exits automatically
- [ ] Profile data updates

### During Typing (Real-Time)
- [ ] Errors appear immediately
- [ ] Errors disappear when fixed
- [ ] Input formatters block invalid chars
- [ ] Character limits enforced

### Edge Cases to Test
- [ ] Empty fields → Should show error
- [ ] Minimum length (exactly at limit) → Should pass
- [ ] Maximum length (exactly at limit) → Should pass
- [ ] One character over limit → Should fail
- [ ] Special characters in wrong places → Should fail
- [ ] Valid edge cases → Should pass

---

## 📱 User Flow Diagram

```
┌─────────────────┐
│ View Profile    │
│ (Read-only)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Tap Edit Button │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Fields Become   │
│ Editable        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ User Types      │◄───────┐
│ in Field        │         │
└────────┬────────┘         │
         │                  │
         ▼                  │
┌─────────────────┐         │
│ Real-time       │         │
│ Validation Runs │         │
└────────┬────────┘         │
         │                  │
    ┌────┴────┐            │
    │         │            │
    ▼         ▼            │
┌───────┐ ┌────────┐      │
│ Valid │ │Invalid │──────┘
└───┬───┘ └────────┘
    │              Show error
    │              message
    ▼
┌─────────────────┐
│ Tap Save Button │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Final Validation│
│ (All fields)    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌──────────┐
│ Pass  │ │  Fail    │
└───┬───┘ └────┬─────┘
    │          │
    ▼          ▼
┌────────┐ ┌───────────┐
│ Update │ │Show Error │
│ Profile│ │SnackBar   │
└────┬───┘ └───────────┘
     │
     ▼
┌─────────────────┐
│ Success Message │
│ Exit Edit Mode  │
└─────────────────┘
```

---

## 💡 Pro Tips

### For Users
1. **Take your time** - Real-time validation helps you fix errors immediately
2. **Read error messages** - They tell you exactly what's wrong
3. **Use proper format** - Follow examples shown in placeholders
4. **Check before saving** - Ensure no red error messages remain

### For Developers
1. **Validation state maps** - Track field validity in real-time
2. **Specific error messages** - Help users understand what went wrong
3. **Input formatters first** - Prevent invalid input at character level
4. **Multi-layer validation** - Combine simple checks with complex business logic
5. **User-friendly feedback** - Show current digit counts, examples, etc.

---

## 🔍 Debug Mode Tips

To see validation in action during development:
```dart
// Add debug prints in validation methods
print('Validating email: $email');  // In _validateEmailComplex
print('Digit sum: $digitSum');       // In _validateStudentId
print('Faculty keywords found: $hasKeyword');  // In _validateFaculty
```

---

**Last Updated**: March 26, 2026  
**Version**: 1.0  
**Maintained By**: Development Team
