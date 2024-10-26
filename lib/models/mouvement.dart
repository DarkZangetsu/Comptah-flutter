class Mouvement {
  final String id;
  final String entrepriseId;
  final String nMouvement;
  final DateTime jour;
  final double montant;
  final String type;
  final String? genre;
  final String? mTransaction;
  final DateTime createdAt;

  Mouvement({
    required this.id,
    required this.entrepriseId,
    required this.nMouvement,
    required this.jour,
    required this.montant,
    required this.type,
    this.genre,
    this.mTransaction,
    required this.createdAt,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) {
    return Mouvement(
      id: json['id'],
      entrepriseId: json['entreprise_id'],
      nMouvement: json['n_mouvement'],
      jour: DateTime.parse(json['jour']),
      montant: json['montant'].toDouble(),
      type: json['type'],
      genre: json['genre'],
      mTransaction: json['m_transaction'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entrepriseId,
      'n_mouvement': nMouvement,
      'jour': jour.toIso8601String(),
      'montant': montant,
      'type': type,
      'genre': genre,
      'm_transaction': mTransaction,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Mouvement copyWith({
    String? id,
    String? entrepriseId,
    String? nMouvement,
    DateTime? jour,
    double? montant,
    String? type,
    String? genre,
    String? mTransaction,
    DateTime? createdAt,
  }) {
    return Mouvement(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nMouvement: nMouvement ?? this.nMouvement,
      jour: jour ?? this.jour,
      montant: montant ?? this.montant,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      mTransaction: mTransaction ?? this.mTransaction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}