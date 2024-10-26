import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/depense.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

final depensesProvider = StateNotifierProvider.family<DepensesNotifier, AsyncValue<List<Depense>>, String>(
      (ref, entrepriseId) => DepensesNotifier(ref.watch(databaseHelperProvider), entrepriseId),
);

class DepensesNotifier extends StateNotifier<AsyncValue<List<Depense>>> {
  final DatabaseHelper _databaseHelper;
  final String entrepriseId;

  DepensesNotifier(this._databaseHelper, this.entrepriseId) : super(const AsyncValue.loading()) {
    loadDepenses();
  }

  Future<void> loadDepenses() async {
    try {
      state = const AsyncValue.loading();
      final depenses = await _databaseHelper.getDepenses(entrepriseId);
      state = AsyncValue.data(
        depenses.map((data) => Depense.fromJson(data)).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addDepense(Depense depense) async {
    try {
      final newDepense = await _databaseHelper.createDepense(depense);
      state.whenData((depenses) {
        state = AsyncValue.data([newDepense, ...depenses]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDepense(Depense depense) async {
    try {
      await _databaseHelper.updateDepense(depense);
      state.whenData((depenses) {
        state = AsyncValue.data([
          for (final d in depenses)
            if (d.id == depense.id) depense else d
        ]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDepense(String depenseId) async {
    try {
      await _databaseHelper.deleteDepense(depenseId);
      state.whenData((depenses) {
        state = AsyncValue.data(
          depenses.where((d) => d.id != depenseId).toList(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchDepenses({
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? chantierId,
    String? type,
  }) async {
    try {
      state = const AsyncValue.loading();
      final depenses = await _databaseHelper.searchDepenses(
        entrepriseId,
        searchTerm: searchTerm,
        dateDebut: dateDebut,
        dateFin: dateFin,
        chantierId: chantierId,
        type: type,
      );
      state = AsyncValue.data(
        depenses.map((data) => Depense.fromJson(data)).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}