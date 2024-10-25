class EmpruntEntree {
  final String id;
  final String nEmprunt;
  final DateTime jour;
  final String personne;
  final double montant;
  final String? mTransaction;
  final String? remarque;

  EmpruntEntree({
    required this.id,
    required this.nEmprunt,
    required this.jour,
    required this.personne,
    required this.montant,
    this.mTransaction,
    this.remarque,
  });

  factory EmpruntEntree.fromJson(Map<String, dynamic> json) {
    return EmpruntEntree(
      id: json['id'],
      nEmprunt: json['n_emprunt'],
      jour: DateTime.parse(json['jour']),
      personne: json['personne'],
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
      remarque: json['remarque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_emprunt': nEmprunt,
      'jour': jour.toIso8601String(),
      'personne': personne,
      'montant': montant,
      'm_transaction': mTransaction,
      'remarque': remarque,
    };
  }

  EmpruntEntree copyWith({
    String? id,
    String? nEmprunt,
    DateTime? jour,
    String? personne,
    double? montant,
    String? mTransaction,
    String? remarque,
  }) {
    return EmpruntEntree(
      id: id ?? this.id,
      nEmprunt: nEmprunt ?? this.nEmprunt,
      jour: jour ?? this.jour,
      personne: personne ?? this.personne,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      remarque: remarque ?? this.remarque,
    );
  }
}
