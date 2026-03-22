import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mentor_model.dart';
import '../models/skill_model.dart';
import '../models/course_model.dart';
import '../models/course_progress_model.dart';
import '../models/accessibility_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return uid;
  }

  // ── Mentors ───────────────────────────────────────────────────────────────
  Future<List<Mentor>> getMentors() async {
    final snapshot = await _db.collection('mentors').get();
    return snapshot.docs.map((doc) => Mentor.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> bookmarkMentor(String mentorId) async {
    await _db.collection('users').doc(_uid).collection('bookmarks').doc(mentorId)
        .set({'mentorId': mentorId, 'savedAt': DateTime.now().toIso8601String()});
  }

  Future<void> removeBookmark(String mentorId) async {
    await _db.collection('users').doc(_uid).collection('bookmarks').doc(mentorId).delete();
  }

  Future<Set<String>> getBookmarkedMentorIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final snapshot = await _db.collection('users').doc(uid).collection('bookmarks').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> updateMentorImage(String mentorId, String imageUrl) async {
    await _db.collection('mentors').doc(mentorId).set(
      {'imageUrl': imageUrl},
      SetOptions(merge: true),
    );
  }

  // ── Skills ────────────────────────────────────────────────────────────────
  Future<List<Skill>> getSkills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db.collection('users').doc(uid).collection('skills').get();
    return snapshot.docs.map((doc) => Skill.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> addSkill(Skill skill) async {
    await _db.collection('users').doc(_uid).collection('skills').add(skill.toMap());
  }

  Future<void> updateSkill(Skill skill) async {
    await _db.collection('users').doc(_uid).collection('skills').doc(skill.id).update(skill.toMap());
  }

  Future<void> deleteSkill(String skillId) async {
    await _db.collection('users').doc(_uid).collection('skills').doc(skillId).delete();
  }

  // ── Courses ───────────────────────────────────────────────────────────────
  Future<List<Course>> getCourses() async {
    final snapshot = await _db.collection('courses').get();
    if (snapshot.docs.isEmpty) {
      await _seedCourses();
      final seeded = await _db.collection('courses').get();
      return seeded.docs.map((d) => Course.fromFirestore(d.id, d.data())).toList();
    }
    return snapshot.docs.map((d) => Course.fromFirestore(d.id, d.data())).toList();
  }

  Future<void> _seedCourses() async {
    final courses = [
      {'title': 'Digital Skills for Business', 'module': 'MODULE 2', 'description': 'Learn the fundamentals of digital presence, online identity, and professional credibility.', 'category': 'Digital Skills', 'duration': '26 min', 'iconName': 'laptop_mac', 'iconColorValue': 0xFF4A90D9, 'isNew': false},
      {'title': 'Introduction to Sign Language', 'module': 'MODULE 1', 'description': 'Core signs for everyday communication. Includes RWL interpreter sessions.', 'category': 'Sign Language', 'duration': '18 min', 'iconName': 'sign_language', 'iconColorValue': 0xFF9B59B6, 'isNew': true},
      {'title': 'Braille Literacy Basics', 'module': 'MODULE 1', 'description': 'An introduction to Grade 1 Braille — reading and writing foundational cells.', 'category': 'Braille', 'duration': '22 min', 'iconName': 'accessibility', 'iconColorValue': 0xFFE07B30, 'isNew': false},
      {'title': 'Vocational Skills: Tailoring', 'module': 'MODULE 3', 'description': 'Practical tailoring techniques with adaptive tools for learners with motor differences.', 'category': 'Vocational', 'duration': '34 min', 'iconName': 'cut', 'iconColorValue': 0xFFD4608A, 'isNew': false},
      {'title': 'Computer Basics for Everyone', 'module': 'MODULE 1', 'description': 'Mouse, keyboard, files, and browsers — no experience needed. Screen-reader friendly.', 'category': 'Digital Skills', 'duration': '15 min', 'iconName': 'computer', 'iconColorValue': 0xFF00A89A, 'isNew': false},
      {'title': 'Advanced Sign Language', 'module': 'MODULE 4', 'description': 'Expand your vocabulary with complex expressions and conversational fluency.', 'category': 'Sign Language', 'duration': '40 min', 'iconName': 'record_voice_over', 'iconColorValue': 0xFF1A5FB4, 'isNew': true},
    ];
    final batch = _db.batch();
    for (final c in courses) {
      batch.set(_db.collection('courses').doc(), c);
    }
    await batch.commit();
  }

  // ── Course Progress ───────────────────────────────────────────────────────
  Future<Map<String, CourseProgress>> getUserCourseProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final snapshot = await _db.collection('users').doc(uid).collection('course_progress').get();
    return {for (final doc in snapshot.docs) doc.id: CourseProgress.fromFirestore(doc.id, doc.data())};
  }

  Future<void> updateCourseProgress(CourseProgress progress) async {
    await _db.collection('users').doc(_uid).collection('course_progress').doc(progress.courseId).set(progress.toMap());
  }

  Future<void> toggleCourseBookmark(String courseId, bool isCurrentlyBookmarked) async {
    final ref = _db.collection('users').doc(_uid).collection('course_progress').doc(courseId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.update({'isBookmarked': !isCurrentlyBookmarked});
    } else {
      await ref.set(CourseProgress(courseId: courseId, progress: 0.0, isBookmarked: true, lastAccessedAt: DateTime.now()).toMap());
    }
  }

  // ── Accessibility Preferences ─────────────────────────────────────────────
  Future<AccessibilityPreference?> getAccessibilityPreference() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).collection('settings').doc('accessibility').get();
    if (!doc.exists || doc.data() == null) return null;
    return AccessibilityPreference.fromFirestore(doc.data()!);
  }

  Future<void> saveAccessibilityPreference(String mode) async {
    final uid = _uid;
    await _db.collection('users').doc(uid).collection('settings').doc('accessibility').set({
      'userId': uid,
      'selectedMode': mode,
      'onboardingComplete': true,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}