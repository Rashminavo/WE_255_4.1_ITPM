# RagSafe SL - Admin/User System Architecture Plan

## Executive Summary

This document outlines the architecture for implementing a role-based access control system in RagSafe SL, separating student users from administrators, with report tracking and status management capabilities.

---

## Current System Analysis

### What's Already Implemented ✅
1. **Report Model** ([`lib/models/report_model.dart`](../lib/models/report_model.dart))
   - Report types: Verbal, Physical, Sexual, Cyber, Other
   - Report statuses: Submitted, Pending, Investigating, Resolved, Closed
   - Firestore integration with document ID as unique report ID
   - Media URL support (now using Cloudinary)

2. **Anonymous Reporting** ([`lib/features/reporting/report_screen.dart`](../lib/features/reporting/report_screen.dart))
   - Form submission with type, description, media, location
   - Cloudinary media upload
   - Firestore storage with auto-generated document ID
   - Success message shows Report ID to user

3. **Basic Authentication** ([`lib/Screens/login_screen.dart`](../lib/Screens/login_screen.dart), [`lib/Screens/register_screen.dart`](../lib/Screens/register_screen.dart))
   - Login/Register screens exist but are NOT connected to Firebase Auth
   - Currently just simulated delays with no real authentication
   - No role differentiation

### What's Missing ❌
1. **No Firebase Authentication integration**
2. **No user role system (Student vs Admin)**
3. **No university email validation**
4. **No admin dashboard**
5. **No report status tracking for users**
6. **No report management interface for admins**
7. **No security rules for role-based access**

---

## System Architecture Design

### 1. User Role System

#### User Types
```
┌─────────────────────────────────────────┐
│           User Roles                    │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   STUDENT    │    │    ADMIN     │  │
│  │              │    │              │  │
│  │ - Submit     │    │ - View all   │  │
│  │   reports    │    │   reports    │  │
│  │ - Track own  │    │ - Update     │  │
│  │   reports    │    │   status     │  │
│  │ - View SOS   │    │ - Add notes  │  │
│  │ - Education  │    │ - Analytics  │  │
│  └──────────────┘    └──────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

#### User Data Model
```dart
class UserProfile {
  String uid;              // Firebase Auth UID
  String email;            // University email
  String fullName;
  String studentId;        // For students only
  UserRole role;           // 'student' or 'admin'
  String university;       // e.g., "University of Colombo"
  DateTime createdAt;
  bool isEmailVerified;
  List<String> reportIds; // Track user's submitted reports
}

enum UserRole {
  student,
  admin
}
```

---

### 2. Authentication Flow

#### Student Registration Flow
```
┌─────────────────────────────────────────────────────────────┐
│                  Student Registration                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Enter Details:                  │
        │  - Full Name                     │
        │  - Student ID                    │
        │  - University Email              │
        │    (must end with .edu.lk or     │
        │     specific university domain)  │
        │  - Password                      │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Validate Email Domain           │
        │  - Check if university email     │
        │  - Reject personal emails        │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Create Firebase Auth Account    │
        │  - createUserWithEmailAndPassword│
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Send Email Verification         │
        │  - sendEmailVerification()       │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Create User Profile in Firestore│
        │  Collection: users/{uid}         │
        │  - role: 'student'               │
        │  - isEmailVerified: false        │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Show "Verify Email" Screen      │
        └──────────────────────────────────┘
```

#### Admin Registration Flow
```
┌─────────────────────────────────────────────────────────────┐
│                   Admin Registration                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Manual Admin Creation           │
        │  (By Super Admin or via          │
        │   Firebase Console)              │
        │                                  │
        │  - Create user account           │
        │  - Set role: 'admin' in          │
        │    Firestore users collection    │
        │  - Assign admin privileges       │
        └──────────────────────────────────┘
```

#### Login Flow
```
┌─────────────────────────────────────────────────────────────┐
│                      Login Flow                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Enter Email & Password          │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Firebase Auth Login             │
        │  - signInWithEmailAndPassword    │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Check Email Verification        │
        │  - If not verified, show warning │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Fetch User Profile from         │
        │  Firestore (users/{uid})         │
        └──────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Check User Role                 │
        └──────────────────────────────────┘
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
    ┌───────────────────┐  ┌───────────────────┐
    │  role == 'admin'  │  │ role == 'student' │
    │                   │  │                   │
    │  Navigate to      │  │  Navigate to      │
    │  Admin Dashboard  │  │  Student Home     │
    └───────────────────┘  └───────────────────┘
