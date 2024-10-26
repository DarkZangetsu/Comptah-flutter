import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/affectation.dart';
import '../models/chantier.dart';
import '../models/personnel.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

// Provider pour la liste des affectations
final affectationListProvider =
StateNotifierProvider<AffectationNotifier, AsyncValue<List<Affectation>>>(
      (ref) => AffectationNotifier(ref.watch(databaseHelperProvider)),
);

// Provider pour les filtres
final affectationFiltersProvider = StateProvider((ref) => AffectationFilters());

// Provider pour la liste du personnel disponible
final availablePersonnelProvider = FutureProvider.family<List<Personnel>, String>(
      (ref, entrepriseId) async {
    final dbHelper = ref.watch(databaseHelperProvider);
    return await dbHelper.getAvailablePersonnel(entrepriseId);
  },
);

// Provider pour la liste des chantiers disponibles
final availableChangiersProvider = FutureProvider.family<List<Chantier>, String>(
      (ref, entrepriseId) async {
    final dbHelper = ref.watch(databaseHelperProvider);
    return await dbHelper.getAvailableChantiers(entrepriseId);
  },
);

class AffectationFilters {
  final String? searchTerm;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? chantierId;
  final String? tache;

  AffectationFilters({
    this.searchTerm,
    this.dateDebut,
    this.dateFin,
    this.chantierId,
    this.tache,
  });

  AffectationFilters copyWith({
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? chantierId,
    String? tache,
  }) {
    return AffectationFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      chantierId: chantierId ?? this.chantierId,
      tache: tache ?? this.tache,
    );
  }
}

class AffectationNotifier extends StateNotifier<AsyncValue<List<Affectation>>> {
  final DatabaseHelper _databaseHelper;

  AffectationNotifier(this._databaseHelper) : super(const AsyncValue.loading());

  Future<void> loadAffectations(String entrepriseId) async {
    try {
      state = const AsyncValue.loading();
      final data = await _databaseHelper.getAffectations(entrepriseId);
      final affectations = data.map((item) => Affectation.fromJson(item)).toList();
      state = AsyncValue.data(affectations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchAffectations(
      String entrepriseId, {
        String? searchTerm,
        DateTime? dateDebut,
        DateTime? dateFin,
        String? chantierId,
        String? tache,
      }) async {
    try {
      state = const AsyncValue.loading();
      final data = await _databaseHelper.searchAffectations(
        entrepriseId,
        searchTerm: searchTerm,
        dateDebut: dateDebut,
        dateFin: dateFin,
        chantierId: chantierId,
        tache: tache,
      );
      final affectations = data.map((item) => Affectation.fromJson(item)).toList();
      state = AsyncValue.data(affectations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAffectation(Affectation affectation) async {
    try {
      await _databaseHelper.createAffectation(affectation);
      await loadAffectations(affectation.entrepriseId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAffectation(Affectation affectation) async {
    try {
      await _databaseHelper.updateAffectation(affectation);
      await loadAffectations(affectation.entrepriseId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAffectation(String id, String entrepriseId) async {
    try {
      await _databaseHelper.deleteAffectation(id);
      await loadAffectations(entrepriseId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}