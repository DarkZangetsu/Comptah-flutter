class RemboursementEE {
  final String id;
  final String nRemboursement;
  final String idEe;
  final DateTime jour;
  final double montant;
  final String? mTransaction;
  final String? personne;

  RemboursementEE({
    required this.id,
    required this.nRemboursement,
    required this.idEe,
    required this.jour,
    required this.montant,
    this.mTransaction,
    this.personne,
  });

  factory RemboursementEE.fromJson(Map<String, dynamic> json) {
    return RemboursementEE(
      id: json['id'],
      nRemboursement: json['n_remboursement'],
      idEe: json['id_ee'],
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
      'id_ee': idEe,
      'jour': jour.toIso8601String(),
      'montant': montant,
      'm_transaction': mTransaction,
      'personne': personne,
    };
  }

  RemboursementEE copyWith({
    String? id,
    String? nRemboursement,
    String? idEe,
    DateTime? jour,
    double? montant,
    String? mTransaction,
    String? personne,
  }) {
    return RemboursementEE(
      id: id ?? this.id,
      nRemboursement: nRemboursement ?? this.nRemboursement,
      idEe: idEe ?? this.idEe,
      jour: jour ?? this.jour,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      personne: personne ?? this.personne,
    );
  }
}
