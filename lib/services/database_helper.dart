// lib/services/database_helper.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/affectation.dart';
import '../models/caisse.dart';
import '../models/chantier.dart';
import '../models/depense.dart';
import '../models/emprunt_entree.dart';
import '../models/emprunt_sortie.dart';
import '../models/mouvement.dart';
import '../models/paiement.dart';
import '../models/personnel.dart';

class DatabaseHelper {
  final SupabaseClient _client = SupabaseConfig.client;

  // Chantier Methods
  Future<List<Chantier>> getAllChantiers() async {
    try {
      final response = await _client
          .from('chantier')
          .select()
          .order('n_chantier', ascending: true);

      print('Response from getAllChantiers: $response'); // Debug

      return (response as List).map((item) => Chantier.fromJson(item)).toList();
    } catch (e) {
      print('Erreur dans getAllChantiers: $e');
      throw Exception('Impossible de récupérer les chantiers: $e');
    }
  }

  Future<Chantier> createChantier(Chantier chantier) async {
    try {
      // Pour la création, on n'envoie pas l'ID - il sera généré par Supabase
      final data = {
        'n_chantier': chantier.nChantier,
        'depense_max': chantier.depenseMax,
        'remarque': chantier.remarque,
      };

      print('Données à insérer: $data'); // Debug

      final response = await _client
          .from('chantier')
          .insert(data)
          .select()
          .single();

      print('Response from createChantier: $response'); // Debug

      return Chantier.fromJson(response);
    } catch (e) {
      print('Erreur dans createChantier: $e');
      throw Exception('Impossible de créer le chantier: $e');
    }
  }

  Future<void> updateChantier(Chantier chantier) async {
    try {
      if (chantier.id == null) throw Exception('ID du chantier manquant');

      final data = {
        'n_chantier': chantier.nChantier,
        'depense_max': chantier.depenseMax,
        'remarque': chantier.remarque,
      };

      print('Données à mettre à jour pour ID ${chantier.id}: $data'); // Debug

      final response = await _client
          .from('chantier')
          .update(data)
          .eq('id', chantier.id as Object)
          .select()
          .single();

      print('Response from updateChantier: $response'); // Debug
    } catch (e) {
      print('Erreur dans updateChantier: $e');
      throw Exception('Impossible de mettre à jour le chantier: $e');
    }
  }

  Future<void> deleteChantier(String id) async {  // UUID as String
    try {
      await _client
          .from('chantier')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Erreur dans deleteChantier: $e');
      throw Exception('Impossible de supprimer le chantier: $e');
    }
  }

  // Mouvement Methods
  Future<List<Mouvement>> getMouvementsByDateRange(DateTime start, DateTime end) async {
    final response = await _client
        .from('mouvement')
        .select()
        .gte('jour', start.toIso8601String())
        .lte('jour', end.toIso8601String())
        .order('jour', ascending: false);
    return (response as List).map((item) => Mouvement.fromJson(item)).toList();
  }

  Future<Mouvement> createMouvement(Mouvement mouvement) async {
    final response = await _client
        .from('mouvement')
        .insert(mouvement.toJson())
        .select()
        .single();
    return Mouvement.fromJson(response);
  }

  // Caisse Methods
  Future<List<Caisse>> getCaisseEntries(DateTime date) async {
    final response = await _client
        .from('caisse')
        .select()
        .eq('jour', date.toIso8601String())
        .order('jour', ascending: false);
    return (response as List).map((item) => Caisse.fromJson(item)).toList();
  }

  Future<double> getCaisseBalance() async {
    final response = await _client.rpc('calculate_caisse_balance');
    return response as double;
  }

  // Personnel Methods
  Future<List<Personnel>> getAllPersonnel() async {
    final response = await _client
        .from('personnel')
        .select()
        .order('nom', ascending: true);
    return (response as List).map((item) => Personnel.fromJson(item)).toList();
  }

  // Affectation Methods
  Future<List<Affectation>> getAffectationsByChantier(String chantierId) async {
    final response = await _client
        .from('affectation')
        .select('*, personnel(*)')
        .eq('id_chantier', chantierId);
    return (response as List).map((item) => Affectation.fromJson(item)).toList();
  }

  // Paiement Methods
  Future<List<Paiement>> getPaiementsByAffectation(String affectationId) async {
    final response = await _client
        .from('paiement')
        .select()
        .eq('id_affectation', affectationId)
        .order('jour', ascending: false);
    return (response as List).map((item) => Paiement.fromJson(item)).toList();
  }

  // Emprunt Methods
  Future<List<EmpruntEntree>> getEmpruntsEntree() async {
    final response = await _client
        .from('emprunt_entree')
        .select('*, remboursement_ee(*)')
        .order('jour', ascending: false);
    return (response as List).map((item) => EmpruntEntree.fromJson(item)).toList();
  }

  Future<List<EmpruntSortie>> getEmpruntsSortie() async {
    final response = await _client
        .from('emprunt_sortie')
        .select('*, remboursement_es(*)')
        .order('jour', ascending: false);
    return (response as List).map((item) => EmpruntSortie.fromJson(item)).toList();
  }

  // Depense Methods
  Future<List<Depense>> getDepensesByChantier(String chantierId) async {
    final response = await _client
        .from('depense')
        .select()
        .eq('id_chantier', chantierId)
        .order('jour', ascending: false);
    return (response as List).map((item) => Depense.fromJson(item)).toList();
  }
}