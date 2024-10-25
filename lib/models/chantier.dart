class Chantier {
  final String? id;  // UUID as String
  final String nChantier;
  final double? depenseMax;
  final String? remarque;

  Chantier({
    this.id,
    required this.nChantier,
    this.depenseMax,
    this.remarque,
  });

  factory Chantier.fromJson(Map<String, dynamic> json) {
    return Chantier(
      id: json['id'] as String?, // Parse comme String pour UUID
      nChantier: json['n_chantier'] as String,
      depenseMax: (json['depense_max'] as num?)?.toDouble(),
      remarque: json['remarque'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'n_chantier': nChantier,
      'depense_max': depenseMax,
      'remarque': remarque,
    };
    // N'incluez l'ID que lors des mises à jour
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Chantier copyWith({
    String? id,
    String? nChantier,
    double? depenseMax,
    String? remarque,
  }) {
    return Chantier(
      id: id ?? this.id,
      nChantier: nChantier ?? this.nChantier,
      depenseMax: depenseMax ?? this.depenseMax,
      remarque: remarque ?? this.remarque,
    );
  }
}