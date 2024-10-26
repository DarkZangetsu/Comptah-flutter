import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/personnel.dart';
import '../services/database_helper.dart';
import 'auth_provider.dart';

final personnelListProvider = StateNotifierProvider<PersonnelNotifier, AsyncValue<List<Personnel>>>((ref) {
  return PersonnelNotifier(ref.watch(databaseHelperProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class PersonnelNotifier extends StateNotifier<AsyncValue<List<Personnel>>> {
  final DatabaseHelper _db;
  String? _currentEntrepriseId;

  PersonnelNotifier(this._db) : super(const AsyncValue.loading());

  Future<void> loadPersonnel(String entrepriseId) async {
    _currentEntrepriseId = entrepriseId;
    state = const AsyncValue.loading();
    try {
      final personnel = await _db.getPersonnel(entrepriseId);
      state = AsyncValue.data(personnel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchPersonnel(String entrepriseId, String query) async {
    if (_currentEntrepriseId == null) return;
    state = const AsyncValue.loading();
    try {
      final personnel = await _db.searchPersonnel(entrepriseId, query);
      state = AsyncValue.data(personnel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPersonnel(String entrepriseId, String nom, String? remarque) async {
    if (_currentEntrepriseId == null) return;
    try {
      final newPersonnel = await _db.createPersonnel(
        entrepriseId,
        nom,
        remarque,
      );
      state.whenData((personnel) {
        state = AsyncValue.data([newPersonnel, ...personnel]);
      });
    } catch (e, stack) {
      // Optionnel : Mettre à jour l'état avec l'erreur
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePersonnel(Personnel updatedPersonnel) async {
    if (_currentEntrepriseId == null) return;
    try {
      await _db.updatePersonnel(updatedPersonnel);
      state.whenData((personnel) {
        final updatedList = personnel.map((p) {
          return p.id == updatedPersonnel.id ? updatedPersonnel : p;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePersonnel(String personnelId) async {
    try {
      await _db.deletePersonnel(personnelId);
      state.whenData((personnel) {
        state = AsyncValue.data(
          personnel.where((p) => p.id != personnelId).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Méthode utilitaire pour rafraîchir la liste
  Future<void> refresh() async {
    if (_currentEntrepriseId == null) return;
    await loadPersonnel(_currentEntrepriseId!);
  }
}