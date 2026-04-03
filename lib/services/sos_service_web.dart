// lib/services/sos_service_web.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web-specific SOS service implementation (shake detection disabled on web)
class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize the SOS service
  Future<void> init() async {
    try {
      debugPrint(
          "✓ SOS Service initialized for web (shake detection disabled)");
    } catch (e) {
      debugPrint("Error initializing SOS service: $e");
    }
  }

  /// Start listening (no-op on web)
  void startListening() {
    debugPrint("Shake detection not available on web platform");
  }

  /// Stop listening (no-op on web)
  void stopListening() {
    debugPrint("Shake detection not available on web platform");
  }

  /// Update shake detection preference (no-op on web)
  Future<void> setShakeEnabled(bool enabled) async {
    if (enabled) {
      debugPrint("⚠️ Shake detection is not available on web platform");
    }
  }

  bool get isShakeEnabled => false; // Always false on web


  /// Execute Full SOS sequence
  Future<void> triggerFullSos(BuildContext context) async {
    final Uri callUri = Uri.parse('tel:1959');
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('emergency_alerts').add({
        'userId': user?.uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(position.latitude, position.longitude),
        'status': 'SOS_TRIGGERED',
        'statusHistory': [
          {
            'status': 'SOS_TRIGGERED',
            'timestamp': FieldValue.serverTimestamp(),
            'comment': 'Emergency SOS triggered via web'
          }
        ],
        'type': 'WEB_MANUAL',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 SOS Alert with location sent to authorities!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error sending SOS location: $e");
    }
  }

  /// Centralized Capture Logic
  Future<XFile?> captureEmergencyMedia({required bool isVideo}) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (isVideo) {
        return await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 10),
        );
      } else {
        return await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }
    } catch (e) {
      debugPrint("Media capture error: $e");
      return null;
    }
  }
}
