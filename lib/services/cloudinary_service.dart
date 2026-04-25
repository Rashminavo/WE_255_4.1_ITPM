import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class CloudinaryService {
  // === YOUR CLOUDINARY CREDENTIALS ===
  static const String cloudName = "dlfg43bwy";
  static const String apiKey = "132312844694336";
  static const String apiSecret = "B0v8LxNQnp3vvI-lRRPvnO_zMck";

  // Upload image or video to Cloudinary using direct HTTP API
  Future<String?> uploadFile(XFile file) async {
    try {
      // On web, skip upload and use the file path directly (it will be a data URL)
      if (kIsWeb) {
        debugPrint("Web platform detected - using image URL directly");
        return file.path;
      }

      final cloudinary = Cloudinary.full(
        cloudName: cloudName,
        apiKey: apiKey,
        apiSecret: apiSecret,
      );

      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: file.path,
          folder: 'ragsafe_reports',
          resourceType: CloudinaryResourceType.auto,
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        return response.secureUrl;
      }

      debugPrint("Cloudinary upload failed: ${response.error}");
      return null;
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }
}
