import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<void> createBooking({
    required String studentId,
    required String studentName,
    required String counselorName,
    required String date,
    required String time,
    required String reason,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Create booking in Firestore
    await _firestore.collection('bookings').add({
      'studentId': studentId,
      'studentName': studentName,
      'counselorName': counselorName,
      'date': date,
      'time': time,
      'reason': reason,
      'status': 'Pending',
      'userId': user?.uid ?? '', // Store Firebase UID for notifications
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Send notification to user
    if (user != null) {
      await sendBookingNotification(
        userId: user.uid,
        title: 'Booking Confirmed',
        body: 'Your session with $counselorName on $date at $time has been booked successfully.',
        type: 'Booking',
      );
    }
  }

  // Update booking status (Admin)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  // Send notification to user
  Future<void> sendBookingNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isNew': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream all bookings (Admin View)
  Stream<QuerySnapshot> getBookingsStream() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching admin bookings: $error');
        });
  }

  // Stream specific student's bookings (Student View) with timeout
  // Omitted orderBy('createdAt') to prevent composite index requirement in Firestore
  Stream<QuerySnapshot> getUserBookingsStream(String studentId) {
    debugPrint('Getting bookings for studentId: $studentId');
    
    if (studentId.isEmpty) {
      debugPrint('Warning: Empty studentId provided');
      // Return a stream that emits an error, which will be caught by UI
      return Stream.error('studentId is empty');
    }
    
    return _firestore
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching user bookings: $error');
        })
        .timeout(
          const Duration(seconds: 5),
          onTimeout: (sink) {
            debugPrint('User bookings stream timeout');
            sink.addError('Stream timeout - please check connection');
          },
        );
  }

  // Get single booking by ID
  Future<DocumentSnapshot> getBooking(String bookingId) async {
    return await _firestore.collection('bookings').doc(bookingId).get();
  }
}
