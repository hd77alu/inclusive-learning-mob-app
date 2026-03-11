import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mentor_model.dart';
import '../models/skill_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Mentor>> getMentors() async {
    final snapshot = await _db.collection('mentors').get();

    return snapshot.docs
        .map((doc) => Mentor.fromFirestore(doc.data()))
        .toList();
  }

  // CRUD operations for Skills
  Future<List<Skill>> getSkills() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();

    return snapshot.docs
        .map((doc) => Skill.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> addSkill(Skill skill) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _db
        .collection('users')
        .doc(userId)
        .collection('skills')
        .add(skill.toMap());
  }

  Future<void> updateSkill(Skill skill) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _db
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skill.id)
        .update(skill.toMap());
  }

  Future<void> deleteSkill(String skillId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _db
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skillId)
        .delete();
  }
}