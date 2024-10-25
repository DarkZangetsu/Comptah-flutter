class Mouvement {
  final String id;
  final String nMouvement;
  final DateTime jour;
  final double montant;
  final String type;
  final String? genre;
  final String? mTransaction;

  Mouvement({
    required this.id,
    required this.nMouvement,
    required this.jour,
    required this.montant,
    required this.type,
    this.genre,
    this.mTransaction,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) {
    return Mouvement(
      id: json['id'],
      nMouvement: json['n_mouvement'],
      jour: DateTime.parse(json['jour']),
      montant: json['montant'].toDouble(),
      type: json['type'],
      genre: json['genre'],
      mTransaction: json['m_transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n_mouvement': nMouvement,
      'jour': jour.toIso8601String(),
      'montant': montant,
      'type': type,
      'genre': genre,
      'm_transaction': mTransaction,
    };
  }

  Mouvement copyWith({
    String? id,
    String? nMouvement,
    DateTime? jour,
    double? montant,
    String? type,
    String? genre,
    String? mTransaction,
  }) {
    return Mouvement(
      id: id ?? this.id,
      nMouvement: nMouvement ?? this.nMouvement,
      jour: jour ?? this.jour,
      montant: montant ?? this.montant,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      mTransaction: mTransaction ?? this.mTransaction,
    );
  }
}
