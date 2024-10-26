import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chantier.dart';
import '../providers/chantier_provider.dart';
import 'debouncer.dart';

class ChantierScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const ChantierScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  ConsumerState<ChantierScreen> createState() => _ChantierScreenState();
}

class _ChantierScreenState extends ConsumerState<ChantierScreen> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chantierListProvider.notifier).loadChantiers(widget.entrepriseId);
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
    final chantiersState = ref.watch(chantierListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chantiers'),
        centerTitle: true,
      ),
      // Ajout du Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChantierDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un chantier...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _searchDebouncer.run(() {
                  ref.read(chantierListProvider.notifier).searchChantiers(value);
                });
              },
            ),
          ),
          Expanded(
            child: chantiersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
              data: (chantiers) {
                if (chantiers.isEmpty) {
                  return const Center(
                    child: Text('Aucun chantier trouvé'),
                  );
                }
                return ListView.builder(
                  itemCount: chantiers.length,
                  itemBuilder: (context, index) {
                    final chantier = chantiers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          chantier.nChantier,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (chantier.depenseMax != null)
                              Text(
                                'Budget max: ${chantier.depenseMax!.toStringAsFixed(2)} €',
                                style: theme.textTheme.bodySmall,
                              ),
                            if (chantier.remarque != null && chantier.remarque!.isNotEmpty)
                              Text(
                                chantier.remarque!,
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
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
                              _showEditChantierDialog(context, chantier);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, chantier);
                            }
                          },
                        ),
                        onTap: () {
                          // Navigation vers les détails du chantier
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateChantierDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String nChantier = '';
    double? depenseMax;
    String? remarque;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau chantier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom du chantier',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onSaved: (value) => nChantier = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Budget maximum (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      depenseMax = double.tryParse(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Remarque (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  onSaved: (value) => remarque = value,
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
                ref.read(chantierListProvider.notifier).createChantier(
                  nChantier,
                  depenseMax,
                  remarque,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditChantierDialog(BuildContext context, Chantier chantier) async {
    final formKey = GlobalKey<FormState>();
    String nChantier = chantier.nChantier;
    double? depenseMax = chantier.depenseMax;
    String? remarque = chantier.remarque;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le chantier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nChantier,
                  decoration: const InputDecoration(
                    labelText: 'Nom du chantier',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onSaved: (value) => nChantier = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: depenseMax?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Budget maximum (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      depenseMax = double.tryParse(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: remarque,
                  decoration: const InputDecoration(
                    labelText: 'Remarque (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  onSaved: (value) => remarque = value,
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
                ref.read(chantierListProvider.notifier).updateChantier(
                  chantier.copyWith(
                    nChantier: nChantier,
                    depenseMax: depenseMax,
                    remarque: remarque,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Chantier chantier) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le chantier'),
        content: Text('Voulez-vous vraiment supprimer le chantier "${chantier.nChantier}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(chantierListProvider.notifier).deleteChantier(chantier.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}