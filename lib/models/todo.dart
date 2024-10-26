class Todo {
  final String id;
  final String entrepriseId;
  final String description;
  final DateTime? dueDate;
  final String status;
  final int priorite;
  final double? montant;
  final String? idChantier;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.entrepriseId,
    required this.description,
    this.dueDate,
    this.status = 'EN_COURS',
    this.priorite = 1,
    this.montant,
    this.idChantier,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id']?.toString() ?? '',
      entrepriseId: json['entreprise_id'],
      description: json['description'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'] ?? 'EN_COURS',
      priorite: json['priorite'] ?? 1,
      montant: json['montant']?.toDouble(),
      idChantier: json['id_chantier'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'entreprise_id': entrepriseId,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'priorite': priorite,
      'montant': montant,
      'id_chantier': idChantier,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Todo copyWith({
    String? id,
    String? entrepriseId,
    String? description,
    DateTime? dueDate,
    String? status,
    int? priorite,
    double? montant,
    String? idChantier,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priorite: priorite ?? this.priorite,
      montant: montant ?? this.montant,
      idChantier: idChantier ?? this.idChantier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}