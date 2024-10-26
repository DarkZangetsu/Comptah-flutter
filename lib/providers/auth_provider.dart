import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/users.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Users?>>((ref) {
  return AuthNotifier(ref.watch(databaseHelperProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<Users?>> {
  final DatabaseHelper _dbHelper;

  AuthNotifier(this._dbHelper) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final userData = await _dbHelper.getCurrentUser();
      if (userData != null) {
        state = AsyncValue.data(userData);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _dbHelper.signIn(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _dbHelper.signUp(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await _dbHelper.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
