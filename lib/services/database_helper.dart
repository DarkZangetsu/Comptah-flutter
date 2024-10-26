import '../config/supabase_config.dart';
import '../models/affectation.dart';
import '../models/chantier.dart';
import '../models/depense.dart';
import '../models/entreprise.dart';
import '../models/personnel.dart';
import '../models/revenu.dart';
import '../models/todo.dart';
import '../models/users.dart';

class DatabaseHelper {
  final _client = SupabaseConfig.client;

  // Auth Methods
  Future<Users?> signUp(
      {required String email, required String password}) async {
    try {
      final userData = await _client
          .from('users')
          .insert({
        'email': email,
        'password': password, // Stockez les mots de passe de manière sécurisée
      })
          .select()
          .single();

      return Users.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Users?> signIn(
      {required String email, required String password}) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password) // Pensez à sécuriser cette vérification
          .single();

      return Users.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Effacez l'état de l'utilisateur dans votre app ici.
  }

  Future<Users?> getCurrentUser() async {
    try {
      final userData = await _client
          .from('users')
          .select()
          .single();

      return Users.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Enterprise Methods
  Future<List<Entreprise>> getUserEnterprises() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _client
          .from('entreprise')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at');

      return (response as List).map((e) => Entreprise.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Entreprise> createEnterprise(String nom) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _client
          .from('entreprise')
          .insert({
        'nom': nom,
        'user_id': currentUser.id,
      })
          .select()
          .single();

      return Entreprise.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Methods Chantier
  Future<List<Chantier>> getChantiers(String entrepriseId) async {
    try {
      final response = await _client
          .from('chantier')
          .select()
          .eq('entreprise_id', entrepriseId)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Chantier.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Chantier> createChantier(String entrepriseId, String nChantier,
      double? depenseMax, String? remarque) async {
    try {
      final response = await _client.from('chantier').insert({
        'entreprise_id': entrepriseId,
        'n_chantier': nChantier,
        'depense_max': depenseMax,
        'remarque': remarque,
      }).select().single();

      return Chantier.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateChantier(Chantier chantier) async {
    try {
      await _client.from('chantier').update({
        'n_chantier': chantier.nChantier,
        'depense_max': chantier.depenseMax,
        'remarque': chantier.remarque,
        // Assurez-vous que cela soit 'chantier.remarque'
      }).eq('id', chantier.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChantier(String chantierId) async {
    try {
      await _client.from('chantier').delete().eq('id', chantierId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Chantier>> searchChantiers(String entrepriseId,
      String query) async {
    try {
      final response = await _client
          .from('chantier')
          .select()
          .eq('entreprise_id', entrepriseId)
          .ilike('n_chantier', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((data) => Chantier.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Personnel Methods
  Future<List<Personnel>> getPersonnel(String entrepriseId) async {
    try {
      final response = await _client
          .from('personnel')
          .select()
          .eq('entreprise_id', entrepriseId)
          .order('nom');

      return (response as List)
          .map((data) => Personnel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Personnel> createPersonnel(String entrepriseId, String nom,
      String? remarque) async {
    try {
      final response = await _client.from('personnel').insert({
        'entreprise_id': entrepriseId,
        'nom': nom,
        'remarque': remarque,
      }).select().single();

      return Personnel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePersonnel(Personnel personnel) async {
    try {
      await _client.from('personnel').update({
        'nom': personnel.nom,
        'remarque': personnel.remarque,
      }).eq('id', personnel.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePersonnel(String personnelId) async {
    try {
      await _client.from('personnel').delete().eq('id', personnelId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Personnel>> searchPersonnel(String entrepriseId,
      String query) async {
    try {
      final response = await _client
          .from('personnel')
          .select()
          .eq('entreprise_id', entrepriseId)
          .ilike('nom', '%$query%')
          .order('nom');

      return (response as List)
          .map((data) => Personnel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }


  // Affectation Methods
  Future<List<Map<String, dynamic>>> getAffectations(
      String entrepriseId) async {
    try {
      final response = await _client
          .from('affectation')
          .select('''
          *,
          personnel:id_personnel(nom),
          chantier:id_chantier(n_chantier)
        ''')
          .eq('entreprise_id', entrepriseId)
          .order('jour', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchAffectations(String entrepriseId, {
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? chantierId,
    String? tache,
  }) async {
    try {
      var query = _client
          .from('affectation')
          .select('''
          *,
          personnel:id_personnel(nom),
          chantier:id_chantier(n_chantier)
        ''')
          .eq('entreprise_id', entrepriseId);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or(
            'personnel.nom.ilike.%$searchTerm%,tache.ilike.%$searchTerm%');
      }

      if (dateDebut != null) {
        query = query.gte('jour', dateDebut.toIso8601String());
      }

      if (dateFin != null) {
        query = query.lte('jour', dateFin.toIso8601String());
      }

      if (chantierId != null) {
        query = query.eq('id_chantier', chantierId);
      }

      if (tache != null && tache.isNotEmpty) {
        query = query.ilike('tache', '%$tache%');
      }

      final response = await query.order('jour', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Affectation> createAffectation(Affectation affectation) async {
    try {
      final response = await _client
          .from('affectation')
          .insert(affectation.toJson())
          .select('''
          *,
          personnel:id_personnel(nom),
          chantier:id_chantier(n_chantier)
        ''')
          .single();

      return Affectation.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAffectation(Affectation affectation) async {
    try {
      await _client
          .from('affectation')
          .update(affectation.toJson())
          .eq('id', affectation.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAffectation(String affectationId) async {
    try {
      await _client
          .from('affectation')
          .delete()
          .eq('id', affectationId);
    } catch (e) {
      rethrow;
    }
  }

// Méthodes utilitaires pour obtenir les listes de personnel et chantiers
  Future<List<Personnel>> getAvailablePersonnel(String entrepriseId) async {
    try {
      final response = await _client
          .from('personnel')
          .select()
          .eq('entreprise_id', entrepriseId)
          .order('nom');

      return (response as List)
          .map((data) => Personnel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Chantier>> getAvailableChantiers(String entrepriseId) async {
    try {
      final response = await _client
          .from('chantier')
          .select()
          .eq('entreprise_id', entrepriseId)
          .order('n_chantier');

      return (response as List).map((data) => Chantier.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }


  // Todos Methods

  Future<List<Todo>> getTodos(String entrepriseId) async {
    try {
      final response = await _client
          .from('todos')
          .select('''
            *,
            chantier:id_chantier(n_chantier)
          ''')
          .eq('entreprise_id', entrepriseId)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Todo.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    try {
      final response = await _client
          .from('todos')
          .insert(todo.toJson())
          .select('''
            *,
            chantier:id_chantier(n_chantier)
          ''')
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _client
          .from('todos')
          .update(todo.toJson())
          .eq('id', todo.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _client
          .from('todos')
          .delete()
          .eq('id', todoId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Todo>> searchTodos(String entrepriseId, {
    String? searchTerm,
    String? status,
    String? chantierId,
  }) async {
    try {
      var query = _client
          .from('todos')
          .select('''
            *,
            chantier:id_chantier(n_chantier)
          ''')
          .eq('entreprise_id', entrepriseId);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.ilike('description', '%$searchTerm%');
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (chantierId != null) {
        query = query.eq('id_chantier', chantierId);
      }

      final response = await query.order('priorite', ascending: false)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Todo.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  //Depenses methods
  Future<List<Map<String, dynamic>>> getDepenses(String entrepriseId) async {
    try {
      final response = await _client
          .from('depense')
          .select('''
          *,
          chantier:id_chantier(n_chantier)
        ''')
          .eq('entreprise_id', entrepriseId)
          .order('jour', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchDepenses(String entrepriseId, {
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? chantierId,
    String? type,
  }) async {
    try {
      var query = _client
          .from('depense')
          .select('''
          *,
          chantier:id_chantier(n_chantier)
        ''')
          .eq('entreprise_id', entrepriseId);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('motif.ilike.%$searchTerm%,n_depense.ilike.%$searchTerm%');
      }

      if (dateDebut != null) {
        query = query.gte('jour', dateDebut.toIso8601String());
      }

      if (dateFin != null) {
        query = query.lte('jour', dateFin.toIso8601String());
      }

      if (chantierId != null) {
        query = query.eq('id_chantier', chantierId);
      }

      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }

      final response = await query.order('jour', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Depense> createDepense(Depense depense) async {
    try {
      final response = await _client
          .from('depense')
          .insert(depense.toJson())
          .select('''
          *,
          chantier:id_chantier(n_chantier)
        ''')
          .single();

      return Depense.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDepense(Depense depense) async {
    try {
      await _client
          .from('depense')
          .update(depense.toJson())
          .eq('id', depense.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDepense(String depenseId) async {
    try {
      await _client
          .from('depense')
          .delete()
          .eq('id', depenseId);
    } catch (e) {
      rethrow;
    }
  }

  //Revenu methods :

  Future<List<Map<String, dynamic>>> getRevenus(String entrepriseId) async {
    try {
      final response = await _client
          .from('revenu')
          .select('''
        *
      ''')
          .eq('entreprise_id', entrepriseId)
          .order('jour', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchRevenus(String entrepriseId, {
    String? searchTerm,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? chantierId,
    String? type,
  }) async {
    try {
      var query = _client
          .from('revenu')
          .select('''
        *,
        chantier:id_chantier(n_chantier)
      ''')
          .eq('entreprise_id', entrepriseId);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('motif.ilike.%$searchTerm%,n_revenu.ilike.%$searchTerm%');
      }

      if (dateDebut != null) {
        query = query.gte('jour', dateDebut.toIso8601String());
      }

      if (dateFin != null) {
        query = query.lte('jour', dateFin.toIso8601String());
      }

      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }

      final response = await query.order('jour', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Revenu> createRevenu(Revenu revenu) async {
    try {
      final response = await _client
          .from('revenu')
          .insert(revenu.toJson())
          .select('''
        *
      ''')
          .single();

      return Revenu.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRevenu(Revenu revenu) async {
    try {
      await _client
          .from('revenu')
          .update(revenu.toJson())
          .eq('id', revenu.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRevenu(String revenuId) async {
    try {
      await _client
          .from('revenu')
          .delete()
          .eq('id', revenuId);
    } catch (e) {
      rethrow;
    }
  }


  //


}
