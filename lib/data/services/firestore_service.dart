import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mentor_model.dart';
import '../models/skill_model.dart';
import '../models/course_model.dart';
import '../models/course_progress_model.dart';
import '../models/accessibility_model.dart';
import '../models/session_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return uid;
  }

  // ── User Management ───────────────────────────────────────────────────────
  Future<void> createUserDocument(String uid, String email, String displayName, {bool isVerified = false}) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'isVerified': isVerified,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateUserVerificationStatus(String uid, bool isVerified) async {
    await _db.collection('users').doc(uid).update({
      'isVerified': isVerified,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get all users ordered by creation time (newest first)
  Future<List<Map<String, dynamic>>> getAllUsersOrderedByCreation({bool descending = true}) async {
    final snapshot = await _db
        .collection('users')
        .orderBy('createdAt', descending: descending)
        .get();
    return snapshot.docs.map((doc) => {'uid': doc.id, ...doc.data()}).toList();
  }

  /// Get recent users (last N users)
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10}) async {
    final snapshot = await _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => {'uid': doc.id, ...doc.data()}).toList();
  }

  /// Get users ordered by last update time
  Future<List<Map<String, dynamic>>> getUsersOrderedByUpdate({bool descending = true}) async {
    final snapshot = await _db
        .collection('users')
        .orderBy('updatedAt', descending: descending)
        .get();
    return snapshot.docs.map((doc) => {'uid': doc.id, ...doc.data()}).toList();
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

  // ── Session Management ────────────────────────────────────────────────────
  /// Create a new session booking
  Future<String> createSession(Session session) async {
    final uid = _uid;
    final now = DateTime.now();
    final sessionData = session.copyWith(
      userId: uid,
      createdAt: now,
      updatedAt: now,
    ).toMap();

    // Create in main sessions collection
    final sessionRef = await _db.collection('sessions').add(sessionData);
    final sessionId = sessionRef.id;

    // Add to user's my_sessions subcollection
    await _db.collection('users').doc(uid).collection('my_sessions').doc(sessionId).set(sessionData);

    // Add to mentor's mentor_sessions subcollection
    await _db.collection('mentors').doc(session.mentorId).collection('mentor_sessions').doc(sessionId).set(sessionData);

    return sessionId;
  }

  /// Get all sessions for the current user
  Future<List<Session>> getUserSessions({SessionStatus? status}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    Query query = _db.collection('users').doc(uid).collection('my_sessions').orderBy('date', descending: false);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Session.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  /// Get sessions for a specific mentor
  Future<List<Session>> getMentorSessions(String mentorId, {SessionStatus? status}) async {
    Query query = _db.collection('mentors').doc(mentorId).collection('mentor_sessions').orderBy('date', descending: false);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Session.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  /// Check if a time slot is available for a mentor on a specific date
  Future<bool> checkTimeSlotAvailability(String mentorId, DateTime date, String timeSlot) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _db
        .collection('mentors')
        .doc(mentorId)
        .collection('mentor_sessions')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .where('timeSlot', isEqualTo: timeSlot)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    return snapshot.docs.isEmpty;
  }

  /// Update session status
  Future<void> updateSessionStatus(String sessionId, String mentorId, SessionStatus status) async {
    final uid = _uid;
    final now = DateTime.now();
    final updateData = {
      'status': status.value,
      'updatedAt': now.toIso8601String(),
    };

    // Update in main sessions collection
    await _db.collection('sessions').doc(sessionId).update(updateData);

    // Update in user's subcollection
    await _db.collection('users').doc(uid).collection('my_sessions').doc(sessionId).update(updateData);

    // Update in mentor's subcollection
    await _db.collection('mentors').doc(mentorId).collection('mentor_sessions').doc(sessionId).update(updateData);
  }

  /// Cancel a session
  Future<void> cancelSession(String sessionId, String mentorId) async {
    await updateSessionStatus(sessionId, mentorId, SessionStatus.cancelled);
  }

  /// Get upcoming sessions for the current user
  Future<List<Session>> getUpcomingSessions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final now = DateTime.now();
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('my_sessions')
        .where('date', isGreaterThanOrEqualTo: now.toIso8601String())
        .where('status', whereIn: ['pending', 'confirmed'])
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) => Session.fromFirestore(doc.id, doc.data())).toList();
  }

  /// Get past sessions for the current user
  Future<List<Session>> getPastSessions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final now = DateTime.now();
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('my_sessions')
        .where('date', isLessThan: now.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Session.fromFirestore(doc.id, doc.data())).toList();
  }
}
