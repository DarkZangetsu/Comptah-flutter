class Depense {
  final String id;
  final String entrepriseId;
  final String nDepense;
  final DateTime jour;
  final String? idChantier;
  final String? motif;
  final String? type;
  final double montant;
  final String? mTransaction;
  final DateTime createdAt;

  Depense({
    required this.id,
    required this.entrepriseId,
    required this.nDepense,
    required this.jour,
    this.idChantier,
    this.motif,
    this.type,
    required this.montant,
    this.mTransaction,
    required this.createdAt,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      entrepriseId: json['entreprise_id'],
      nDepense: json['n_depense'],
      jour: DateTime.parse(json['jour']),
      idChantier: json['id_chantier'],
      motif: json['motif'],
      type: json['type'],
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entrepriseId,
      'n_depense': nDepense,
      'jour': jour.toIso8601String(),
      'id_chantier': idChantier,
      'motif': motif,
      'type': type,
      'montant': montant,
      'm_transaction': mTransaction,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Depense copyWith({
    String? id,
    String? entrepriseId,
    String? nDepense,
    DateTime? jour,
    String? idChantier,
    String? motif,
    String? type,
    double? montant,
    String? mTransaction,
    DateTime? createdAt,
  }) {
    return Depense(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nDepense: nDepense ?? this.nDepense,
      jour: jour ?? this.jour,
      idChantier: idChantier ?? this.idChantier,
      motif: motif ?? this.motif,
      type: type ?? this.type,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}