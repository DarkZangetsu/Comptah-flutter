import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onStatusChanged;

  const TodoListItem({
    Key? key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChanged,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (todo.priorite) {
      case 3:
        return Colors.red.shade100;
      case 2:
        return Colors.orange.shade100;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getPriorityColor(),
      child: ListTile(
        onTap: onTap,
        title: Text(
          todo.description,
          style: TextStyle(
            decoration: todo.status == 'TERMINÉ' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.dueDate != null)
              Text(
                'Échéance: ${todo.dueDate?.toString().split(' ')[0]}',
                style: TextStyle(
                  color: todo.dueDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : null,
                ),
              ),
            if (todo.montant != null)
              Text('Montant: ${todo.montant?.toStringAsFixed(2)} €'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              onSelected: onStatusChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'EN_COURS',
                  child: Text('En cours'),
                ),
                const PopupMenuItem(
                  value: 'TERMINÉ',
                  child: Text('Terminé'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: todo.status == 'TERMINÉ' ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todo.status == 'TERMINÉ' ? 'Terminé' : 'En cours',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
