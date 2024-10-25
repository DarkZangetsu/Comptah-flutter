class EmpruntSortie {
  final String id;
  final String nSortie;
  final DateTime jour;
  final String personne;
  final double montant;
  final String? mTransaction;
  final String? remarque;

  EmpruntSortie({
    required this.id,
    required this.nSortie,
    required this.jour,
    required this.personne,
    required this.montant,
    this.mTransaction,
    this.remarque,
  });

  factory EmpruntSortie.fromJson(Map<String, dynamic> json) {
    return EmpruntSortie(
      id: json['id'],
      nSortie: json['n_sortie'],
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
      'n_sortie': nSortie,
      'jour': jour.toIso8601String(),
      'personne': personne,
      'montant': montant,
      'm_transaction': mTransaction,
      'remarque': remarque,
    };
  }

  EmpruntSortie copyWith({
    String? id,
    String? nSortie,
    DateTime? jour,
    String? personne,
    double? montant,
    String? mTransaction,
    String? remarque,
  }) {
    return EmpruntSortie(
      id: id ?? this.id,
      nSortie: nSortie ?? this.nSortie,
      jour: jour ?? this.jour,
      personne: personne ?? this.personne,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      remarque: remarque ?? this.remarque,
    );
  }
}
