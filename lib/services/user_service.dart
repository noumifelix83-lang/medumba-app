import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _db = Supabase.instance.client;

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      return await _db.from('profiles').select().eq('id', uid).single();
    } catch (_) { return null; }
  }

  // ── Progress (XP, gems, streak) ───────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProgress(String uid) async {
    try {
      return await _db.from('user_progress').select().eq('user_id', uid).maybeSingle();
    } catch (_) { return null; }
  }

  static Future<void> saveProgress(String uid, Map<String, dynamic> fields) async {
    try {
      await _db.from('user_progress').upsert(
        {'user_id': uid, ...fields, 'updated_at': DateTime.now().toIso8601String()},
        onConflict: 'user_id',
      );
    } catch (_) {}
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  static Future<int> updateStreak(String uid) async {
    final progress = await getProgress(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    final lastDate = progress?['streak_last_date'] as String?;
    int streak = (progress?['streak'] as int?) ?? 0;

    if (lastDate == today) return streak;
    if (lastDate == yesterday) streak++;
    else streak = 1;

    await saveProgress(uid, {'streak': streak, 'streak_last_date': today});
    return streak;
  }

  // ── XP / Gems ─────────────────────────────────────────────────────────────

  static Future<void> addXp(String uid, int amount) async {
    final progress = await getProgress(uid);
    final current = (progress?['xp'] as int?) ?? 0;
    await saveProgress(uid, {'xp': current + amount});
  }

  static Future<void> addGems(String uid, int amount) async {
    final progress = await getProgress(uid);
    final current = (progress?['gems'] as int?) ?? 0;
    await saveProgress(uid, {'gems': current + amount});
  }

  // ── Completed lessons — SharedPreferences (primary) + Supabase (sync) ────

  static String _spKey(String uid) => 'completed_lessons_$uid';

  /// Returns the locally-cached completed lesson IDs (instantly, no network).
  static Future<List<String>> getCompletedLessons(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_spKey(uid));

    // If local cache exists, use it directly
    if (local != null) return local;

    // First launch: pull from Supabase and prime the cache
    final progress = await getProgress(uid);
    final raw = progress?['completed_lessons'];
    final remote = raw is List
        ? raw.map((e) => e.toString()).toList()
        : <String>[];
    await prefs.setStringList(_spKey(uid), remote);
    return remote;
  }

  /// Marks a lesson complete locally (instant) and syncs to Supabase.
  static Future<void> completeLesson(String uid, String lessonId) async {
    final done = await getCompletedLessons(uid);
    if (done.contains(lessonId)) return;
    final updated = [...done, lessonId];

    // 1. Write to local cache immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_spKey(uid), updated);

    // 2. Sync to Supabase (best-effort, errors swallowed)
    await saveProgress(uid, {'completed_lessons': updated});
  }

  // ── Completed certifications (CEPOM) — same pattern as completed lessons ──

  static String _certSpKey(String uid) => 'completed_certs_$uid';

  static Future<List<String>> getCompletedCertifications(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_certSpKey(uid));
    if (local != null) return local;

    final progress = await getProgress(uid);
    final raw = progress?['completed_certifications'];
    final remote = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
    await prefs.setStringList(_certSpKey(uid), remote);
    return remote;
  }

  static Future<void> completeCertification(String uid, String unitId) async {
    final done = await getCompletedCertifications(uid);
    if (done.contains(unitId)) return;
    final updated = [...done, unitId];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_certSpKey(uid), updated);
    await saveProgress(uid, {'completed_certifications': updated});
  }
}
