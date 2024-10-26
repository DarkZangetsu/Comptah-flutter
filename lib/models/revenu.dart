class Revenu {
  final String id;
  final String entrepriseId;
  final String nRevenu;
  final DateTime jour;
  final String? raison;
  final String? type;
  final double montant;
  final String? mTransaction;
  final String? remarque;
  final DateTime createdAt;

  Revenu({
    required this.id,
    required this.entrepriseId,
    required this.nRevenu,
    required this.jour,
    this.raison,
    this.type,
    required this.montant,
    this.mTransaction,
    this.remarque,
    required this.createdAt,
  });

  factory Revenu.fromJson(Map<String, dynamic> json) {
    return Revenu(
      id: json['id'],
      entrepriseId: json['entreprise_id'],
      nRevenu: json['n_revenu'],
      jour: DateTime.parse(json['jour']),
      raison: json['raison'],
      type: json['type'],
      montant: json['montant'].toDouble(),
      mTransaction: json['m_transaction'],
      remarque: json['remarque'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entrepriseId,
      'n_revenu': nRevenu,
      'jour': jour.toIso8601String(),
      'raison': raison,
      'type': type,
      'montant': montant,
      'm_transaction': mTransaction,
      'remarque': remarque,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Revenu copyWith({
    String? id,
    String? entrepriseId,
    String? nRevenu,
    DateTime? jour,
    String? raison,
    String? type,
    double? montant,
    String? mTransaction,
    String? remarque,
    DateTime? createdAt,
  }) {
    return Revenu(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nRevenu: nRevenu ?? this.nRevenu,
      jour: jour ?? this.jour,
      raison: raison ?? this.raison,
      type: type ?? this.type,
      montant: montant ?? this.montant,
      mTransaction: mTransaction ?? this.mTransaction,
      remarque: remarque ?? this.remarque,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}