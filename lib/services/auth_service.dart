import 'package:supabase_flutter/supabase_flutter.dart';

// Migration de authService.js → même logique, même structure
class AuthService {
  static final _client = Supabase.instance.client;

  // ── Inscription email / mot de passe ──────────────────────────────────────
  static Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    String? age,
    String language = 'french',
    String? reason,
    String dailyGoal = 'normal',
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'native_lang': language},
    );
    if (res.user != null) {
      await _client.from('profiles').upsert({
        'id':          res.user!.id,
        'name':        name,
        'age':         age,
        'native_lang': language,
        'reason':      reason,
        'daily_goal':  dailyGoal,
      });
    }
    return res.user;
  }

  // ── Connexion email / mot de passe ────────────────────────────────────────
  static Future<User?> loginUser(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────
  static Future<void> logoutUser() async {
    await _client.auth.signOut();
  }

  // ── Réinitialisation mot de passe ─────────────────────────────────────────
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── Utilisateur courant ───────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;

  // ── Stream d'état auth ────────────────────────────────────────────────────
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ── Profil utilisateur depuis Supabase ────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();
    return res;
  }

  // ── Mettre à jour le profil ───────────────────────────────────────────────
  static Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _client.from('profiles').upsert({'id': uid, ...data});
  }
}
