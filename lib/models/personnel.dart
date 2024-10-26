// Personnel Model
class Personnel {
  final String id;
  final String entrepriseId;
  final String nom;
  final String? remarque;
  final DateTime createdAt;

  Personnel({
    required this.id,
    required this.entrepriseId,
    required this.nom,
    this.remarque,
    required this.createdAt,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      id: json['id'],
      entrepriseId: json['entreprise_id'],
      nom: json['nom'],
      remarque: json['remarque'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entrepriseId,
      'nom': nom,
      'remarque': remarque,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Personnel copyWith({
    String? id,
    String? entrepriseId,
    String? nom,
    String? remarque,
    DateTime? createdAt,
  }) {
    return Personnel(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nom: nom ?? this.nom,
      remarque: remarque ?? this.remarque,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}