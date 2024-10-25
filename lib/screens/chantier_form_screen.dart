import '../models/chantier.dart';import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chantier_provider.dart';



class ChantierFormScreen extends ConsumerStatefulWidget {
  final Chantier? chantier;

  const ChantierFormScreen({Key? key, this.chantier}) : super(key: key);

  @override
  ChantierFormScreenState createState() => ChantierFormScreenState();
}

class ChantierFormScreenState extends ConsumerState<ChantierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nChantierController;
  late TextEditingController _depenseMaxController;
  late TextEditingController _remarqueController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nChantierController = TextEditingController(text: widget.chantier?.nChantier);
    _depenseMaxController = TextEditingController(
      text: widget.chantier?.depenseMax?.toString() ?? '',
    );
    _remarqueController = TextEditingController(text: widget.chantier?.remarque ?? '');
  }

  @override
  void dispose() {
    _nChantierController.dispose();
    _depenseMaxController.dispose();
    _remarqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chantier == null ? 'Nouveau Chantier' : 'Modifier Chantier'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nChantierController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du chantier',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom de chantier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _depenseMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Budget maximum',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = double.tryParse(value);
                      if (number == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      if (number < 0) {
                        return 'Le budget ne peut pas être négatif';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarqueController,
                  decoration: const InputDecoration(
                    labelText: 'Remarques',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: Text(widget.chantier == null ? 'Créer' : 'Mettre à jour'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Pour la création, on laisse l'id à null
        final chantierData = Chantier(
          id: widget.chantier?.id,  // null pour création, existant pour mise à jour
          nChantier: _nChantierController.text,
          depenseMax: _depenseMaxController.text.isNotEmpty
              ? double.parse(_depenseMaxController.text)
              : null,
          remarque: _remarqueController.text.isNotEmpty
              ? _remarqueController.text
              : null,
        );

        print('Données du chantier à soumettre: ${chantierData.toJson()}'); // Debug

        if (widget.chantier == null) {
          // Création
          await ref.read(chantierControllerProvider.notifier).createChantier(chantierData);
          print('Chantier créé avec succès'); // Debug
        } else {
          // Mise à jour
          await ref.read(chantierControllerProvider.notifier).updateChantier(chantierData);
          print('Chantier mis à jour avec succès'); // Debug
        }

        // Rafraîchir la liste des chantiers
        ref.refresh(chantiersProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.chantier == null
                  ? 'Chantier créé avec succès'
                  : 'Chantier mis à jour avec succès'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Erreur lors de la soumission: $e'); // Debug
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}