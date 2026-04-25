// lib/services/sos_service_mobile.dart
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/emergency_popup.dart';

/// Mobile-specific SOS service implementation with shake detection
class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  ShakeDetector? _shakeDetector;
  bool _isShakeEnabled = true;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize the SOS service
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isShakeEnabled = prefs.getBool('shake_detection_enabled') ?? true;

      if (_isShakeEnabled) {
        startListening();
      }
    } catch (e) {
      debugPrint("Error initializing SOS service: $e");
    }
  }

  /// Start listening for shake events
  void startListening() {
    try {
      _shakeDetector?.stopListening();
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (event) {
          _showEmergencyPopup();
        },
        shakeThresholdGravity: 2.7,
      );
    } catch (e) {
      debugPrint("Error starting shake detection: $e");
    }
  }

  /// Stop listening for shake events
  void stopListening() {
    try {
      _shakeDetector?.stopListening();
      _shakeDetector = null;
    } catch (e) {
      debugPrint("Error stopping shake detection: $e");
    }
  }

  /// Update shake detection preference
  Future<void> setShakeEnabled(bool enabled) async {
    _isShakeEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('shake_detection_enabled', enabled);

      if (enabled) {
        startListening();
      } else {
        stopListening();
      }
    } catch (e) {
      debugPrint("Error setting shake enabled: $e");
    }
  }

  bool get isShakeEnabled => _isShakeEnabled;

  void _showEmergencyPopup() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const EmergencyPopup(),
      );
    }
  }

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
            'comment': 'Emergency SOS triggered via shake.'
          }
        ],
        'type': 'SHAKE_DETECTION',
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
