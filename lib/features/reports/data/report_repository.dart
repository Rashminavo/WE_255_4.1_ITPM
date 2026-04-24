import 'package:cloud_firestore/cloud_firestore.dart';

class ReportRepository {
  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot> streamReports() {
    return _firestore.collection('reports').snapshots();
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': status,
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ])
    });
  }
}
