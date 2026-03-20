import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  /// Streams all mentor documents from the 'mentors' collection.
  Stream<List<MentorModel>> getMentors() {
    return _db.collection('mentors').snapshots().map(
          (snap) => snap.docs.map(MentorModel.fromFirestore).toList(),
        );
  }

  /// Streams the set of bookmarked mentor IDs for a user.
  Stream<List<String>> getBookmarks(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('savedMentors')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// Bookmarks a mentor for a user.
  Future<void> bookmarkMentor(String userId, String mentorId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedMentors')
        .doc(mentorId)
        .set({'savedAt': FieldValue.serverTimestamp()});
  }

  /// Removes a mentor bookmark for a user.
  Future<void> removeBookmark(String userId, String mentorId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('savedMentors')
        .doc(mentorId)
        .delete();
  }

  /// Updates the imageUrl field of a mentor document.
  Future<void> updateMentorImage(String mentorId, String imageUrl) async {
    await _db
        .collection('mentors')
        .doc(mentorId)
        .update({'imageUrl': imageUrl});
  }
}
