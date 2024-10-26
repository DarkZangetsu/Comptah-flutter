import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoForm extends StatefulWidget {
  final Todo? initialTodo;
  final String entrepriseId;  // Ajout du paramètre entrepriseId
  final Function(String description, DateTime? dueDate, int priorite, double? montant, String? chantierId) onSubmit;

  const TodoForm({
    Key? key,
    this.initialTodo,
    required this.entrepriseId,  // Ajout du paramètre requis
    required this.onSubmit,
  }) : super(key: key);

  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  late TextEditingController _descriptionController;
  late TextEditingController _montantController;
  DateTime? _dueDate;
  int _priorite = 1;
  String? _selectedChantierId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialTodo?.description);
    _montantController = TextEditingController(
      text: widget.initialTodo?.montant?.toString() ?? '',
    );
    _dueDate = widget.initialTodo?.dueDate;
    _priorite = widget.initialTodo?.priorite ?? 1;
    _selectedChantierId = widget.initialTodo?.idChantier;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date d\'échéance'),
            subtitle: Text(_dueDate?.toString() ?? 'Non définie'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _priorite,
            decoration: const InputDecoration(labelText: 'Priorité'),
            items: List.generate(3, (index) => index + 1).map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text('Priorité $p'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _priorite = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _montantController,
            decoration: const InputDecoration(labelText: 'Montant'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: DatabaseHelper().getAvailableChantiers(widget.entrepriseId),  // Utilisation de l'entrepriseId passé
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur: ${snapshot.error}');
              } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return const Text('Aucun chantier disponible');
              } else {
                final chantiers = snapshot.data as List<Chantier>;
                return DropdownButtonFormField<String>(
                  value: _selectedChantierId,
                  decoration: const InputDecoration(labelText: 'Chantier'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Aucun chantier'),
                    ),
                    ...chantiers.map((chantier) {
                      return DropdownMenuItem(
                        value: chantier.id,
                        child: Text(chantier.nChantier),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedChantierId = value);
                  },
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('La description est requise')),
                    );
                    return;
                  }

                  double? montant;
                  if (_montantController.text.isNotEmpty) {
                    try {
                      montant = double.parse(_montantController.text);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Montant invalide')),
                      );
                      return;
                    }
                  }

                  widget.onSubmit(
                    _descriptionController.text,
                    _dueDate,
                    _priorite,
                    montant,
                    _selectedChantierId,
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}