```

---

### 3. Report Tracking System

#### Report ID Generation
- **Current**: Firestore auto-generates document IDs (e.g., `abc123xyz`)
- **Enhancement**: Create human-readable IDs with prefix
  - Format: `RS-YYYY-XXXXXX` (e.g., `RS-2026-001234`)
  - RS = RagSafe
  - YYYY = Year
  - XXXXXX = Sequential number

#### Report Data Structure (Enhanced)
```dart
class Report {
  String id;                    // Firestore doc ID
  String displayId;             // Human-readable ID (RS-2026-001234)
  String userId;                // Submitter's Firebase Auth UID
  ReportType type;
  String description;
  String? mediaUrl;             // Cloudinary URL
  double? latitude;
  double? longitude;
  DateTime timestamp;
  ReportStatus status;
  String? adminNotes;           // Admin can add notes
  String? assignedAdminId;      // Which admin is handling this
  DateTime? lastUpdated;
  List<StatusUpdate> statusHistory; // Track all status changes
}

class StatusUpdate {
  ReportStatus status;
  String updatedBy;             // Admin UID
  DateTime timestamp;
  String? notes;
}
```

---

### 4. Firebase Firestore Data Structure

```
firestore/
│
├── users/                          # User profiles
│   ├── {uid}/
│   │   ├── email: string
│   │   ├── fullName: string
│   │   ├── studentId: string (optional)
│   │   ├── role: string ('student' | 'admin')
│   │   ├── university: string
│   │   ├── createdAt: timestamp
│   │   ├── isEmailVerified: boolean
│   │   └── reportIds: array<string>
│   │
│
├── reports/                        # All reports
│   ├── {reportId}/
│   │   ├── displayId: string (RS-2026-001234)
│   │   ├── userId: string (submitter UID)
│   │   ├── type: string
│   │   ├── description: string
│   │   ├── mediaUrl: string (Cloudinary)
│   │   ├── latitude: number
│   │   ├── longitude: number
│   │   ├── timestamp: timestamp
│   │   ├── status: string
│   │   ├── adminNotes: string
│   │   ├── assignedAdminId: string
│   │   ├── lastUpdated: timestamp
│   │   └── statusHistory: array<object>
│   │
│
├── reportCounter/                  # For generating sequential IDs
│   └── counter/
│       └── currentNumber: number
│
└── universities/                   # Allowed university domains
    ├── {universityId}/
    │   ├── name: string
    │   ├── emailDomain: string (@uoc.lk, @mrt.ac.lk)
    │   └── isActive: boolean
```

---

### 5. User Interface Design

#### Student Side

##### A. Report Submission (Already Exists - Enhance)
- Current: [`lib/features/reporting/report_screen.dart`](../lib/features/reporting/report_screen.dart)
- Enhancement: Link report to authenticated user's UID
- Save report ID to user's profile

##### B. My Reports Screen (NEW)
```
┌─────────────────────────────────────────┐
│         My Reports                      │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Report ID: RS-2026-001234         │  │
│  │ Type: Physical Ragging            │  │
│  │ Status: Under Investigation 🔍    │  │
│  │ Submitted: 2026-03-20             │  │
│  │ Last Updated: 2026-03-25          │  │
│  │                                   │  │
│  │ [View Details]                    │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Report ID: RS-2026-001189         │  │
│  │ Type: Verbal Ragging              │  │
│  │ Status: Resolved ✅               │  │
│  │ Submitted: 2026-03-15             │  │
│  │ Last Updated: 2026-03-22          │  │
│  │                                   │  │
│  │ [View Details]                    │  │
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

##### C. Track Report by ID Screen (NEW)
```
┌─────────────────────────────────────────┐
│      Track Report Status                │
├─────────────────────────────────────────┤
│                                         │
│  Enter Report ID:                       │
│  ┌─────────────────────────────────┐   │
│  │ RS-2026-001234                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Track Report]                         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Report Details:                        │
│  • Type: Physical Ragging               │
│  • Status: Under Investigation          │
│  • Submitted: March 20, 2026            │
│  • Last Updated: March 25, 2026         │
│                                         │
│  Status Timeline:                       │
│  ✅ Submitted - March 20, 2026          │
│  ✅ Received - March 20, 2026           │
│  🔵 Under Investigation - March 22      │
│  ⏳ Pending Resolution                  │
│                                         │
│  Admin Notes:                           │
│  "Investigation in progress. Witnesses  │
│   are being interviewed."               │
│                                         │
└─────────────────────────────────────────┘
```

