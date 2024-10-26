import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entreprise.dart';
import '../services/database_helper.dart';
import 'auth_provider.dart';

final enterpriseListProvider = StateNotifierProvider<EnterpriseNotifier, AsyncValue<List<Entreprise>>>((ref) {
  return EnterpriseNotifier(ref.watch(databaseHelperProvider));
});

class EnterpriseNotifier extends StateNotifier<AsyncValue<List<Entreprise>>> {
  final DatabaseHelper _dbHelper;

  EnterpriseNotifier(this._dbHelper) : super(const AsyncValue.loading()) {
    loadEnterprises();
  }

  Future<void> loadEnterprises() async {
    try {
      state = const AsyncValue.loading();
      final enterprises = await _dbHelper.getUserEnterprises();
      state = AsyncValue.data(enterprises);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Entreprise> createEnterprise(String nom) async {
    try {
      final newEnterprise = await _dbHelper.createEnterprise(nom);
      state.whenData((enterprises) {
        state = AsyncValue.data([...enterprises, newEnterprise]);
      });
      return newEnterprise;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}