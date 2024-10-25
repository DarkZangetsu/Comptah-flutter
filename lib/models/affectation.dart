class Affectation {
  final String id;
  final DateTime jour;
  final String idPersonnel;
  final String idChantier;
  final double? salaireMax;
  final String? personnel;

  Affectation({
    required this.id,
    required this.jour,
    required this.idPersonnel,
    required this.idChantier,
    this.salaireMax,
    this.personnel,
  });

  factory Affectation.fromJson(Map<String, dynamic> json) {
    return Affectation(
      id: json['id'],
      jour: DateTime.parse(json['jour']),
      idPersonnel: json['id_personnel'],
      idChantier: json['id_chantier'],
      salaireMax: json['salaire_max']?.toDouble(),
      personnel: json['personnel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jour': jour.toIso8601String(),
      'id_personnel': idPersonnel,
      'id_chantier': idChantier,
      'salaire_max': salaireMax,
      'personnel': personnel,
    };
  }

  Affectation copyWith({
    String? id,
    DateTime? jour,
    String? idPersonnel,
    String? idChantier,
    double? salaireMax,
    String? personnel,
  }) {
    return Affectation(
      id: id ?? this.id,
      jour: jour ?? this.jour,
      idPersonnel: idPersonnel ?? this.idPersonnel,
      idChantier: idChantier ?? this.idChantier,
      salaireMax: salaireMax ?? this.salaireMax,
      personnel: personnel ?? this.personnel,
    );
  }
}
