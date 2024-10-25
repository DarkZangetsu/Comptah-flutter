class Personnel {
  final String id;
  final String nom;
  final String? remarque;

  Personnel({
    required this.id,
    required this.nom,
    this.remarque,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      id: json['id'],
      nom: json['nom'],
      remarque: json['remarque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'remarque': remarque,
    };
  }

  Personnel copyWith({
    String? id,
    String? nom,
    String? remarque,
  }) {
    return Personnel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      remarque: remarque ?? this.remarque,
    );
  }
}
