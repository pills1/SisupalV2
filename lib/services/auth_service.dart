import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Sign Up Logic
  // Updated signUp function to accept 'grade'
  Future<User?> signUp(String email, String password, String name, String role, {int grade = 5}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();

        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'studentName': name,
          'displayName': name,
          'fullName': name,
          'email': email,
          'role': role,
          'grade': role == 'Student' ? grade : null, // Only save grade for students
          'xp': 0,
          'streak': 1,
          'lastLogin': FieldValue.serverTimestamp(),
          'lastActiveDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Initialize fresh progress collection for student
        if (role == 'Student') {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('progress')
              .doc('mathematics')
              .set({
            'subject': 'Mathematics',
            'completedLessons': <String>[],
            'completedConcepts': <String>[],
            'quizScores': <String, dynamic>{},
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
      return user;
    } catch (e) {
      print("Error in SignUp: $e");
      return null;
    }
  }

  // 1b. Multi-Step Registration: Parent Account + Linked Student Profile
  Future<User?> signUpParentWithStudent({
    required String parentEmail,
    required String password,
    required String parentName,
    required String relationship,
    required String parentPin,
    required String studentName,
    required DateTime dob,
    required String gender,
    required String district,
    required String schoolName,
    int grade = 5,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: parentEmail,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(studentName);
        await user.reload();

        // 1. Explicitly write complete user and student profile to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': parentEmail,
          'parentEmail': parentEmail,
          'parentName': parentName,
          'relationship': relationship,
          'parentPin': parentPin,
          'name': studentName, // Student name as primary display name
          'studentName': studentName,
          'displayName': studentName,
          'fullName': studentName,
          'dob': dob.toIso8601String().split('T')[0],
          'gender': gender,
          'district': district,
          'school': schoolName,
          'role': 'Student',
          'grade': grade,
          'xp': 0,
          'streak': 1,
          'lastLogin': FieldValue.serverTimestamp(),
          'lastActiveDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 2. Initialize fresh progress map (0 completed lessons & 0 completed concepts)
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('progress')
            .doc('mathematics')
            .set({
          'subject': 'Mathematics',
          'completedLessons': <String>[],
          'completedConcepts': <String>[],
          'quizScores': <String, dynamic>{},
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return user;
    } catch (e) {
      print("Error in signUpParentWithStudent: $e");
      rethrow;
    }
  }

  // 2. Login Logic
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return result.user;
    } catch (e) {
      print("Error in SignIn: $e");
      return null;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // 4. Fetch User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] as String? ?? 'Student';
      }
    } catch (e) {
      print("Error getting role: $e");
    }
    return 'Student';
  }
  // 5. Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending reset email: $e");
      throw e; // Pass the error back to the UI so we can show a message
    }
  }

}