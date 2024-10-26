import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/personnel.dart';
import '../providers/personnel_provider.dart';
import 'debouncer.dart';

class PersonnelScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const PersonnelScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  ConsumerState<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends ConsumerState<PersonnelScreen> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(personnelListProvider.notifier).loadPersonnel(widget.entrepriseId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personnelState = ref.watch(personnelListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonnelDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un membre du personnel...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _searchDebouncer.run(() {
                  ref.read(personnelListProvider.notifier).searchPersonnel(widget.entrepriseId, value);
                });
              },
            ),
          ),
          Expanded(
            child: personnelState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
              data: (personnel) {
                if (personnel.isEmpty) {
                  return const Center(
                    child: Text('Aucun membre du personnel trouvé'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(personnelListProvider.notifier).loadPersonnel(widget.entrepriseId);
                  },
                  child: ListView.builder(
                    itemCount: personnel.length,
                    itemBuilder: (context, index) {
                      final member = personnel[index];
                      return Dismissible(
                        key: Key(member.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmation(context, member);
                        },
                        onDismissed: (direction) {
                          ref.read(personnelListProvider.notifier).deletePersonnel(member.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Personnel supprimé avec succès')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              member.nom,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: member.remarque != null
                                ? Text(
                              member.remarque!,
                              style: theme.textTheme.bodySmall,
                            )
                                : null,
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditPersonnelDialog(context, member);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(context, member);
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPersonnelDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String nom = '';
    String? remarque;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un membre du personnel'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                  onSaved: (value) => nom = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Remarque (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  onSaved: (value) => remarque = value?.trim(),
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
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                ref.read(personnelListProvider.notifier).addPersonnel(
                  widget.entrepriseId,
                  nom,
                  remarque,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Personnel ajouté avec succès')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPersonnelDialog(BuildContext context, Personnel personnel) async {
    final formKey = GlobalKey<FormState>();
    String nom = personnel.nom;
    String? remarque = personnel.remarque;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le membre du personnel'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: personnel.nom,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                  onSaved: (value) => nom = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: personnel.remarque,
                  decoration: const InputDecoration(
                    labelText: 'Remarque (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  onSaved: (value) => remarque = value?.trim(),
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
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                ref.read(personnelListProvider.notifier).updatePersonnel(
                  personnel.copyWith(
                    nom: nom,
                    remarque: remarque,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Personnel modifié avec succès')),
                );
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Personnel personnel) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le membre du personnel'),
        content: Text('Voulez-vous vraiment supprimer "${personnel.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }
}