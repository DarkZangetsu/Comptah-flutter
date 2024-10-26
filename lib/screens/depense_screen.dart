import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/depense.dart';
import '../providers/depense_provider.dart';

class DepenseScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const DepenseScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  ConsumerState<DepenseScreen> createState() => _DepenseScreenState();
}

class _DepenseScreenState extends ConsumerState<DepenseScreen> {
  String? searchQuery;
  DateTime? dateDebut;
  DateTime? dateFin;
  String? selectedChantierId;
  String? selectedType;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      Future(() {
        if (mounted) {
          ref
              .read(depensesProvider(widget.entrepriseId).notifier)
              .loadDepenses();
        }
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final depensesState = ref.watch(depensesProvider(widget.entrepriseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dépenses',
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xffea6b24),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => _showAddDepenseDialog(context),
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
      body: depensesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
        data: (depenses) => _buildDepensesList(depenses),
      ),
    );
  }

  Widget _buildDepensesList(List<Depense> depenses) {
    if (depenses.isEmpty) {
      return const Center(child: Text('Aucune dépense trouvée'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: depenses.length,
      itemBuilder: (context, index) {
        final depense = depenses[index];
        return Dismissible(
          key: Key(depense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _deleteDepense(depense);
          },
          confirmDismiss: (direction) {
            return _showDeleteConfirmationDialog(context, depense);
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('${depense.nDepense} - ${depense.motif ?? ""}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(depense.jour)}'),
                  Text('Montant: ${depense.montant.toStringAsFixed(2)} €'),
                  if (depense.type != null) Text('Type: ${depense.type}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDepenseDialog(context, depense),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDepenseDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String nDepense = '';
    DateTime jour = DateTime.now();
    String? motif;
    String? type;
    double montant = 0.0;
    String? mTransaction;
    String? chantierId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
          child: const Text(
            'Nouvelle dépense',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Numéro de dépense'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                  onSaved: (value) => nDepense = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Motif'),
                  onSaved: (value) => motif = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Type'),
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
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            style:
                TextButton.styleFrom(backgroundColor: const Color(0xffea6b24)),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final newDepense = Depense(
                  id: '', // L'ID sera géré par Supabase
                  entrepriseId: widget.entrepriseId,
                  nDepense: nDepense,
                  jour: jour,
                  idChantier: chantierId,
                  motif: motif,
                  type: type,
                  montant: montant,
                  mTransaction: mTransaction,
                  createdAt: DateTime.now(),
                );
                ref
                    .read(depensesProvider(widget.entrepriseId).notifier)
                    .addDepense(newDepense);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Ajouter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDepenseDialog(BuildContext context, Depense depense) {
    final formKey = GlobalKey<FormState>();
    String nDepense = depense.nDepense;
    DateTime jour = depense.jour;
    String? motif = depense.motif;
    String? type = depense.type;
    double montant = depense.montant;
    String? mTransaction = depense.mTransaction;
    String? chantierId = depense.idChantier;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: Container(
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.grey))),
            child: const Text(
              'Modifier la dépense',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nDepense,
                  decoration:
                      const InputDecoration(labelText: 'Numéro de dépense'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                  onSaved: (value) => nDepense = value!,
                ),
                TextFormField(
                  initialValue: motif,
                  decoration: const InputDecoration(labelText: 'Motif'),
                  onSaved: (value) => motif = value,
                ),
                TextFormField(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
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
                final updatedDepense = depense.copyWith(
                  nDepense: nDepense,
                  jour: jour,
                  idChantier: chantierId,
                  motif: motif,
                  type: type,
                  montant: montant,
                  mTransaction: mTransaction,
                );
                ref
                    .read(depensesProvider(widget.entrepriseId).notifier)
                    .updateDepense(updatedDepense);
                Navigator.pop(context);
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, Depense depense) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
                'Voulez-vous vraiment supprimer la dépense "${depense.nDepense}" ?'),
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
        ) ??
        false;
  }

  void _deleteDepense(Depense depense) {
    ref
        .read(depensesProvider(widget.entrepriseId).notifier)
        .deleteDepense(depense.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dépense supprimée'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            // Logique pour annuler la suppression si nécessaire
          },
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        title: Container(
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.grey))),
            child: const Text('Filtrer les dépenses',
                style: TextStyle(fontWeight: FontWeight.bold))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  searchQuery = value;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dateDebut ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            dateDebut = date;
                          });
                        }
                      },
                      child: Text(
                        'Du: ${dateDebut != null ? DateFormat('dd/MM/yyyy').format(dateDebut!) : 'Choisir'}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dateFin ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            dateFin = date;
                          });
                        }
                      },
                      child: Text(
                        'Au: ${dateFin != null ? DateFormat('dd/MM/yyyy').format(dateFin!) : 'Choisir'}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              // Ajoutez d'autres filtres si nécessaire
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = null;
                dateDebut = null;
                dateFin = null;
                selectedType = null;
              });
              ref
                  .read(depensesProvider(widget.entrepriseId).notifier)
                  .loadDepenses();
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser', style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: const Color(0xffea6b24)),
            onPressed: () {
              ref
                  .read(depensesProvider(widget.entrepriseId).notifier)
                  .searchDepenses(
                    searchTerm: searchQuery,
                    dateDebut: dateDebut,
                    dateFin: dateFin,
                    type: selectedType,
                  );
              Navigator.pop(context);
            },
            child: const Text('Appliquer', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}