#### Admin Side

##### A. Admin Dashboard (NEW)
```
┌─────────────────────────────────────────┐
│       Admin Dashboard                   │
├─────────────────────────────────────────┤
│                                         │
│  Statistics:                            │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│  │  45  │ │  12  │ │   8  │ │  25  │  │
│  │Total │ │ New  │ │Active│ │Closed│  │
│  └──────┘ └──────┘ └──────┘ └──────┘  │
│                                         │
│  Recent Reports:                        │
│  ┌───────────────────────────────────┐  │
│  │ 🔴 RS-2026-001234 | Physical      │  │
│  │    Status: New | 2 hours ago      │  │
│  │    [View] [Assign to me]          │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🟡 RS-2026-001233 | Cyber         │  │
│  │    Status: Investigating          │  │
│  │    Assigned to: Admin John        │  │
│  │    [View] [Update Status]         │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [View All Reports]                     │
│  [Analytics]                            │
│  [Settings]                             │
│                                         │
└─────────────────────────────────────────┘
```

##### B. Report Management Screen (NEW)
```
┌─────────────────────────────────────────┐
│      Report Details - RS-2026-001234    │
├─────────────────────────────────────────┤
│                                         │
│  Report Information:                    │
│  • Type: Physical Ragging               │
│  • Submitted: March 20, 2026 10:30 AM   │
│  • Submitter: Anonymous (Student)       │
│  • Location: Shared ✓                   │
│                                         │
│  Description:                           │
│  "I was physically assaulted by senior  │
│   students in the hostel..."            │
│                                         │
│  Evidence:                              │
│  [📷 View Photo] [📹 View Video]        │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Current Status: Under Investigation    │
│                                         │
│  Update Status:                         │
│  ┌─────────────────────────────────┐   │
│  │ [Dropdown: Select Status]       │   │
│  │ - Pending Review                │   │
│  │ - Under Investigation ✓         │   │
│  │ - Resolved                      │   │
│  │ - Closed                        │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Admin Notes:                           │
│  ┌─────────────────────────────────┐   │
│  │ Add notes visible to user...    │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Update Report] [Assign to Me]         │
│                                         │
│  Status History:                        │
│  • Submitted - March 20, 10:30 AM       │
│  • Received - March 20, 10:31 AM        │
│  • Under Investigation - March 22       │
│    by Admin Sarah                       │
│                                         │
└─────────────────────────────────────────┘
```

---

### 6. Security Rules (Firebase Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read their own profile
      allow read: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can create their own profile during registration
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can update their own profile (except role)
      allow update: if isAuthenticated() && 
                       request.auth.uid == userId &&
                       request.resource.data.role == resource.data.role;
      
      // Admins can read all user profiles
      allow read: if isAdmin();
      
      // Admins can update user roles
      allow update: if isAdmin();
    }
    
    // Reports collection
    match /reports/{reportId} {
      // Anyone authenticated can create a report
      allow create: if isAuthenticated();
      
      // Users can read their own reports
      allow read: if isAuthenticated() && 
                     resource.data.userId == request.auth.uid;
      
      // Admins can read all reports
      allow read: if isAdmin();
      
      // Only admins can update reports (status, notes, etc.)
      allow update: if isAdmin();
      
      // No one can delete reports
      allow delete: if false;
    }
    
    // Report counter (for generating sequential IDs)
    match /reportCounter/counter {
      // Only admins and the system can update
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    // Universities collection
    match /universities/{universityId} {
      // Anyone can read university list (for registration)
      allow read: if true;
      
      // Only admins can modify
      allow write: if isAdmin();
    }
  }
}
```

---

### 7. University Email Validation

#### Allowed Email Domains
```dart
class UniversityEmailValidator {
  static const List<String> allowedDomains = [
    '@uoc.lk',           // University of Colombo
    '@mrt.ac.lk',        // University of Moratuwa
    '@pdn.ac.lk',        // University of Peradeniya
    '@ruh.ac.lk',        // University of Ruhuna
    '@sjp.ac.lk',        // University of Sri Jayewardenepura
    '@kln.ac.lk',        // University of Kelaniya
    '@jfn.ac.lk',        // University of Jaffna
    '@esn.ac.lk',        // Eastern University
    '@sab.ac.lk',        // Sabaragamuwa University
    '@wyb.ac.lk',        // Wayamba University
    '@seu.ac.lk',        // South Eastern University
    '@rusl.ac.lk',       // Rajarata University
    '@vau.ac.lk',        // Vavuniya Campus
    // Add more as needed
  ];
  
