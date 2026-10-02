import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  Future<void> saveProfile(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await _db.collection('users').doc(uid).set({
      ...data,

      // Every normal app registration creates a student account.
      'role': 'student',

      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveCollegeSchedule(
      String uid,
      Map<String, dynamic> schedule,
      ) async {
    await _db.collection('collegeSchedules').doc(uid).set({
      'userId': uid,
      'schedule': schedule,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

