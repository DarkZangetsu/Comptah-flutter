import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/affectation.dart';
import '../providers/affectation_provider.dart';

class AffectationScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const AffectationScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  AffectationScreenState createState() => AffectationScreenState();
}

class AffectationScreenState extends ConsumerState<AffectationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(affectationListProvider.notifier).loadAffectations(widget.entrepriseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final affectationsAsync = ref.watch(affectationListProvider);
    final filters = ref.watch(affectationFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Affectations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          Expanded(
            child: affectationsAsync.when(
              data: (affectations) => _buildAffectationsList(affectations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAffectationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAffectationsList(List<Affectation> affectations) {
    if (affectations.isEmpty) {
      return const Center(child: Text('Aucune affectation trouvée'));
    }

    return ListView.builder(
      itemCount: affectations.length,
      itemBuilder: (context, index) {
        final affectation = affectations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text('${affectation.personnel ?? 'Non assigné'} - ${affectation.tache ?? 'Pas de tâche'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chantier: ${affectation.chantier}'),
                Text('Date: ${_dateFormat.format(affectation.jour)}'),
                if (affectation.salaireMax != null)
                  Text('Salaire max: ${affectation.salaireMax}Ar'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAffectationDialog(context, affectation: affectation),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, affectation),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _showFilterDialog(BuildContext context) async {
    final filters = ref.read(affectationFiltersProvider);
    DateTime? startDate = filters.dateDebut;
    DateTime? endDate = filters.dateFin;
    String? selectedChantierId = filters.chantierId;

    final chantiers = await ref.read(availableChangiersProvider(widget.entrepriseId).future);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtres'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Date début: ${startDate != null ? _dateFormat.format(startDate!) : 'Non définie'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Date fin: ${endDate != null ? _dateFormat.format(endDate!) : 'Non définie'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => endDate = date);
                    }
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedChantierId,
                decoration: const InputDecoration(labelText: 'Chantier'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous les chantiers')),
                  ...chantiers.map((chantier) => DropdownMenuItem(
                    value: chantier.id,
                    child: Text(chantier.nChantier),
                  )),
                ],
                onChanged: (value) => setState(() => selectedChantierId = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                ref.read(affectationFiltersProvider.notifier).state = AffectationFilters(
                  dateDebut: startDate,
                  dateFin: endDate,
                  chantierId: selectedChantierId,
                  searchTerm: _searchController.text,
                );
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAffectationDialog(BuildContext context, {Affectation? affectation}) async {
    final isEditing = affectation != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = affectation?.jour ?? DateTime.now();
    String? selectedPersonnelId = affectation?.idPersonnel;
    String? selectedChantierId = affectation?.idChantier;
    final tacheController = TextEditingController(text: affectation?.tache);
    final salaireController = TextEditingController(
      text: affectation?.salaireMax?.toString() ?? '',
    );

    final personnel = await ref.read(availablePersonnelProvider(widget.entrepriseId).future);
    final chantiers = await ref.read(availableChangiersProvider(widget.entrepriseId).future);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Modifier l\'affectation' : 'Nouvelle affectation'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Date: ${_dateFormat.format(selectedDate)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPersonnelId,
                    decoration: const InputDecoration(labelText: 'Personnel'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sélectionner un personnel')),
                      ...personnel.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.nom),
                      )),
                    ],
                    onChanged: (value) => setState(() => selectedPersonnelId = value),
                    validator: (value) => value == null ? 'Ce champ est requis' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedChantierId,
                    decoration: const InputDecoration(labelText: 'Chantier'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sélectionner un chantier')),
                      ...chantiers.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nChantier),
                      )),
                    ],
                    onChanged: (value) => setState(() => selectedChantierId = value),
                    validator: (value) => value == null ? 'Ce champ est requis' : null,
                  ),
                  TextFormField(
                    controller: tacheController,
                    decoration: const InputDecoration(labelText: 'Tâche'),
                    validator: (value) => value?.isEmpty == true ? 'Ce champ est requis' : null,
                  ),
                  TextFormField(
                    controller: salaireController,
                    decoration: const InputDecoration(labelText: 'Salaire maximum'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return null;
                      if (double.tryParse(value!) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
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
              onPressed: () async {
                if (formKey.currentState?.validate() == true) {
                  // Créer une nouvelle instance d'Affectation
                  final newAffectation = Affectation(
                    id: isEditing ? affectation!.id : '',
                    entrepriseId: widget.entrepriseId,
                    jour: selectedDate,
                    idPersonnel: selectedPersonnelId!,
                    idChantier: selectedChantierId!,
                    tache: tacheController.text,
                    salaireMax: salaireController.text.isNotEmpty
                        ? double.parse(salaireController.text)
                        : null,
                    createdAt: affectation?.createdAt ?? DateTime.now(),
                    personnel: null, // Ces valeurs seront remplies par la base de données
                  );

                  try {
                    if (isEditing) {
                      await ref.read(affectationListProvider.notifier)
                          .updateAffectation(newAffectation);
                    } else {
                      await ref.read(affectationListProvider.notifier)
                          .addAffectation(newAffectation);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Affectation mise à jour avec succès'
                                : 'Affectation créée avec succès',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(isEditing ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Affectation affectation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette affectation ?'),
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

    if (confirmed == true) {
      await ref.read(affectationListProvider.notifier)
          .deleteAffectation(affectation.id, affectation.entrepriseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Affectation supprimée avec succès')),
        );
      }
    }
  }

  void _applyFilters() {
    final filters = ref.read(affectationFiltersProvider);
    ref.read(affectationListProvider.notifier).searchAffectations(
      widget.entrepriseId,
      searchTerm: _searchController.text,
      dateDebut: filters.dateDebut,
      dateFin: filters.dateFin,
      chantierId: filters.chantierId,
      tache: filters.tache,
    );
  }
}