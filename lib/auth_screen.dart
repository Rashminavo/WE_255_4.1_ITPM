import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'features/admin/admin_dashboard.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is already logged in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Check if user document exists and handle role
              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final userData = roleSnapshot.data!.data() as Map<String, dynamic>;
                final bool isAdmin = userData['isAdmin'] ?? false;

                if (isAdmin) {
                  return const AdminDashboard();
                } else {
                  return const MainNavigation();
                }
              }

              // Fallback for students if no detailed document is found
              return const MainNavigation();
            },
          );
        }

        // If not logged in, show the login screen
        return const LoginScreen();
      },
    );
  }
}
