import 'package:cloud_firestore/cloud_firestore.dart';

class MentorModel {
  final String id;
  final String name;
  final String specialty;
  final bool isOnline;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final String phone;
  final String email;
  final String videoUrl;



  const MentorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.isOnline,
    this.imageUrl = '',
    this.description = '',
    this.tags = const [],
    this.phone = '',
    this.email = '',
    this.videoUrl = '',
  });

  factory MentorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MentorModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      specialty: data['specialty']?.toString() ?? '',
      isOnline: data['isOnline'] is bool ? data['isOnline'] : false,
      imageUrl: data['imageUrl']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      tags: (data['tags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      videoUrl: data['videoUrl']?.toString() ?? '',
    );
  }
}
