class Mentor {
  final String name;
  final String role;
  final double rating;
  final String description;
  final List<String> tags;
  final bool isOnline;

  Mentor({
    required this.name,
    required this.role,
    required this.rating,
    this.description = '',
    this.tags = const [],
    this.isOnline = false,
  });

  factory Mentor.fromFirestore(Map<String, dynamic> data) {
    return Mentor(
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isOnline: data['isOnline'] ?? false,
    );
  }
}