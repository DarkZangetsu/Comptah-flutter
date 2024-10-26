class Affectation {
  final String id;
  final String entrepriseId;
  final DateTime jour;
  final String? idPersonnel;
  final String? idChantier;
  final double? salaireMax;
  final String? tache;
  final String? personnel;
  final String? chantier;
  final DateTime createdAt;

  Affectation({
    required this.id,
    required this.entrepriseId,
    required this.jour,
    this.idPersonnel,
    this.idChantier,
    this.salaireMax,
    this.tache,
    this.personnel,
    this.chantier,
    required this.createdAt,
  });

  factory Affectation.fromJson(Map<String, dynamic> json) {
    return Affectation(
      id: json['id']?.toString() ?? '',
      entrepriseId: json['entreprise_id']?.toString() ?? '',
      jour: DateTime.tryParse(json['jour']?.toString() ?? '') ?? DateTime.now(),
      idPersonnel: json['id_personnel']?.toString(),
      idChantier: json['id_chantier']?.toString(),
      salaireMax: json['salaire_max'] != null ? double.tryParse(json['salaire_max'].toString()) : null,
      tache: json['tache']?.toString(),
      personnel: json['personnel']?.toString(),
      chantier: json['chantier']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'entreprise_id': entrepriseId,
      'jour': jour.toIso8601String(),
      'id_personnel': idPersonnel,
      'id_chantier': idChantier,
      'salaire_max': salaireMax,
      'tache': tache,
      'personnel': personnel,
      'chantier' : chantier,
      'created_at': createdAt.toIso8601String(),
    };

}

  Affectation copyWith({
    String? id,
    String? entrepriseId,
    DateTime? jour,
    String? idPersonnel,
    String? idChantier,
    double? salaireMax,
    String? tache,
    String? personnel,
    String? chantier,
    DateTime? createdAt,
  }) {
    return Affectation(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      jour: jour ?? this.jour,
      idPersonnel: idPersonnel ?? this.idPersonnel,
      idChantier: idChantier ?? this.idChantier,
      salaireMax: salaireMax ?? this.salaireMax,
      tache: tache ?? this.tache,
      personnel: personnel ?? this.personnel,
      chantier: personnel ?? this.chantier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}