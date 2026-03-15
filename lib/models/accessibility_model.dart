class AccessibilityPreference {
  final String userId;
  final String selectedMode; // 'visual' | 'auditory' | 'motor' | 'cognitive'
  final bool onboardingComplete;
  final DateTime updatedAt;

  const AccessibilityPreference({
    required this.userId,
    required this.selectedMode,
    required this.onboardingComplete,
    required this.updatedAt,
  });

  factory AccessibilityPreference.fromFirestore(Map<String, dynamic> data) {
    return AccessibilityPreference(
      userId: data['userId'] ?? '',
      selectedMode: data['selectedMode'] ?? '',
      onboardingComplete: data['onboardingComplete'] ?? false,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'selectedMode': selectedMode,
        'onboardingComplete': onboardingComplete,
        'updatedAt': updatedAt.toIso8601String(),
      };

  AccessibilityPreference copyWith({
    String? selectedMode,
    bool? onboardingComplete,
  }) {
    return AccessibilityPreference(
      userId: userId,
      selectedMode: selectedMode ?? this.selectedMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      updatedAt: DateTime.now(),
    );
  }
}