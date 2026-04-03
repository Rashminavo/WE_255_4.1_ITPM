# Quick Copy-Paste Validation Code Snippets

## 📋 Copy These Code Blocks Directly Into Your Project

---

## 1. State Variables (Add to your State class)

```dart
final _formKey = GlobalKey<FormState>();
bool _isEditing = false;

// Real-time validation state tracking
Map<String, bool> _fieldValidationState = {};
Map<String, String> _fieldErrorMessages = {};

// Text controllers
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

## 2. Name Validation Methods

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

---

## 3. Email Validation Methods

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

---

## 4. Phone Number Validation Methods

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

## 5. Real-Time Validation Handler

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

## 6. Save Function

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

## 7. Name Field Widget

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

---

## 8. Email Field Widget

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

---

## 9. Phone Number Field Widget

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

## 10. Edit/Save Button in AppBar

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
    // ... rest of your build method
  );
}
```

---

## 11. Save & Cancel Buttons

```dart
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
```

---

## 🎯 Usage Example in Build Method

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
              // Header
              Card(
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
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form Fields
              Card(
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
              
              // Buttons
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
                const SizedBox(height: 12),
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

## ✅ Complete Implementation Checklist

After copying all snippets above, verify:

- [ ] State variables added to class
- [ ] initState() and dispose() methods implemented
- [ ] All 3 validation methods copied (_validateName, _validateEmail, _validatePhone)
- [ ] All 3 error message methods copied (_getNameError, _getEmailError, _getPhoneError)
- [ ] Real-time handler _onFieldChanged() copied
- [ ] Save function _saveProfile() copied
- [ ] All 3 field widgets copied (_buildNameField, _buildEmailField, _buildPhoneField)
- [ ] Build method includes form structure
- [ ] Edit/Save button in AppBar
- [ ] Save and Cancel buttons at bottom
- [ ] Input formatters working (test by typing invalid characters)
- [ ] Error messages appear on invalid input
- [ ] Success message appears on valid save

---

**Quick Start**: Copy sections 1-11 into your Flutter project and customize colors/text as needed!
