import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chantier.dart';
import '../../providers/chantier_provider.dart';
import 'chantier_detail_screen.dart';
import 'chantier_form_screen.dart';

class ChantierListScreen extends ConsumerWidget {
  const ChantierListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chantiersAsync = ref.watch(chantiersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chantiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implémenter le filtre
            },
          ),
        ],
      ),
      body: chantiersAsync.when(
        data: (chantiers) => RefreshIndicator(
          onRefresh: () => ref.refresh(chantiersProvider.future),
          child: ListView.builder(
            itemCount: chantiers.length,
            itemBuilder: (context, index) {
              final chantier = chantiers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(chantier.nChantier),
                  subtitle: Text('Budget max: ${chantier.depenseMax?.toString() ?? "Non défini"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChantierFormScreen(chantier: chantier),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmerSuppression(context, ref, chantier),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChantierDetailScreen(chantier: chantier),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChantierFormScreen()),
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(BuildContext context, WidgetRef ref, Chantier chantier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer le chantier ${chantier.nChantier} ?'),
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

    if (result == true) {
      ref.read(chantierControllerProvider.notifier).deleteChantier(chantier.id ?? 'default_id');
    }
  }
}

