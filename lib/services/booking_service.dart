import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        .snapshots();
  }

  // Stream specific student's bookings (Student View)
  // Omitted orderBy('createdAt') to prevent composite index requirement in Firestore
  Stream<QuerySnapshot> getUserBookingsStream(String studentId) {
    return _firestore
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .snapshots();
  }

  // Get single booking by ID
  Future<DocumentSnapshot> getBooking(String bookingId) async {
    return await _firestore.collection('bookings').doc(bookingId).get();
  }
}
