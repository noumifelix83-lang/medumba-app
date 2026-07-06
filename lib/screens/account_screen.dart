import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';

class _ProfMeta { final String fr, en; final Color color; const _ProfMeta(this.fr, this.en, this.color); }
class _GoalMeta  { final String fr, en, time, xp; const _GoalMeta(this.fr, this.en, this.time, this.xp); }

const _profLabels = <int, _ProfMeta>{
  1: _ProfMeta('Débutant absolu',  'Absolute Beginner', Color(0xFFEF4444)),
  2: _ProfMeta('Élémentaire',      'Elementary',        Color(0xFFF59E0B)),
  3: _ProfMeta('Intermédiaire',    'Intermediate',      Color(0xFF22C55E)),
  4: _ProfMeta('Avancé',           'Advanced',          Color(0xFF0056D2)),
};

const _goalLabels = <String, _GoalMeta>{
  'relaxed': _GoalMeta('En douceur', 'Gentle',   '5 min/j',  '10 XP'),
  'normal':  _GoalMeta('Régulier',   'Regular',  '10 min/j', '20 XP'),
  'serious': _GoalMeta('Sérieux',    'Serious',  '15 min/j', '30 XP'),
  'intense': _GoalMeta('Intensif',   'Intense',  '30 min/j', '60 XP'),
};

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _progress;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { setState(() => _loading = false); return; }
    final results = await Future.wait([UserService.getProfile(uid), UserService.getProgress(uid)]);
    if (mounted) setState(() {
      _profile = results[0];
      _progress = results[1];
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logoutUser();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: kBlue)));

    final name      = (_profile?['name']        as String?) ?? '';
    final email     = Supabase.instance.client.auth.currentUser?.email ?? '';
    final lang      = (_profile?['native_lang'] as String?) ?? 'french';
    final isFr      = lang == 'french';
    final profLevel = (_profile?['proficiency'] as int?) ?? 1;
    final dailyGoal = (_profile?['daily_goal']  as String?) ?? 'normal';
    final streak    = (_progress?['streak']     as int?) ?? 0;
    final xp        = (_progress?['xp']         as int?) ?? 0;
    final gems      = (_progress?['gems']       as int?) ?? 0;

    final profMeta = _profLabels[profLevel] ?? _profLabels[1]!;
    final goalMeta = _goalLabels[dailyGoal]  ?? _goalLabels['normal']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(isFr ? 'Mon Compte' : 'My Account',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kInk)),
      ),
      body: RefreshIndicator(
        color: kBlue,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner + avatar + nom
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder)),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                Image.asset('assets/images/profile_welcome_vector.png', width: double.infinity, height: 100, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: kBlue,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kInk)),
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: profMeta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(isFr ? profMeta.fr : profMeta.en,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: profMeta.color)),
                  ),
                ])),
              ]),
            ),
          ]),
        ),
            const SizedBox(height: 12),

            // Stats
            Row(children: [
              _StatCard(emoji: '🔥', value: '$streak', labelFr: 'Série', labelEn: 'Streak', isFr: isFr),
              const SizedBox(width: 8),
              _StatCard(emoji: '⚡', value: '$xp', labelFr: 'XP Total', labelEn: 'Total XP', isFr: isFr),
              const SizedBox(width: 8),
              _StatCard(emoji: '💎', value: '$gems', labelFr: 'Gemmes', labelEn: 'Gems', isFr: isFr),
            ]),
            const SizedBox(height: 12),

            // Objectif quotidien
            _InfoCard(
              icon: '🎯',
              title: isFr ? 'Objectif quotidien' : 'Daily goal',
              value: '${isFr ? goalMeta.fr : goalMeta.en} — ${goalMeta.time} · ${goalMeta.xp}',
            ),
            const SizedBox(height: 8),

            // Langue
            _InfoCard(
              icon: '🌍',
              title: isFr ? 'Langue native' : 'Native language',
              value: lang == 'french' ? '🇫🇷 Français' : lang == 'english' ? '🇬🇧 English' : lang,
            ),
            const SizedBox(height: 24),

            // Déconnexion
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRed, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                ),
                child: Text(isFr ? 'Se déconnecter' : 'Log out',
                    style: const TextStyle(color: kRed, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, labelFr, labelEn;
  final bool isFr;
  const _StatCard({required this.emoji, required this.value, required this.labelFr, required this.labelEn, required this.isFr});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kInk)),
        Text(isFr ? labelFr : labelEn, style: const TextStyle(fontSize: 10, color: kMuted, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final String icon, title, value;
  const _InfoCard({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kInk)),
      ])),
    ]),
  );
}
