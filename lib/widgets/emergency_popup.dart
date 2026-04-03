// lib/widgets/emergency_popup.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Ensure XFile is defined
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';
import '../services/sos_service.dart';
import '../features/reporting/report_screen.dart';

class EmergencyPopup extends StatefulWidget {
  const EmergencyPopup({super.key});

  @override
  State<EmergencyPopup> createState() => _EmergencyPopupState();
}

class _EmergencyPopupState extends State<EmergencyPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isShakeEnabled = SosService().isShakeEnabled;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleFullSos() async {
    setState(() => _isProcessing = true);
    await SosService().triggerFullSos(context);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleCapture() async {
    // Show a quick choice between Photo and Video
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1D9E75)),
              title: const Text("Take Photo"),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF1D9E75)),
              title: const Text("Record Video (max 10s)"),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    try {
      final file =
          await SosService().captureEmergencyMedia(isVideo: choice == 'video');

      if (file != null && mounted) {
        _showPreview(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Capture failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPreview(XFile file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MediaPreviewDialog(
        file: file,
        onUse: () {
          Navigator.pop(context); // Close preview
          Navigator.pop(this.context); // Close popup
          Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (context) => ReportScreen(initialMedia: file),
            ),
          );
        },
        onCancel: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final rootNavigator = Navigator.of(this.context);
          final bool isPopupMounted = mounted;

          await Gal.putImage(file.path);

          if (mounted) {
            navigator.pop(); // Close preview
            if (isPopupMounted) {
              rootNavigator.pop(); // Close popup
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                "Emergency Detected",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Shake detected. What would you like to do?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (_isProcessing)
                const CircularProgressIndicator(color: Color(0xFF1D9E75))
              else ...[
                _buildActionButton(
                  onPressed: _handleFullSos,
                  icon: Icons.emergency,
                  label: "🚨 Full SOS",
                  color: Colors.red,
                  subtitle: "Call 1959 + Send Location",
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  onPressed: _handleCapture,
                  icon: Icons.camera_alt,
                  label: "📸 Capture Photo or Video",
                  color: const Color(0xFF1D9E75),
                  subtitle: "Gather evidence quickly",
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isShakeEnabled,
                  onChanged: (val) {
                    setState(() => _isShakeEnabled = val);
                    SosService().setShakeEnabled(val);
                  },
                  title: const Text("Enable shake detection",
                      style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF1D9E75),
                  activeTrackColor:
                      const Color(0xFF1D9E75).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required String subtitle,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: color.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaPreviewDialog extends StatefulWidget {
  final XFile file;
  final VoidCallback onUse;
  final VoidCallback onCancel;

  const MediaPreviewDialog({
    super.key,
    required this.file,
    required this.onUse,
    required this.onCancel,
  });

  @override
  State<MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<MediaPreviewDialog> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _videoController = VideoPlayerController.file(File(widget.file.path))
        ..initialize().then((_) => setState(() {}))
        ..setLooping(true)
        ..play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool get _isVideo =>
      widget.file.path.toLowerCase().endsWith('.mp4') ||
      widget.file.path.toLowerCase().endsWith('.mov');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              width: double.infinity,
              color: Colors.black,
              child: _isVideo
                  ? (_videoController?.value.isInitialized ?? false
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const Center(child: CircularProgressIndicator()))
                  : Image.file(File(widget.file.path), fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.onUse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Use in New Report",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
