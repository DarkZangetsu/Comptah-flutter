import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chantier.dart';
import '../models/depense.dart';
import '../models/affectation.dart';
import '../services/database_helper.dart';

// Base database provider
final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

// Provider pour la liste des chantiers avec gestion du rechargement
final chantiersProvider = FutureProvider<List<Chantier>>((ref) async {
  try {
    final chantiers = await ref.read(databaseProvider).getAllChantiers();
    return chantiers;
  } catch (e, stack) {
    print('Erreur dans chantiersProvider: $e');
    print('Stack trace: $stack');
    throw Exception('Échec du chargement des chantiers: $e');
  }
});

// Provider pour les dépenses par chantier
final depensesParChantierProvider = FutureProvider.family<List<Depense>, String>((ref, String chantierId) async {
  try {
    return await ref.read(databaseProvider).getDepensesByChantier(chantierId);
  } catch (e, stack) {
    print('Erreur dans depensesParChantierProvider: $e');
    print('Stack trace: $stack');
    throw Exception('Échec du chargement des dépenses: $e');
  }
});

// Provider pour les affectations par chantier
final affectationsParChantierProvider = FutureProvider.family<List<Affectation>, String>((ref, String chantierId) async {
  try {
    return await ref.read(databaseProvider).getAffectationsByChantier(chantierId);
  } catch (e, stack) {
    print('Erreur dans affectationsParChantierProvider: $e');
    print('Stack trace: $stack');
    throw Exception('Échec du chargement des affectations: $e');
  }
});

// Controller pour la gestion des opérations CRUD
class ChantierController extends StateNotifier<AsyncValue<void>> {
  final DatabaseHelper _db;
  final Ref _ref;

  ChantierController(this._db, this._ref) : super(const AsyncValue.data(null));

  Future<Chantier> createChantier(Chantier chantier) async {
    state = const AsyncValue.loading();
    try {
      final createdChantier = await _db.createChantier(chantier);
      // Invalider le cache des chantiers pour forcer un rechargement
      _ref.invalidate(chantiersProvider);
      state = const AsyncValue.data(null);
      return createdChantier;
    } catch (e, stack) {
      print('Erreur dans createChantier: $e');
      print('Stack trace: $stack');
      state = AsyncValue.error(e, stack);
      throw Exception('Échec de la création du chantier: $e');
    }
  }

  Future<void> updateChantier(Chantier chantier) async {
    state = const AsyncValue.loading();
    try {
      await _db.updateChantier(chantier);
      // Invalider le cache des chantiers pour forcer un rechargement
      _ref.invalidate(chantiersProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('Erreur dans updateChantier: $e');
      print('Stack trace: $stack');
      state = AsyncValue.error(e, stack);
      throw Exception('Échec de la mise à jour du chantier: $e');
    }
  }

  Future<void> deleteChantier(String id) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteChantier(id);
      // Invalider le cache des chantiers pour forcer un rechargement
      _ref.invalidate(chantiersProvider);
      // Invalider aussi les providers liés à ce chantier
      _ref.invalidate(depensesParChantierProvider(id));
      _ref.invalidate(affectationsParChantierProvider(id));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      print('Erreur dans deleteChantier: $e');
      print('Stack trace: $stack');
      state = AsyncValue.error(e, stack);
      throw Exception('Échec de la suppression du chantier: $e');
    }
  }
}

// Provider pour le controller avec accès au Ref
final chantierControllerProvider = StateNotifierProvider<ChantierController, AsyncValue<void>>((ref) {
  return ChantierController(ref.read(databaseProvider), ref);
});