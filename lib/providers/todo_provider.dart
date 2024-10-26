import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseHelper _db;
  List<Todo> _todos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedChantier;

  TodoProvider(this._db);

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  String? get selectedChantier => _selectedChantier;

  Future<void> loadTodos(String entrepriseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _db.getTodos(entrepriseId);
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTodos(String entrepriseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _db.searchTodos(
        entrepriseId,
        searchTerm: _searchQuery.isEmpty ? null : _searchQuery,
        status: _selectedStatus,
        chantierId: _selectedChantier,
      );
    } catch (e) {
      print('Error searching todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await _db.createTodo(todo);
      _todos.insert(0, newTodo);
      notifyListeners();
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _db.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _db.deleteTodo(todoId);
      _todos.removeWhere((todo) => todo.id == todoId);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  void setSelectedStatus(String? status) {
    _selectedStatus = status;
  }

  void setSelectedChantier(String? chantierId) {
    _selectedChantier = chantierId;
  }
}
