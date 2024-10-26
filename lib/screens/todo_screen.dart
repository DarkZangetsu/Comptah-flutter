import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/affectation_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/todo_form.dart';

// Créez un ChangeNotifierProvider pour TodoProvider
final todoProvider = ChangeNotifierProvider<TodoProvider>((ref) {
  final db = ref.read(databaseHelperProvider);
  return TodoProvider(db);
});

class TodoScreen extends ConsumerStatefulWidget {
  final String entrepriseId;

  const TodoScreen({Key? key, required this.entrepriseId}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTodos());
  }

  void _loadTodos() {
    ref.read(todoProvider).loadTodos(widget.entrepriseId);
  }

  @override
  Widget build(BuildContext context) {
    final todoProviderData = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: todoProviderData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                Future.microtask(() {
                  ref.read(todoProvider).setSearchQuery(value);
                  ref.read(todoProvider).searchTodos(widget.entrepriseId);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todoProviderData.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProviderData.todos[index];
                return TodoListItem(
                  todo: todo,
                  onTap: () => _showEditDialog(context, todo),
                  onDelete: () => _deleteTodo(context, todo.id),
                  onStatusChanged: (newStatus) =>
                      _updateTodoStatus(todo, newStatus),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final todoNotifier = ref.read(todoProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les tâches'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: todoNotifier.selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: 'EN_COURS', child: Text('En cours')),
                DropdownMenuItem(value: 'TERMINE', child: Text('Terminé')),
              ],
              onChanged: (value) {
                Future.microtask(() {
                  todoNotifier.setSelectedStatus(value);
                  todoNotifier.searchTodos(widget.entrepriseId);
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Future.microtask(() {
                todoNotifier.setSelectedStatus(null);
                todoNotifier.setSelectedChantier(null);
                todoNotifier.searchTodos(widget.entrepriseId);
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final todoNotifier = ref.read(todoProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Tâche'),
        content: TodoForm(
          entrepriseId: widget.entrepriseId,  // Ajout de l'entrepriseId
          onSubmit: (description, dueDate, priorite, montant, chantierId) async {
            final todo = Todo(
              entrepriseId: widget.entrepriseId,
              description: description,
              dueDate: dueDate,
              priorite: priorite,
              montant: montant,
              idChantier: chantierId,
              createdAt: DateTime.now(), id: '',
            );
            await todoNotifier.addTodo(todo);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    final todoNotifier = ref.read(todoProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la tâche'),
        content: TodoForm(
          initialTodo: todo,
          entrepriseId: widget.entrepriseId,  // Ajout de l'entrepriseId
          onSubmit: (description, dueDate, priorite, montant, chantierId) async {
            final updatedTodo = todo.copyWith(
              description: description,
              dueDate: dueDate,
              priorite: priorite,
              montant: montant,
              idChantier: chantierId,
            );
            await todoNotifier.updateTodo(updatedTodo);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  Future<void> _deleteTodo(BuildContext context, String todoId) async {
    final todoNotifier = ref.read(todoProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer cette tâche ?'),
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

    if (confirm == true) {
      await todoNotifier.deleteTodo(todoId);
    }
  }

  void _updateTodoStatus(Todo todo, String newStatus) {
    final updatedTodo = todo.copyWith(status: newStatus);
    Future.microtask(() {
      ref.read(todoProvider).updateTodo(updatedTodo);
    });
  }
}
