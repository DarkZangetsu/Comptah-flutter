class Depense {
  final String id;
  final String nDepense;
  final DateTime jour;
  final String idChantier;
  final String? motif;
  final double montant;
  final String? mTransaction;

  Depense({
    required this.id,
    required this.nDepense,
    required this.jour,
    required this.idChantier,
    this.motif,
    required this.montant,
    this.mTransaction,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      nDepense: json['n_depense'],
      jour: DateTime.parse(json['jour']),
      idChantier: json['id_chantier'],
      motif: json['motif'],
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_depense': nDepense,
      'jour': jour.toIso8601String(),
      'id_chantier': idChantier,
      'motif': motif,
      'montant': montant,
      'm_transaction': mTransaction,
    };
  }

  Depense copyWith({
    String? id,
    String? nDepense,
    DateTime? jour,
    String? idChantier,
    String? motif,
    double? montant,
    String? mTransaction,
  }) {
    return Depense(
      id: id ?? this.id,
      nDepense: nDepense ?? this.nDepense,
      jour: jour ?? this.jour,
      idChantier: idChantier ?? this.idChantier,
      motif: motif ?? this.motif,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
    );
  }
}
