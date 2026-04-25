import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
  }

  void _startShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        _showShakeConfirmation();
      },
      shakeThresholdGravity: 2.7,
    );
  }

  void _showShakeConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Detected'),
        content: const Text('Do you want to activate SOS?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _callUGCHotline();
            },
            child: const Text('Yes, Call SOS'),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call UGC Hotline'),
        content: const Text(
            'Do you want to call the UGC Anti-Ragging Hotline (1959)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _callUGCHotline();
            },
            child: const Text('Yes, Call Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _callUGCHotline() async {
    final Uri url = Uri.parse('tel:1959');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch hotline')),
      );
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Emergency SOS'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 120, color: Colors.red),
            const SizedBox(height: 30),
            const Text('In Danger?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Press SOS or Shake your phone',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: _showSOSConfirmation,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 10)
                  ],
                ),
                child: const Center(
                  child: Text('SOS',
                      style: TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Shake your phone for quick SOS',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
