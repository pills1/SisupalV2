import 'package:cloud_firestore/cloud_firestore.dart';

class LessonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all lessons for a specific subject (e.g., "Mathematics")
  Stream<QuerySnapshot> getLessons(String subject) {
    return _db
        .collection('lessons')
        .where('subject', isEqualTo: subject)
        .orderBy('order') // Sort by order (1, 2, 3...)
        .snapshots();
  }
}