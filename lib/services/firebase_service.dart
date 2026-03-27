// lib/services/firebase_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/report_model.dart';

/// FirebaseService handles all Firebase operations for RagaSafe SL
/// Provides methods for creating anonymous reports and tracking status
class FirebaseService {
  // Firestore collection reference
  static const String _reportsCollection = 'reports';

  // Firebase Storage reference
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new anonymous report
  ///
  /// Parameters:
  /// - [type]: The type of ragging incident
  /// - [description]: Detailed description of the incident
  /// - [mediaFile]: Optional media file (image/video) as evidence
  /// - [latitude]: Optional GPS latitude
  /// - [longitude]: Optional GPS longitude
  ///
  /// Returns the generated report ID
  Future<String> createReport({
    required ReportType type,
    required String description,
    File? mediaFile,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Generate unique report ID
      final String reportId = _generateReportId();

      // Upload media if provided
      String? mediaUrl;
      if (mediaFile != null) {
        mediaUrl = await _uploadMedia(mediaFile, reportId);
      }

      // Create report timestamp
      final DateTime timestamp = DateTime.now();

      // Create report document
      final Map<String, dynamic> reportData = {
        'id': reportId,
        'type': type.name,
        'description': description,
        'mediaUrl': mediaUrl,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': ReportStatus.submitted.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .set(reportData);

      return reportId;
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to create report: $e',
        code: 'CREATE_REPORT_ERROR',
      );
    }
  }

  /// Get report status as a real-time stream
  ///
  /// Parameters:
  /// - [reportId]: The unique report identifier
  ///
  /// Returns a Stream that emits the report status updates
  Stream<Report?> getReportStatus(String reportId) {
    return _firestore
        .collection(_reportsCollection)
        .doc(reportId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Report.fromSnapshot(snapshot);
      }
      return null;
    });
  }

  /// Get report by ID (single fetch)
  ///
  /// Parameters:
  /// - [reportId]: The unique report identifier
  ///
  /// Returns the Report if found, null otherwise
  Future<Report?> getReport(String reportId) async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection(_reportsCollection).doc(reportId).get();

      if (snapshot.exists) {
        return Report.fromSnapshot(snapshot);
      }
      return null;
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch report: $e',
        code: 'FETCH_REPORT_ERROR',
      );
    }
  }

  /// Update report status (admin only)
  ///
  /// Parameters:
  /// - [reportId]: The unique report identifier
  /// - [status]: The new status to set
  /// - [notes]: Optional admin notes
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .update(updateData);
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to update report status: $e',
        code: 'UPDATE_STATUS_ERROR',
      );
    }
  }

  /// Get all reports (admin only)
  ///
  /// Returns a list of all reports
  Future<List<Report>> getAllReports() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_reportsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Report.fromSnapshot(doc)).toList();
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch reports: $e',
        code: 'FETCH_REPORTS_ERROR',
      );
    }
  }

  /// Upload media file to Firebase Storage
  ///
  /// Parameters:
  /// - [file]: The media file to upload
  /// - [reportId]: The associated report ID
  ///
  /// Returns the download URL of the uploaded file
  Future<String> _uploadMedia(File file, String reportId) async {
    try {
      // Determine file extension
      final String extension = file.path.split('.').last.toLowerCase();

      // Determine storage path based on file type
      String storagePath;
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        storagePath = 'reports/$reportId/evidence.$extension';
      } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
        storagePath = 'reports/$reportId/video.$extension';
      } else {
        storagePath = 'reports/$reportId/media.$extension';
      }

      // Create storage reference
      final Reference storageRef = _storage.ref().child(storagePath);

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(extension),
        cacheControl: 'max-age=31536000',
      );

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(
        file,
        metadata,
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw FirebaseServiceException(
        'Failed to upload media: $e',
        code: 'UPLOAD_MEDIA_ERROR',
      );
    }
  }

  /// Delete media from Firebase Storage
  ///
  /// Parameters:
  /// - [mediaUrl]: The full download URL of the media to delete
  Future<void> deleteMedia(String mediaUrl) async {
    try {
      // Extract storage path from URL
      final String path = _extractStoragePath(mediaUrl);

      if (path.isNotEmpty) {
        await _storage.ref(path).delete();
      }
    } catch (e) {
      // Log error but don't throw - media deletion failure shouldn't break the flow
      debugPrint('Warning: Failed to delete media: $e');
    }
  }

  /// Generate a unique report ID
  /// Format: RS-{TIMESTAMP}-{RANDOM}
  String _generateReportId() {
    final DateTime now = DateTime.now();
    final String timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final int random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000));
    return 'RS-$timestamp-$random';
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  /// Extract storage path from Firebase Storage download URL
  String _extractStoragePath(String downloadUrl) {
    try {
      // Firebase Storage URLs follow the pattern:
      // https://firebasestorage.googleapis.com/.../o/PATH?...
      final String marker = '/o/';
      final int startIndex = downloadUrl.indexOf(marker);

      if (startIndex == -1) return '';

      final int pathStart = startIndex + marker.length;
      final int pathEnd = downloadUrl.indexOf('?', pathStart);

      if (pathEnd == -1) return '';

      return Uri.decodeComponent(downloadUrl.substring(pathStart, pathEnd));
    } catch (e) {
      return '';
    }
  }
}

/// Custom exception for Firebase service errors
class FirebaseServiceException implements Exception {
  final String message;
  final String code;
  final DateTime timestamp;
  final dynamic originalError;

  FirebaseServiceException(
    this.message, {
    this.code = 'UNKNOWN_ERROR',
    DateTime? timestamp,
    this.originalError,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'FirebaseServiceException: [$code] $message';
  }

  /// Convert to map for logging/debugging
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'originalError': originalError?.toString(),
    };
  }
}