  static bool isValidUniversityEmail(String email) {
    return allowedDomains.any((domain) => email.toLowerCase().endsWith(domain));
  }
  
  static String? getUniversityName(String email) {
    // Map email domain to university name
    // Return university name or null
  }
}
```

---

### 8. Implementation Phases

#### Phase 1: Authentication & User Management
1. Integrate Firebase Authentication
2. Update registration to validate university emails
3. Create user profile in Firestore on registration
4. Implement email verification flow
5. Update login to check user role and route accordingly
6. Create user model and service classes

#### Phase 2: Report Enhancement
1. Link reports to authenticated users
2. Implement human-readable report ID generation
3. Add report counter in Firestore
4. Update report submission to include userId
5. Save report IDs to user profile

#### Phase 3: Student Features
1. Create "My Reports" screen
2. Implement report detail view for students
3. Create "Track Report by ID" screen
4. Add real-time status updates

#### Phase 4: Admin Features
1. Create admin dashboard
2. Implement report list view for admins
3. Create report management screen
4. Add status update functionality
5. Implement admin notes feature
6. Add report assignment to admins

#### Phase 5: Security & Testing
1. Implement Firestore security rules
2. Test role-based access control
3. Test email validation
4. Test report tracking
5. Test admin operations

---

### 9. Technical Stack

#### Frontend (Flutter)
- **State Management**: Provider or Riverpod
- **Authentication**: firebase_auth package
- **Database**: cloud_firestore package
- **Storage**: Cloudinary (already implemented)
- **Navigation**: Named routes with role-based guards

#### Backend (Firebase)
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Storage**: Cloudinary (for media)
- **Security**: Firestore Security Rules

---

### 10. Key Features Summary

#### For Students
✅ Register with university email
✅ Submit anonymous reports
✅ View their own submitted reports
✅ Track report status by ID
✅ Receive updates on report progress
✅ Access education hub and resources

#### For Admins
✅ View all submitted reports
✅ Update report status
✅ Add notes to reports
✅ Assign reports to themselves
✅ View analytics and statistics
✅ Manage report lifecycle

---

### 11. Database Queries

#### Common Queries

```dart
// Get user's reports
FirebaseFirestore.instance
  .collection('reports')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('timestamp', descending: true)
  .snapshots();

// Get all reports for admin
FirebaseFirestore.instance
  .collection('reports')
  .orderBy('timestamp', descending: true)
  .snapshots();

// Get reports by status
FirebaseFirestore.instance
  .collection('reports')
  .where('status', isEqualTo: 'submitted')
  .orderBy('timestamp', descending: true)
  .snapshots();

// Track report by display ID
FirebaseFirestore.instance
  .collection('reports')
  .where('displayId', isEqualTo: 'RS-2026-001234')
  .limit(1)
  .get();

// Get user profile
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();
```

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Prioritize features** based on requirements
3. **Start with Phase 1** (Authentication & User Management)
4. **Iterate and test** each phase before moving to the next
5. **Deploy security rules** before going to production

---

## Questions to Consider

1. **Should reports be truly anonymous or linked to users?**
   - Current plan: Linked to authenticated users but identity hidden from public
   - Admins can see submitter info if needed for investigation

2. **How many admins will there be?**
   - Affects assignment and workload distribution features

3. **Should students be able to delete their reports?**
   - Current plan: No deletion, only status updates by admins

4. **Email verification requirement?**
   - Current plan: Required before full access

5. **Report retention policy?**
   - How long should closed reports be kept?

---

## Conclusion

This architecture provides a comprehensive solution for role-based access control, report tracking, and admin management in RagSafe SL. The system maintains user privacy while enabling effective report management and status tracking.
