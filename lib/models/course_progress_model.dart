class CourseProgress {
  final String courseId;
  final double progress; // 0.0 to 1.0
  final bool isBookmarked;
  final DateTime lastAccessedAt;

  const CourseProgress({
    required this.courseId,
    required this.progress,
    required this.isBookmarked,
    required this.lastAccessedAt,
  });

  factory CourseProgress.fromFirestore(String courseId, Map<String, dynamic> data) {
    return CourseProgress(
      courseId: courseId,
      progress: (data['progress'] ?? 0.0).toDouble(),
      isBookmarked: data['isBookmarked'] ?? false,
      lastAccessedAt: data['lastAccessedAt'] != null
          ? DateTime.parse(data['lastAccessedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'courseId': courseId,
        'progress': progress,
        'isBookmarked': isBookmarked,
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
      };

  CourseProgress copyWith({double? progress, bool? isBookmarked}) {
    return CourseProgress(
      courseId: courseId,
      progress: progress ?? this.progress,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastAccessedAt: DateTime.now(),
    );
  }
}