import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // === YOUR CLOUDINARY CREDENTIALS ===
  static const String cloudName = "dlfg43bwy";
  static const String apiKey = "132312844694336";
  static const String apiSecret = "B0v8LxNQnp3vvI-lRRPvnO_zMck";

  // Upload image or video to Cloudinary using direct HTTP API
  Future<String?> uploadFile(XFile file) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'ragsafe_preset'
        ..fields['folder'] = 'ragsafe_reports'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseString);

        if (jsonResponse['secure_url'] != null) {
          return jsonResponse['secure_url'];
        }
      }

      debugPrint("Cloudinary upload failed: Status ${response.statusCode}");
      return null;
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }
}
