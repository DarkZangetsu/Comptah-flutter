/*import 'package:flutter/material.dart';
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
        title: const Text('Mes entreprises',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color:Colors.white)),
        backgroundColor: const Color(0xffea6b24),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: Colors.white,),
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
}*/


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
        title: const Text(
          'Mes entreprises',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xffea6b24),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: Colors.white),
            onPressed: () => _showCreateEnterpriseDialog(context, ref),
            tooltip: 'Créer une entreprise',
          ),
        ],
      ),
      body: enterprisesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorContent(theme, error),
        data: (enterprises) {
          return enterprises.isEmpty
              ? _buildEmptyState(context, ref, theme)
              : _buildEnterpriseList(context, enterprises, theme);
        },
      ),
    );
  }

  Widget _buildEnterpriseList(BuildContext context, List<Entreprise> enterprises, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: enterprises.length,
      itemBuilder: (context, index) {
        final enterprise = enterprises[index];
        return GestureDetector(
          onTap: () => _navigateToEnterpriseDashboard(context, enterprise),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/Logo.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enterprise.nom,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créée le: ${_formatDate(enterprise.createdAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, ThemeData theme) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(ThemeData theme, Object error) {
    return Center(
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
            icon: const Icon(Icons.close, color: Colors.black,),
            label: const Text('Annuler', style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _createAndNavigateToEnterprise(context, ref, controller.text);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check, color: Color(0xffea6b24),),
            label: const Text('Créer', style: TextStyle(color: Color(0xffea6b24)),),
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
