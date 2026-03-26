import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_learning_app/data/models/skill_model.dart';
import 'package:inclusive_learning_app/data/models/mentor_model.dart';
import 'package:inclusive_learning_app/data/models/course_model.dart';
import 'package:inclusive_learning_app/data/models/accessibility_model.dart';
import 'package:inclusive_learning_app/data/models/session_model.dart';

void main() {

  // ── Skill model ──────────────────────────────────────────────────────────
  group('Skill model', () {
    test('creates a Skill with correct fields', () {
      final skill = Skill(id: '1', name: 'Flutter', level: 'Intermediate');
      expect(skill.id, '1');
      expect(skill.name, 'Flutter');
      expect(skill.level, 'Intermediate');
    });

    test('toMap() returns correct keys and values', () {
      final skill = Skill(id: '1', name: 'Dart', level: 'Beginner');
      final map = skill.toMap();
      expect(map['name'], 'Dart');
      expect(map['level'], 'Beginner');
      expect(map.containsKey('id'), isFalse);
    });

    test('fromFirestore() parses data correctly', () {
      final skill = Skill.fromFirestore('abc', {'name': 'Sign Language', 'level': 'Expert'});
      expect(skill.id, 'abc');
      expect(skill.name, 'Sign Language');
      expect(skill.level, 'Expert');
    });

    test('fromFirestore() uses empty string for missing fields', () {
      final skill = Skill.fromFirestore('x', {});
      expect(skill.name, '');
      expect(skill.level, '');
    });

    test('toMap() and fromFirestore() round-trip is consistent', () {
      final original = Skill(id: '99', name: 'Braille', level: 'Advanced');
      final map = original.toMap();
      final restored = Skill.fromFirestore('99', map);
      expect(restored.name, original.name);
      expect(restored.level, original.level);
    });
  });

  // ── Mentor model ─────────────────────────────────────────────────────────
  group('Mentor model', () {
    test('creates a Mentor with required fields', () {
      final mentor = Mentor(id: 'm1', name: 'Jean Damascene', role: 'Web Developer');
      expect(mentor.id, 'm1');
      expect(mentor.name, 'Jean Damascene');
      expect(mentor.role, 'Web Developer');
    });

    test('default values are applied when optional fields are omitted', () {
      final mentor = Mentor(id: 'm2', name: 'Aline', role: 'Designer');
      expect(mentor.rating, 0);
      expect(mentor.isOnline, isFalse);
      expect(mentor.tags, isEmpty);
      expect(mentor.imageUrl, '');
    });

    test('fromFirestore() parses all fields correctly', () {
      final mentor = Mentor.fromFirestore('m3', {
        'name': 'Eric Mugisha',
        'role': 'Mobile Developer',
        'rating': 4.5,
        'description': 'Expert in Flutter',
        'tags': ['Flutter', 'Dart'],
        'isOnline': true,
        'imageUrl': 'https://example.com/img.jpg',
        'phone': '+250788000000',
        'email': 'eric@example.com',
        'videoUrl': '',
      });
      expect(mentor.name, 'Eric Mugisha');
      expect(mentor.rating, 4.5);
      expect(mentor.tags, ['Flutter', 'Dart']);
      expect(mentor.isOnline, isTrue);
    });

    test('fromFirestore() falls back to specialty if role is missing', () {
      final mentor = Mentor.fromFirestore('m4', {'name': 'Rachel', 'specialty': 'Sign Language'});
      expect(mentor.role, 'Sign Language');
    });

    test('copyWith() returns updated Mentor without mutating original', () {
      final original = Mentor(id: 'm5', name: 'Jean', role: 'Dev');
      final updated = original.copyWith(name: 'Jean Bosco', isOnline: true);
      expect(updated.name, 'Jean Bosco');
      expect(updated.isOnline, isTrue);
      expect(original.name, 'Jean');
    });

    test('toMap() includes both role and legacy specialty field', () {
      final mentor = Mentor(id: 'm6', name: 'Esther', role: 'UX Designer');
      final map = mentor.toMap();
      expect(map['role'], 'UX Designer');
      expect(map['specialty'], 'UX Designer');
    });
  });

  // ── Course model ─────────────────────────────────────────────────────────
  group('Course model', () {
    test('creates a Course with correct fields', () {
      const course = Course(
        id: 'c1', title: 'Digital Skills', module: 'MODULE 1',
        description: 'Intro to digital tools', category: 'Digital Skills',
        duration: '20 min', iconName: 'laptop_mac', iconColorValue: 0xFF4A90D9,
      );
      expect(course.id, 'c1');
      expect(course.title, 'Digital Skills');
      expect(course.isNew, isFalse);
    });

    test('fromFirestore() parses data correctly', () {
      final course = Course.fromFirestore('c2', {
        'title': 'Sign Language Basics', 'module': 'MODULE 2',
        'description': 'Learn core signs', 'category': 'Sign Language',
        'duration': '18 min', 'iconName': 'sign_language',
        'iconColorValue': 0xFF9B59B6, 'isNew': true,
      });
      expect(course.title, 'Sign Language Basics');
      expect(course.isNew, isTrue);
    });

    test('fromFirestore() uses defaults for missing fields', () {
      final course = Course.fromFirestore('c3', {});
      expect(course.title, '');
      expect(course.iconName, 'laptop_mac');
      expect(course.isNew, isFalse);
    });

    test('toMap() contains all expected keys', () {
      const course = Course(
        id: 'c4', title: 'Braille', module: 'MODULE 1',
        description: 'Braille basics', category: 'Braille',
        duration: '22 min', iconName: 'accessibility', iconColorValue: 0xFFE07B30,
      );
      final map = course.toMap();
      expect(map.containsKey('title'), isTrue);
      expect(map.containsKey('isNew'), isTrue);
      expect(map['category'], 'Braille');
    });
  });

  // ── AccessibilityPreference model ─────────────────────────────────────────
  group('AccessibilityPreference model', () {
    test('fromFirestore() parses fields correctly', () {
      final pref = AccessibilityPreference.fromFirestore({
        'userId': 'u1', 'selectedMode': 'visual',
        'onboardingComplete': true, 'updatedAt': '2026-01-01T00:00:00.000',
      });
      expect(pref.userId, 'u1');
      expect(pref.selectedMode, 'visual');
      expect(pref.onboardingComplete, isTrue);
    });

    test('fromFirestore() handles missing updatedAt gracefully', () {
      final pref = AccessibilityPreference.fromFirestore(
        {'userId': 'u2', 'selectedMode': 'auditory', 'onboardingComplete': false});
      expect(pref.updatedAt, isNotNull);
    });

    test('copyWith() updates mode without changing userId', () {
      final original = AccessibilityPreference(
        userId: 'u3', selectedMode: 'visual',
        onboardingComplete: false, updatedAt: DateTime(2026),
      );
      final updated = original.copyWith(selectedMode: 'motor', onboardingComplete: true);
      expect(updated.selectedMode, 'motor');
      expect(updated.userId, 'u3');
    });

    test('toMap() serializes all fields correctly', () {
      final pref = AccessibilityPreference(
        userId: 'u4', selectedMode: 'cognitive',
        onboardingComplete: true, updatedAt: DateTime(2026, 1, 15),
      );
      final map = pref.toMap();
      expect(map['selectedMode'], 'cognitive');
      expect(map['updatedAt'], isA<String>());
    });
  });

  // ── Session model ─────────────────────────────────────────────────────────
  group('Session model', () {
    test('fromFirestore() parses all fields correctly', () {
      final session = Session.fromFirestore('s1', {
        'mentorId': 'mentor1', 'mentorName': 'Jean Damascene',
        'userId': 'user1', 'userName': 'Rachel', 'userEmail': 'rachel@example.com',
        'date': '2026-03-01T10:00:00.000', 'timeSlot': '10:00 AM',
        'note': 'Looking forward to it', 'status': 'pending',
        'createdAt': '2026-02-01T00:00:00.000', 'updatedAt': '2026-02-01T00:00:00.000',
      });
      expect(session.id, 's1');
      expect(session.mentorName, 'Jean Damascene');
      expect(session.status, SessionStatus.pending);
    });

    test('SessionStatus.fromString() parses all valid statuses', () {
      expect(SessionStatus.fromString('pending'), SessionStatus.pending);
      expect(SessionStatus.fromString('confirmed'), SessionStatus.confirmed);
      expect(SessionStatus.fromString('cancelled'), SessionStatus.cancelled);
      expect(SessionStatus.fromString('completed'), SessionStatus.completed);
    });

    test('SessionStatus.fromString() defaults to pending for unknown value', () {
      expect(SessionStatus.fromString('unknown'), SessionStatus.pending);
    });

    test('toMap() serializes status as string value', () {
      final session = Session(
        id: 's2', mentorId: 'm1', mentorName: 'Jean', userId: 'u1',
        userName: 'Rachel', userEmail: 'r@test.com',
        date: DateTime(2026, 4, 1), timeSlot: '2:00 PM',
        status: SessionStatus.confirmed,
        createdAt: DateTime(2026), updatedAt: DateTime(2026),
      );
      final map = session.toMap();
      expect(map['status'], 'confirmed');
    });

    test('copyWith() updates status without changing other fields', () {
      final original = Session(
        id: 's3', mentorId: 'm1', mentorName: 'Jean', userId: 'u1',
        userName: 'Rachel', userEmail: 'r@test.com',
        date: DateTime(2026, 4, 1), timeSlot: '2:00 PM',
        status: SessionStatus.pending,
        createdAt: DateTime(2026), updatedAt: DateTime(2026),
      );
      final updated = original.copyWith(status: SessionStatus.cancelled);
      expect(updated.status, SessionStatus.cancelled);
      expect(updated.mentorName, 'Jean');
      expect(original.status, SessionStatus.pending);
    });
  });

  // ── Widget tests ──────────────────────────────────────────────────────────
  group('Widget tests', () {
    testWidgets('Skill card renders name and level', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: _SkillCardPreview(
          skill: Skill(id: '1', name: 'Flutter', level: 'Intermediate'),
        )),
      ));
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('Skill card shows edit and delete icons', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: _SkillCardPreview(
          skill: Skill(id: '2', name: 'Dart', level: 'Beginner'),
        )),
      ));
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('Empty state shows prompt when no skills exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _EmptyStatePreview())),
      );
      expect(find.text('No skills added yet'), findsOneWidget);
    });
  });
}

// ── Preview widgets used only in widget tests ─────────────────────────────

class _SkillCardPreview extends StatelessWidget {
  final Skill skill;
  const _SkillCardPreview({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(skill.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(skill.level, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Row(children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
        ]),
      ]),
    );
  }
}

class _EmptyStatePreview extends StatelessWidget {
  const _EmptyStatePreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_outline_rounded, size: 48),
        SizedBox(height: 16),
        Text('No skills added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}