import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/revenu.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

final revenusProvider = StateNotifierProvider.family<RevenusNotifier, AsyncValue<List<Revenu>>, String>(
      (ref, entrepriseId) => RevenusNotifier(ref.watch(databaseHelperProvider), entrepriseId),
);

class RevenusNotifier extends StateNotifier<AsyncValue<List<Revenu>>> {
  final DatabaseHelper _databaseHelper;
  final String entrepriseId;

  RevenusNotifier(this._databaseHelper, this.entrepriseId) : super(const AsyncValue.loading()) {
    loadRevenus();
  }

  Future<void> loadRevenus() async {
    try {
      state = const AsyncValue.loading();
      final revenus = await _databaseHelper.getRevenus(entrepriseId);
      state = AsyncValue.data(
        revenus.map((data) => Revenu.fromJson(data)).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRevenu(Revenu revenu) async {
    try {
      final newRevenu = await _databaseHelper.createRevenu(revenu);
      state.whenData((revenus) {
        state = AsyncValue.data([newRevenu, ...revenus]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRevenu(Revenu revenu) async {
    try {
      await _databaseHelper.updateRevenu(revenu);
      state.whenData((revenus) {
        state = AsyncValue.data([
          for (final r in revenus)
            if (r.id == revenu.id) revenu else r
        ]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRevenu(String revenuId) async {
    try {
      await _databaseHelper.deleteRevenu(revenuId);
      state.whenData((revenus) {
        state = AsyncValue.data(
          revenus.where((r) => r.id != revenuId).toList(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchRevenus({
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? type,
  }) async {
    try {
      state = const AsyncValue.loading();
      final revenus = await _databaseHelper.searchRevenus(
        entrepriseId,
        searchTerm: searchTerm,
        dateDebut: dateDebut,
        dateFin: dateFin,
        type: type,
      );
      state = AsyncValue.data(
        revenus.map((data) => Revenu.fromJson(data)).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
