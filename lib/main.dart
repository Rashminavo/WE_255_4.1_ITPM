import 'package:flutter/material.dart';
import 'Screens/hub_home_screen.dart';

void main() {
  runApp(const AwarenessHubApp());
}

class AwarenessHubApp extends StatelessWidget {
  const AwarenessHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awareness & Education Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const HubHomeScreen(),
    );
  }
}