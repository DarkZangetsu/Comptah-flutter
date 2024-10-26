import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/revenu.dart';
import '../providers/revenu_provider.dart';

class RevenuScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const RevenuScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  ConsumerState<RevenuScreen> createState() => _RevenuScreenState();
}

class _RevenuScreenState extends ConsumerState<RevenuScreen> {
  String? searchQuery;
  DateTime? dateDebut;
  DateTime? dateFin;
  String? selectedType;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      Future(() {
        if (mounted) {
          ref.read(revenusProvider(widget.entrepriseId).notifier).loadRevenus();
        }
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenusState = ref.watch(revenusProvider(widget.entrepriseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Revenus',
          style: const TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xffea6b24),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => _showAddRevenuDialog(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: revenusState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
        data: (revenus) => _buildRevenusList(revenus),
      ),
    );
  }

  Widget _buildRevenusList(List<Revenu> revenus) {
    if (revenus.isEmpty) {
      return const Center(child: Text('Aucun revenu trouvé'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: revenus.length,
      itemBuilder: (context, index) {
        final revenu = revenus[index];
        return Dismissible(
          key: Key(revenu.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteRevenu(revenu);
          },
          confirmDismiss: (direction) {
            return _showDeleteConfirmationDialog(context, revenu);
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('${revenu.nRevenu} - ${revenu.raison ?? ""}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(revenu.jour)}'),
                  Text('Montant: ${revenu.montant.toStringAsFixed(2)} €'),
                  if (revenu.type != null) Text('Type: ${revenu.type}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditRevenuDialog(context, revenu),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddRevenuDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String nRevenu = '';
    DateTime jour = DateTime.now();
    String? raison;
    String? type;
    double montant = 0.0;
    String? mTransaction;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
          ),
          child: const Text('Nouveau revenu', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Numéro de revenu'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                  onSaved: (value) => nRevenu = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Raison'),
                  onSaved: (value) => raison = value,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  value: type,
                  items: ['Salaire', 'Bonus', 'Investissement']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => type = value,
                  onSaved: (value) => type = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Montant'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    final number = double.tryParse(value!);
                    if (number == null) return 'Montant invalide';
                    return null;
                  },
                  onSaved: (value) => montant = double.parse(value!),
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Mode de transaction'),
                  onSaved: (value) => mTransaction = value,
                ),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: jour,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      jour = selectedDate;
                    }
                  },
                  child: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(jour)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final newRevenu = Revenu(
                  id: '',
                  entrepriseId: widget.entrepriseId,
                  nRevenu: nRevenu,
                  jour: jour,
                  raison: raison,
                  type: type,
                  montant: montant,
                  mTransaction: mTransaction,
                  createdAt: DateTime.now(),
                );
                ref
                    .read(revenusProvider(widget.entrepriseId).notifier)
                    .addRevenu(newRevenu);
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter', style: TextStyle(color: Color(0xffea6b24)),),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditRevenuDialog(
      BuildContext context, Revenu revenu) async {
    final formKey = GlobalKey<FormState>();
    String nRevenu = revenu.nRevenu;
    DateTime jour = revenu.jour;
    String? raison = revenu.raison;
    String? type = revenu.type;
    double montant = revenu.montant;
    String? mTransaction = revenu.mTransaction;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: const Text('Modifier le revenu'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nRevenu,
                  decoration:
                      const InputDecoration(labelText: 'Numéro de revenu'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                  onSaved: (value) => nRevenu = value!,
                ),
                TextFormField(
                  initialValue: raison,
                  decoration: const InputDecoration(labelText: 'Raison'),
                  onSaved: (value) => raison = value,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  value: type,
                  items: ['Salaire', 'Bonus', 'Investissement']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => type = value,
                  onSaved: (value) => type = value,
                ),
                TextFormField(
                  initialValue: montant.toString(),
                  decoration: const InputDecoration(labelText: 'Montant'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Champ requis';
                    final number = double.tryParse(value!);
                    if (number == null) return 'Montant invalide';
                    return null;
                  },
                  onSaved: (value) => montant = double.parse(value!),
                ),
                TextFormField(
                  initialValue: mTransaction,
                  decoration:
                      const InputDecoration(labelText: 'Mode de transaction'),
                  onSaved: (value) => mTransaction = value,
                ),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: jour,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      jour = selectedDate;
                    }
                  },
                  child: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(jour)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final updatedRevenu = revenu.copyWith(
                  nRevenu: nRevenu,
                  jour: jour,
                  raison: raison,
                  type: type,
                  montant: montant,
                  mTransaction: mTransaction,
                );
                ref
                    .read(revenusProvider(widget.entrepriseId).notifier)
                    .updateRevenu(updatedRevenu);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRevenu(Revenu revenu) async {
    await ref
        .read(revenusProvider(widget.entrepriseId).notifier)
        .deleteRevenu(revenu as String);
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, Revenu revenu) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: const Text('Supprimer le revenu'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce revenu ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    // Fonction de filtre personnalisée, si besoin d'implémenter des critères de filtre.
  }
}
