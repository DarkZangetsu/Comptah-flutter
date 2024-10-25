class Caisse {
  final String id;
  final String nCaisse;
  final DateTime jour;
  final double montant;
  final String? raison;
  final String? mTransaction;
  final String? remarque;

  Caisse({
    required this.id,
    required this.nCaisse,
    required this.jour,
    required this.montant,
    this.raison,
    this.mTransaction,
    this.remarque,
  });

  factory Caisse.fromJson(Map<String, dynamic> json) {
    return Caisse(
      id: json['id'],
      nCaisse: json['n_caisse'],
      jour: DateTime.parse(json['jour']),
      montant: json['montant'].toDouble(),
      raison: json['raison'],
      mTransaction: json['m_transaction'],
      remarque: json['remarque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_caisse': nCaisse,
      'jour': jour.toIso8601String(),
      'montant': montant,
      'raison': raison,
      'm_transaction': mTransaction,
      'remarque': remarque,
    };
  }

  Caisse copyWith({
    String? id,
    String? nCaisse,
    DateTime? jour,
    double? montant,
    String? raison,
    String? mTransaction,
    String? remarque,
  }) {
    return Caisse(
      id: id ?? this.id,
      nCaisse: nCaisse ?? this.nCaisse,
      jour: jour ?? this.jour,
      montant: montant ?? this.montant,
      raison: raison ?? this.raison,
      mTransaction: mTransaction ?? this.mTransaction,
      remarque: remarque ?? this.remarque,
    );
  }
}
