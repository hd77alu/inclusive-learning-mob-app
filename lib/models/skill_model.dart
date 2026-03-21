class Skill {
  final String id;
  final String name;
  final String level;

  Skill({
    required this.id,
    required this.name,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
    };
  }

  factory Skill.fromFirestore(String id, Map<String, dynamic> data) {
    return Skill(
      id: id,
      name: data['name'] ?? '',
      level: data['level'] ?? '',
    );
  }
}
