import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/ragasafe_provider.dart';
import 'providers/buddy_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/forum_provider.dart';
import 'providers/meetup_provider.dart';
import 'Screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    debugPrint("❌ Firebase setup error: $e");
  }

  runApp(const RagaSafeApp());
}

class RagaSafeApp extends StatelessWidget {
  const RagaSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // RagaSafe Providers
        ChangeNotifierProvider(create: (_) => RagaSafeProvider()),
        
        // Peer Buddy & Chat Providers
        ChangeNotifierProvider(create: (_) => BuddyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => MeetupProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RagaSafe + PeerBuddy',
        
        // Themes with brand colors
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Entry point
        home: const SplashScreen(),
        
        builder: (context, child) {
          return child!;
        },
      ),
    );
  }
}
