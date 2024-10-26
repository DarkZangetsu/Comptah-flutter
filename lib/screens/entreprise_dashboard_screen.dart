import 'package:flutter/material.dart';
import 'package:project/screens/revenu_screen.dart';
import 'package:project/screens/todo_screen.dart';
import 'package:project/screens/personnel_screen.dart';
import '../models/entreprise.dart';
import 'affectation_screen.dart';
import 'chantier_screen.dart';
import 'depense_screen.dart';

class EnterpriseDashboardScreen extends StatelessWidget {
  final Entreprise enterprise;

  const EnterpriseDashboardScreen({Key? key, required this.enterprise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(enterprise.nom),
        elevation: 0,
      ),
      drawer: _buildDrawer(context, theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bienvenue dans le tableau de bord de ${enterprise.nom}!',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Revenus',
                  Icons.attach_money,
                  Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RevenuScreen(entrepriseId: enterprise.id),
                          ),
                        );
                      },
                ),
                _buildMenuCard(
                  context,
                  'Dépenses',
                  Icons.money_off,
                  Colors.red,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DepenseScreen(entrepriseId: enterprise.id),
                          ),
                        );
                      },
                ),
                _buildMenuCard(
                  context,
                  'Journal',
                  Icons.book,
                  Colors.blue,
                      () {},
                ),
                _buildMenuCard(
                  context,
                  'Affectations',
                  Icons.assignment,
                  Colors.orange,
                      () {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AffectationScreen(entrepriseId: enterprise.id),
                        ),
                      );},
                ),
                _buildMenuCard(
                  context,
                  'Todo',
                  Icons.check_circle,
                  Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoScreen(entrepriseId: enterprise.id),
                          ),
                        );
                      },
                ),
                _buildMenuCard(
                  context,
                  'Personnel',
                  Icons.people,
                  Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonnelScreen(entrepriseId: enterprise.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    enterprise.nom[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  enterprise.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            'Changer d\'entreprise',
            Icons.business_center,
                () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          _buildDrawerItem(
            context,
            'Chantiers',
            Icons.construction,
                () {
              Navigator.pop(context);
              _navigateToChantiers(context);
            },
          ),
          _buildDrawerItem(
            context,
            'Paramètres',
            Icons.settings,
                () {
              Navigator.pop(context);
              // Navigation vers les paramètres
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            'À propos',
            Icons.info,
                () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateToChantiers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChantierScreen(entrepriseId: enterprise.id),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${enterprise.nom}'),
            const SizedBox(height: 8),
            Text('Créée le: ${_formatDate(enterprise.createdAt)}'),
            const SizedBox(height: 16),
            const Text('Version de l\'application: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
