import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chantier.dart';
import '../services/database_helper.dart';
import 'auth_provider.dart';

final chantierListProvider = StateNotifierProvider<ChantierNotifier, AsyncValue<List<Chantier>>>((ref) {
  return ChantierNotifier(ref.watch(databaseHelperProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class ChantierNotifier extends StateNotifier<AsyncValue<List<Chantier>>> {
  final DatabaseHelper _db;
  String? _currentEntrepriseId;

  ChantierNotifier(this._db) : super(const AsyncValue.loading());

  Future<void> loadChantiers(String entrepriseId) async {
    _currentEntrepriseId = entrepriseId;
    state = const AsyncValue.loading();
    try {
      final chantiers = await _db.getChantiers(entrepriseId);
      state = AsyncValue.data(chantiers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchChantiers(String query) async {
    if (_currentEntrepriseId == null) return;
    state = const AsyncValue.loading();
    try {
      final chantiers = await _db.searchChantiers(_currentEntrepriseId!, query);
      state = AsyncValue.data(chantiers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createChantier(String nChantier, double? depenseMax, String? remarque) async {
    if (_currentEntrepriseId == null) return;
    try {
      final newChantier = await _db.createChantier(
        _currentEntrepriseId!,
        nChantier,
        depenseMax,
        remarque,
      );
      state.whenData((chantiers) {
        state = AsyncValue.data([newChantier, ...chantiers]);
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> deleteChantier(String chantierId) async {
    try {
      await _db.deleteChantier(chantierId);
      state.whenData((chantiers) {
        state = AsyncValue.data(
          chantiers.where((c) => c.id != chantierId).toList(),
        );
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> updateChantier(Chantier updatedChantier) async {
    if (_currentEntrepriseId == null) return;
    try {
      await _db.updateChantier(updatedChantier);
      state.whenData((chantiers) {
        final updatedList = chantiers.map((c) {
          return c.id == updatedChantier.id ? updatedChantier : c;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }
}
