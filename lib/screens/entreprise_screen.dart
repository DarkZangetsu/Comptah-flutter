import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/entreprise_provider.dart';
import '../models/entreprise.dart';
import 'entreprise_dashboard_screen.dart';

class EnterpriseSelectionScreen extends ConsumerWidget {
  const EnterpriseSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterprisesState = ref.watch(enterpriseListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes entreprises'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showCreateEnterpriseDialog(context, ref),
            tooltip: 'Créer une entreprise',
          ),
        ],
      ),
      body: enterprisesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur: $error',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (enterprises) {
          if (enterprises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune entreprise trouvée',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateEnterpriseDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une nouvelle entreprise'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: enterprises.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final enterprise = enterprises[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      enterprise.nom[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    enterprise.nom,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Créée le: ${_formatDate(enterprise.createdAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _navigateToEnterpriseDashboard(context, enterprise),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showCreateEnterpriseDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.business,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Nouvelle entreprise'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom de l\'entreprise',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_center),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _createAndNavigateToEnterprise(context, ref, controller.text);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAndNavigateToEnterprise(
      BuildContext context,
      WidgetRef ref,
      String enterpriseName,
      ) async {
    final enterpriseNotifier = ref.read(enterpriseListProvider.notifier);
    final newEnterprise = await enterpriseNotifier.createEnterprise(enterpriseName);
    _navigateToEnterpriseDashboard(context, newEnterprise);
  }

  void _navigateToEnterpriseDashboard(BuildContext context, Entreprise enterprise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterpriseDashboardScreen(enterprise: enterprise),
      ),
    );
  }
}
