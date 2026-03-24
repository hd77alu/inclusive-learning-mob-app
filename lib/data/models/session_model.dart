class Session {
  final String id;
  final String mentorId;
  final String mentorName;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime date;
  final String timeSlot;
  final String note;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Session({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.date,
    required this.timeSlot,
    this.note = '',
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromFirestore(String id, Map<String, dynamic> data) {
    return Session(
      id: id,
      mentorId: data['mentorId'] ?? '',
      mentorName: data['mentorName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      date: data['date'] != null
          ? DateTime.parse(data['date'])
          : DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      note: data['note'] ?? '',
      status: SessionStatus.fromString(data['status'] ?? 'pending'),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'mentorName': mentorName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'note': note,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Session copyWith({
    String? id,
    String? mentorId,
    String? mentorName,
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? date,
    String? timeSlot,
    String? note,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum SessionStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  final String value;
  const SessionStatus(this.value);

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'completed':
        return SessionStatus.completed;
      case 'pending':
      default:
        return SessionStatus.pending;
    }
  }
}
