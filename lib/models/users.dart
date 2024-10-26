class Users {
  final String id;
  final String email;
  final DateTime createdAt;

  Users({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Users copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
  }) {
    return Users(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
