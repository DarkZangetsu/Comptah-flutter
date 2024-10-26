class Chantier {
  final String id;
  final String entrepriseId;
  final String nChantier;
  final double? depenseMax;
  final String? remarque;
  final DateTime createdAt;

  Chantier({
    required this.id,
    required this.entrepriseId,
    required this.nChantier,
    this.depenseMax,
    this.remarque,
    required this.createdAt,
  });

  factory Chantier.fromJson(Map<String, dynamic> json) {
    return Chantier(
      id: json['id'],
      entrepriseId: json['entreprise_id'],
      nChantier: json['n_chantier'],
      depenseMax: json['depense_max']?.toDouble(),
      remarque: json['remarque'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entrepriseId,
      'n_chantier': nChantier,
      'depense_max': depenseMax,
      'remarque': remarque,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Chantier copyWith({
    String? id,
    String? entrepriseId,
    String? nChantier,
    double? depenseMax,
    String? remarque,
    DateTime? createdAt,
  }) {
    return Chantier(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nChantier: nChantier ?? this.nChantier,
      depenseMax: depenseMax ?? this.depenseMax,
      remarque: remarque ?? this.remarque,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}