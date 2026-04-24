import 'package:flutter/material.dart';
import '../../Screens/admin_dashboard.dart' as admin_app;
import '../../Screens/buddy_hub_screen.dart';
import '../../Screens/counselor_screen.dart';
import '../../Screens/main_navigation.dart';
import 'app_role.dart';

class RoleHomeResolver {
  static Widget resolveHome(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const admin_app.AdminDashboard();
      case AppRole.student:
        return const MainNavigation();
      case AppRole.counselor:
        return const CounselorScreen();
      case AppRole.peerBuddy:
        return const BuddyHubScreen();
    }
  }

  static bool isAuthorized({
    required AppRole role,
    required Set<AppRole> allowedRoles,
  }) {
    return allowedRoles.contains(role);
  }
}

class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.currentRole,
    required this.allowedRoles,
    required this.child,
  });

  final AppRole currentRole;
  final Set<AppRole> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canAccess = RoleHomeResolver.isAuthorized(
      role: currentRole,
      allowedRoles: allowedRoles,
    );

    if (canAccess) {
      return child;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'You do not have permission to access this feature.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
