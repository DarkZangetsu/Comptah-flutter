import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affectation.dart';
import '../models/chantier.dart';
import '../models/depense.dart';
import '../providers/chantier_provider.dart';

class ChantierDetailScreen extends ConsumerWidget {
  final Chantier chantier;

  const ChantierDetailScreen({Key? key, required this.chantier}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depenses = ref.watch(depensesParChantierProvider(chantier.id ?? 'default_id'));
    final affectations = ref.watch(affectationsParChantierProvider(chantier.id ?? 'default_id'));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(chantier.nChantier),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Informations'),
              Tab(text: 'Dépenses'),
              Tab(text: 'Personnel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: 'Budget Maximum',
                    value: chantier.depenseMax?.toString() ?? 'Non défini',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    title: 'Remarques',
                    value: chantier.remarque ?? 'Aucune remarque',
                  ),
                ],
              ),
            ),
            depenses.when(
              data: (list) => DepensesList(depenses: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
            affectations.when(
              data: (list) => AffectationsList(affectations: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ],
        ),
      ),
    );
  }

  AffectationsList({required List<Affectation> affectations}) {}

  DepensesList({required List<Depense> depenses}) {}
}

// Widgets utilitaires
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
