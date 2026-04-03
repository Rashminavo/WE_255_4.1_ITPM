import 'package:flutter/material.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLocationEnabled = true;
  bool _isAnonymousMode = false;
  bool _isEditing = false;

  // User data - centralized for consistency
  String _fullName = "Tharani Bandara";
  String _studentId = "IT23318748";
  String _email = "tharani@gmail.com";
  String _faculty = "Faculty of Computing";
  String _phone = "+94 77 123 4567";

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _idController;
  late final TextEditingController _facultyController;
  late final TextEditingController _phoneController;

  // Safety score and achievements
  final int _safetyScore = 85;
  final List<Map<String, dynamic>> _achievements = [
    {
      "icon": Icons.shield,
      "title": "Safety Champion",
      "desc": "7 days incident-free",
      "color": 0xFF4CAF50
    },
    {
      "icon": Icons.people,
      "title": "Buddy Helper",
      "desc": "Helped 5 students",
      "color": 0xFF2196F3
    },
    {
      "icon": Icons.star,
      "title": "Active Reporter",
      "desc": "Submitted 3 reports",
      "color": 0xFFFF9800
    },
  ];

  // Emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    {"name": "Father", "phone": "+94 77 987 6543", "relation": "Parent"},
    {"name": "Kavindu", "phone": "+94 76 456 7890", "relation": "Buddy"},
  ];

  @override
  void initState() {
    super.initState();
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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _fullName = _nameController.text.trim();
        _email = _emailController.text.trim();
        _studentId = _idController.text.trim();
        _faculty = _facultyController.text.trim();
        _phone = _phoneController.text.trim();
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Color(0xFF1D9E75),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: const Color(0xFFF8FAF8),
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

                    // Avatar
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 60, color: Color(0xFF1D9E75)),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildField("Full name", _nameController,
                                  Icons.person_outline),
                              const Divider(),
                              _buildEmailField(),
                              const Divider(),
                              _buildField("Student ID", _idController,
                                  Icons.badge_outlined),
                              const Divider(),
                              _buildField("Faculty", _facultyController,
                                  Icons.school_outlined),
                              const Divider(),
                              _buildPhoneField(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Safety Score - NEW FEATURE
                      const Text("Safety Score",
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
                                        "$_safetyScore",
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
                                  value: _safetyScore / 100,
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

                      // Achievements - NEW FEATURE
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
                            children: _achievements.map((achievement) {
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

                      // Emergency Contacts - NEW FEATURE
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: _emergencyContacts.map((contact) {
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
                                  "${contact["relation"]} • ${contact["phone"]}",
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200)),
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
                            SwitchListTile(
                              activeThumbColor: const Color(0xFF1D9E75),
                              title: const Text("Anonymous mode",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: const Text(
                                  "Hide personal details in public community forums",
                                  style: TextStyle(fontSize: 12)),
                              value: _isAnonymousMode,
                              onChanged: (val) =>
                                  setState(() => _isAnonymousMode = val),
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
                            onPressed: _isEditing ? _saveProfile : null,
                            child: const Text("Save changes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
                                                const MyApp()),
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

  Widget _buildField(
      String label, TextEditingController controller, IconData icon) {
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
      validator: (val) =>
          (val == null || val.isEmpty) ? "This field cannot be empty" : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      readOnly: !_isEditing,
      decoration: const InputDecoration(
        labelText: "Email address",
        prefixIcon:
            Icon(Icons.email_outlined, color: Color(0xFF1D9E75), size: 20),
        border: InputBorder.none,
        labelStyle: TextStyle(fontSize: 13),
      ),
      style: const TextStyle(fontSize: 14),
      validator: (val) {
        if (val == null || val.isEmpty) return "Please enter your email";
        final valid = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);
        if (!valid) return "Enter a valid email address";
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      readOnly: !_isEditing,
      decoration: const InputDecoration(
        labelText: "Phone number",
        prefixIcon:
            Icon(Icons.phone_outlined, color: Color(0xFF1D9E75), size: 20),
        border: InputBorder.none,
        labelStyle: TextStyle(fontSize: 13),
      ),
      style: const TextStyle(fontSize: 14),
      keyboardType: TextInputType.phone,
      validator: (val) {
        if (val == null || val.isEmpty) return "Please enter your phone number";
        return null;
      },
    );
  }
}
