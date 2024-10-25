class Paiement {
  final String id;
  final String nPaiement;
  final DateTime jour;
  final String idAffectation;
  final double montant;
  final String? mTransaction;
  final String? remarque;

  Paiement({
    required this.id,
    required this.nPaiement,
    required this.jour,
    required this.idAffectation,
    required this.montant,
    this.mTransaction,
    this.remarque,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      nPaiement: json['n_paiement'],
      jour: DateTime.parse(json['jour']),
      idAffectation: json['id_affectation'],
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
      remarque: json['remarque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_paiement': nPaiement,
      'jour': jour.toIso8601String(),
      'id_affectation': idAffectation,
      'montant': montant,
      'm_transaction': mTransaction,
      'remarque': remarque,
    };
  }

  Paiement copyWith({
    String? id,
    String? nPaiement,
    DateTime? jour,
    String? idAffectation,
    double? montant,
    String? mTransaction,
    String? remarque,
  }) {
    return Paiement(
      id: id ?? this.id,
      nPaiement: nPaiement ?? this.nPaiement,
      jour: jour ?? this.jour,
      idAffectation: idAffectation ?? this.idAffectation,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      remarque: remarque ?? this.remarque,
    );
  }
}
