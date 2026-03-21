import 'package:cloud_firestore/cloud_firestore.dart';

class Mentor {
  static const String fieldName = 'name';
  static const String fieldRole = 'role';
  static const String fieldSpecialty = 'specialty'; 
  static const String fieldRating = 'rating';
  static const String fieldDescription = 'description';
  static const String fieldTags = 'tags';
  static const String fieldIsOnline = 'isOnline';
  static const String fieldImageUrl = 'imageUrl';
  static const String fieldPhone = 'phone';
  static const String fieldEmail = 'email';
  static const String fieldVideoUrl = 'videoUrl';

  final String id;
  final String name;
  final String role;
  final double rating;
  final String description;
  final List<String> tags;
  final bool isOnline;
  final String imageUrl;
  final String phone;
  final String email;
  final String videoUrl;

  Mentor({
    required this.id,
    required this.name,
    required this.role,
    this.rating = 0,
    this.description = '',
    this.tags = const [],
    this.isOnline = false,
    this.imageUrl = '',
    this.phone = '',
    this.email = '',
    this.videoUrl = '',
  });

  factory Mentor.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Mentor.fromMap(id: doc.id, data: doc.data() ?? const {});
  }

  factory Mentor.fromFirestore(String id, Map<String, dynamic> data) {
    return Mentor.fromMap(id: id, data: data);
  }

  factory Mentor.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final parsedTags = _parseStringList(data[fieldTags]);
    final parsedRating = _parseDouble(data[fieldRating]);
    final parsedRole = _firstNonEmptyString(
      data[fieldRole],
      data[fieldSpecialty],
    );

    return Mentor(
      id: id,
      name: _asString(data[fieldName]),
      role: parsedRole,
      rating: parsedRating,
      description: _asString(data[fieldDescription]),
      tags: parsedTags,
      isOnline: _parseBool(data[fieldIsOnline]),
      imageUrl: _asString(data[fieldImageUrl]),
      phone: _asString(data[fieldPhone]),
      email: _asString(data[fieldEmail]),
      videoUrl: _asString(data[fieldVideoUrl]),
    );
  }

  Map<String, dynamic> toMap({bool includeLegacySpecialty = true}) {
    final map = <String, dynamic>{
      fieldName: name,
      fieldRole: role,
      fieldRating: rating,
      fieldDescription: description,
      fieldTags: tags,
      fieldIsOnline: isOnline,
      fieldImageUrl: imageUrl,
      fieldPhone: phone,
      fieldEmail: email,
      fieldVideoUrl: videoUrl,
    };

    if (includeLegacySpecialty) {
      map[fieldSpecialty] = role;
    }

    return map;
  }

  Mentor copyWith({
    String? id,
    String? name,
    String? role,
    double? rating,
    String? description,
    List<String>? tags,
    bool? isOnline,
    String? imageUrl,
    String? phone,
    String? email,
    String? videoUrl,
  }) {
    return Mentor(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isOnline: isOnline ?? this.isOnline,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static bool _parseBool(dynamic value) => value is bool ? value : false;

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((e) => e.toString()).toList();
  }

  static String _firstNonEmptyString(dynamic first, dynamic second) {
    final firstValue = _asString(first).trim();
    if (firstValue.isNotEmpty) return firstValue;
    return _asString(second).trim();
  }
}

