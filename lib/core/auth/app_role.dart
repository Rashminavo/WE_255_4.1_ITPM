enum AppRole {
  admin,
  student,
  counselor,
  peerBuddy,
}

extension AppRoleX on AppRole {
  String get value {
    switch (this) {
      case AppRole.admin:
        return 'admin';
      case AppRole.student:
        return 'student';
      case AppRole.counselor:
        return 'counselor';
      case AppRole.peerBuddy:
        return 'peer_buddy';
    }
  }

  static AppRole fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'admin':
        return AppRole.admin;
      case 'counselor':
        return AppRole.counselor;
      case 'peer_buddy':
      case 'peerbuddy':
      case 'buddy':
        return AppRole.peerBuddy;
      case 'student':
      default:
        return AppRole.student;
    }
  }
}
