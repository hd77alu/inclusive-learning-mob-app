class Course {
  final String id;
  final String title;
  final String module;
  final String description;
  final String category;
  final String duration;
  final String iconName;
  final int iconColorValue;
  final bool isNew;

  const Course({
    required this.id,
    required this.title,
    required this.module,
    required this.description,
    required this.category,
    required this.duration,
    required this.iconName,
    required this.iconColorValue,
    this.isNew = false,
  });

  factory Course.fromFirestore(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      title: data['title'] ?? '',
      module: data['module'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? '',
      iconName: data['iconName'] ?? 'laptop_mac',
      iconColorValue: data['iconColorValue'] ?? 0xFF4A90D9,
      isNew: data['isNew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'module': module,
        'description': description,
        'category': category,
        'duration': duration,
        'iconName': iconName,
        'iconColorValue': iconColorValue,
        'isNew': isNew,
      };
}