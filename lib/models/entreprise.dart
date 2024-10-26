class Entreprise {
  final String id;
  final String nom;
  final String userId;
  final DateTime createdAt;

  Entreprise({
    required this.id,
    required this.nom,
    required this.userId,
    required this.createdAt,
  });

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
      id: json['id'],
      nom: json['nom'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Entreprise copyWith({
    String? id,
    String? nom,
    String? userId,
    DateTime? createdAt,
  }) {
    return Entreprise(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
