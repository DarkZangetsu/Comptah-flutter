class RemboursementES {
  final String id;
  final String nRemboursement;
  final String idEs;
  final DateTime jour;
  final double montant;
  final String? mTransaction;
  final String? personne;

  RemboursementES({
    required this.id,
    required this.nRemboursement,
    required this.idEs,
    required this.jour,
    required this.montant,
    this.mTransaction,
    this.personne,
  });

  factory RemboursementES.fromJson(Map<String, dynamic> json) {
    return RemboursementES(
      id: json['id'],
      nRemboursement: json['n_remboursement'],
      idEs: json['id_es'],
      jour: DateTime.parse(json['jour']),
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
      personne: json['personne'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_remboursement': nRemboursement,
      'id_es': idEs,
      'jour': jour.toIso8601String(),
      'montant': montant,
      'm_transaction': mTransaction,
      'personne': personne,
    };
  }

  RemboursementES copyWith({
    String? id,
    String? nRemboursement,
    String? idEs,
    DateTime? jour,
    double? montant,
    String? mTransaction,
    String? personne,
  }) {
    return RemboursementES(
      id: id ?? this.id,
      nRemboursement: nRemboursement ?? this.nRemboursement,
      idEs: idEs ?? this.idEs,
      jour: jour ?? this.jour,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      personne: personne ?? this.personne,
    );
  }
}
