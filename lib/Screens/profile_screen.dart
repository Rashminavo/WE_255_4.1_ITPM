import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLocationEnabled = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Image handling for both platforms
  dynamic _profileImage; // File for mobile, Uint8List for web
  Uint8List? _webImageBytes;
  File? _mobileImageFile;

  final ImagePicker _imagePicker = ImagePicker();

  // Real-time validation state
  Map<String, String> _fieldErrors = {
    'name': '',
    'email': '',
    'phone': '',
  };

  // User data - will be initialized from provider
  late String _fullName;
  late String _studentId;
  late String _email;
  late String _faculty;
  late String _phone;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _idController;
  late final TextEditingController _facultyController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    // Load anonymous mode from Firestore
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadAnonymousMode();

    // Initialize with data from provider
    _fullName = userProvider.fullName;
    _studentId = userProvider.studentId;
    _email = userProvider.email;
    _faculty = userProvider.faculty;
    _phone = userProvider.phone;

    if (kIsWeb) {
      _webImageBytes = userProvider.webImageBytes;
      _profileImage = _webImageBytes;
    } else {
      _mobileImageFile = userProvider.mobileImageFile;
      _profileImage = _mobileImageFile;
    }

    _nameController = TextEditingController(text: _fullName);
    _emailController = TextEditingController(text: _email);
    _idController = TextEditingController(text: _studentId);
    _facultyController = TextEditingController(text: _faculty);
    _phoneController = TextEditingController(text: _phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _facultyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Perform final validation before saving
    bool isValid = true;

    // Validate name
    String nameError = _validateName(_nameController.text);
    if (nameError.isNotEmpty) {
      setState(() {
        _fieldErrors['name'] = nameError;
      });
      isValid = false;
    }

    // Validate email
    String emailError = _validateEmail(_emailController.text);
    if (emailError.isNotEmpty) {
      setState(() {
        _fieldErrors['email'] = emailError;
      });
      isValid = false;
    }

    // Validate phone
    String phoneError = _validatePhone(_phoneController.text);
    if (phoneError.isNotEmpty) {
      setState(() {
        _fieldErrors['phone'] = phoneError;
      });
      isValid = false;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isSaving = true;
    });

    // Simulate network/database save operation
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Update user data in provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      studentId: _idController.text.trim(),
      faculty: _facultyController.text.trim(),
      profileImage: kIsWeb ? _webImageBytes : _mobileImageFile,
    );

    // Update local variables
    setState(() {
      _fullName = _nameController.text.trim();
      _email = _emailController.text.trim();
      _studentId = _idController.text.trim();
      _faculty = _facultyController.text.trim();
      _phone = _phoneController.text.trim();
      _isEditing = false;
      _isSaving = false;
      _fieldErrors = {'name': '', 'email': '', 'phone': ''};
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Name Validation - No numbers allowed
  String _validateName(String name) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }
    if (name.trim().isEmpty) {
      return 'Name cannot be only spaces';
    }
    if (RegExp(r'[0-9]').hasMatch(name)) {
      return 'Numbers are not allowed in the name field';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return '';
  }

  // Email Validation
  String _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }

    final trimmedEmail = email.trim();

    if (!trimmedEmail.contains('@')) {
      return 'Please enter a valid email address (must contain @)';
    }

    final atIndex = trimmedEmail.lastIndexOf('@');
    if (atIndex == trimmedEmail.length - 1) {
      return 'Please enter a valid email address (missing domain)';
    }

    final domainPart = trimmedEmail.substring(atIndex + 1);
    if (!domainPart.contains('.')) {
      return 'Please enter a valid email address (missing domain extension like .com)';
    }

    final dotIndex = domainPart.lastIndexOf('.');
    if (dotIndex == domainPart.length - 1) {
      return 'Please enter a valid email address (domain extension cannot be empty)';
    }

    final extension = domainPart.substring(dotIndex + 1);
    if (extension.length < 2) {
      return 'Please enter a valid email address (domain extension too short)';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    return '';
  }

  // Phone Validation
  String _validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Phone number cannot be empty';
    }

    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (RegExp(r'[a-zA-Z]').hasMatch(phone)) {
      return 'Phone number must contain no letters';
    }

    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits (current: ${digitsOnly.length} digits)';
    }

    return '';
  }

  void _onFieldChanged(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'name':
          _fieldErrors['name'] = _validateName(value);
          break;
        case 'email':
          _fieldErrors['email'] = _validateEmail(value);
          break;
        case 'phone':
          _fieldErrors['phone'] = _validatePhone(value);
          break;
      }
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF1D9E75)),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1D9E75)),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFE24B4A)),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (kIsWeb) {
                      _webImageBytes = null;
                      _profileImage = null;
                    } else {
                      _mobileImageFile = null;
                      _profileImage = null;
                    }
                  });
                  // Update provider
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  userProvider.updateProfileImage(null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo removed'),
                      backgroundColor: Color(0xFF1D9E75),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web platform - read as bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _profileImage = bytes;
          });
          // Update provider
          if (mounted) {
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            userProvider.updateProfileImage(bytes);
          }
        } else {
          // Mobile platform - use File
          final imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            setState(() {
              _mobileImageFile = imageFile;
              _profileImage = imageFile;
            });
            // Update provider
            if (mounted) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.updateProfileImage(imageFile);
            }
          } else {
            throw Exception('File does not exist');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated!'),
              backgroundColor: Color(0xFF1D9E75),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Emergency Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Relation",
                prefixIcon: const Icon(Icons.people),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Contact added successfully!"),
                  backgroundColor: Color(0xFF1D9E75),
                ),
              );
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top green header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D9E75),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    // Back button + title row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const Spacer(),
                        const Text("My Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        // Edit button
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = !_isEditing),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_isEditing ? Icons.close : Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar with image picker - Cross-platform support
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: _getImageProvider(),
                          child: _profileImage == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Color(0xFF1D9E75))
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F6E56),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_studentId,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General Information
                      const Text("General information",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildNameField(),
                              const Divider(),
                              _buildEmailField(),
                              const Divider(),
                              _buildField("Student ID", _idController,
                                  Icons.badge_outlined, false),
                              const Divider(),
                              _buildField("Faculty", _facultyController,
                                  Icons.school_outlined, false),
                              const Divider(),
                              _buildPhoneField(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Safety Score
                      const Text("Safety Score",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1D9E75),
                                          Color(0xFF0F6E56)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1D9E75)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${Provider.of<UserProvider>(context).safetyScore}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Excellent!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1D9E75),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "You're among the top 15% of safe students on campus",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: Provider.of<UserProvider>(context)
                                          .safetyScore /
                                      100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF1D9E75)),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Achievements
                      const Text("Achievements",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: Provider.of<UserProvider>(context)
                                .achievements
                                .map((achievement) {
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(achievement["color"])
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    achievement["icon"] as IconData,
                                    color: Color(achievement["color"]),
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  achievement["title"] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  achievement["desc"] as String,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: const Icon(Icons.check_circle,
                                    color: Color(0xFF4CAF50), size: 20),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Emergency Contacts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Emergency Contacts",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)),
                          if (_isEditing)
                            TextButton.icon(
                              onPressed: _showAddContactDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Add"),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1D9E75),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: Provider.of<UserProvider>(context)
                                .emergencyContacts
                                .map((contact) {
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE24B4A)
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.contact_phone,
                                    color: Color(0xFFE24B4A),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  contact["name"] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  "${contact["relation"]} â€¢ ${contact["phone"]}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.phone,
                                      color: Color(0xFF1D9E75)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Calling ${contact["name"]}..."),
                                        backgroundColor:
                                            const Color(0xFF1D9E75),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Safety & Privacy
                      const Text("Safety & privacy settings",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor)),
                        child: Column(
                          children: [
                            SwitchListTile(
                              activeThumbColor: const Color(0xFF1D9E75),
                              title: const Text("Live location sharing",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: const Text(
                                  "Share location with university security during alerts",
                                  style: TextStyle(fontSize: 12)),
                              value: _isLocationEnabled,
                              onChanged: (val) =>
                                  setState(() => _isLocationEnabled = val),
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return SwitchListTile(
                                  activeThumbColor: const Color(0xFF1D9E75),
                                  title: const Text("Dark mode",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  subtitle: const Text(
                                      "Switch between light and dark theme",
                                      style: TextStyle(fontSize: 12)),
                                  value: themeProvider.isDarkMode,
                                  onChanged: (val) =>
                                      themeProvider.setDarkMode(val),
                                );
                              },
                            ),
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                return SwitchListTile(
                                  activeThumbColor: const Color(0xFF1D9E75),
                                  title: const Text("Anonymous mode",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  subtitle: const Text(
                                      "Hide personal details in public community forums",
                                      style: TextStyle(fontSize: 12)),
                                  value: userProvider.isAnonymousMode,
                                  onChanged: (val) =>
                                      userProvider.toggleAnonymousMode(val),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D9E75),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isSaving ? null : _saveProfile,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    "Save changes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                      if (_isEditing) const SizedBox(height: 12),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE24B4A), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout,
                              color: Color(0xFFE24B4A)),
                          label: const Text("Log out",
                              style: TextStyle(
                                  color: Color(0xFFE24B4A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text("Log out"),
                                content: const Text(
                                    "Are you sure you want to log out?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE24B4A),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RagaSafeApp()),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text("Log out",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the appropriate image provider based on platform
  ImageProvider? _getImageProvider() {
    if (_profileImage == null) return null;

    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    } else if (!kIsWeb && _mobileImageFile != null) {
      return FileImage(_mobileImageFile!);
    }
    return null;
  }

  // Name Field
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          readOnly: !_isEditing,
          onChanged: _isEditing ? (val) => _onFieldChanged('name', val) : null,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
            LengthLimitingTextInputFormatter(50),
          ],
          decoration: InputDecoration(
            labelText: "Full name",
            prefixIcon: const Icon(Icons.person_outline,
                color: Color(0xFF1D9E75), size: 20),
            border: InputBorder.none,
            labelStyle: const TextStyle(fontSize: 13),
            errorText: _isEditing && _fieldErrors['name']!.isNotEmpty
                ? _fieldErrors['name']
                : null,
            errorStyle: const TextStyle(fontSize: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Email Field
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          readOnly: !_isEditing,
          onChanged: _isEditing ? (val) => _onFieldChanged('email', val) : null,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          decoration: InputDecoration(
            labelText: "Email address",
            prefixIcon: const Icon(Icons.email_outlined,
                color: Color(0xFF1D9E75), size: 20),
            border: InputBorder.none,
            labelStyle: const TextStyle(fontSize: 13),
            errorText: _isEditing && _fieldErrors['email']!.isNotEmpty
                ? _fieldErrors['email']
                : null,
            errorStyle: const TextStyle(fontSize: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Phone Field
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          readOnly: !_isEditing,
          onChanged: _isEditing ? (val) => _onFieldChanged('phone', val) : null,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: "Phone number",
            prefixIcon: const Icon(Icons.phone_outlined,
                color: Color(0xFF1D9E75), size: 20),
            border: InputBorder.none,
            labelStyle: const TextStyle(fontSize: 13),
            hintText: '1234567890',
            errorText: _isEditing && _fieldErrors['phone']!.isNotEmpty
                ? _fieldErrors['phone']
                : null,
            errorStyle: const TextStyle(fontSize: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Generic field builder
  Widget _buildField(String label, TextEditingController controller,
      IconData icon, bool isEditing) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1D9E75), size: 20),
        border: InputBorder.none,
        labelStyle: const TextStyle(fontSize: 13),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}
