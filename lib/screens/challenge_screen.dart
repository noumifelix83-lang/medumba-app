import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  Map<String, dynamic>? _progress;
  bool _isFr = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final p = await UserService.getProgress(uid);
    if (mounted) setState(() => _progress = p);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final streak = (_progress?['streak'] as int?) ?? 0;
    final xp = (_progress?['xp'] as int?) ?? 0;

    final daily = [
      _Challenge(icon: '⚡', titleFr: 'Terminer 3 leçons',          titleEn: 'Complete 3 lessons',    progress: 0, total: 3, reward: 20),
      _Challenge(icon: '🔥', titleFr: 'Maintenir votre série',       titleEn: 'Keep your streak',      progress: streak > 0 ? 1 : 0, total: 1, reward: 15),
      _Challenge(icon: '⭐', titleFr: "Gagner 50 XP aujourd'hui",    titleEn: 'Earn 50 XP today',      progress: xp > 50 ? 50 : xp % 50, total: 50, reward: 25),
    ];
    final weekly = [
      _Challenge(icon: '🏅', titleFr: 'Semaine parfaite',            titleEn: 'Perfect week streak',    progress: streak > 7 ? 7 : streak, total: 7,  reward: 100),
      _Challenge(icon: '🎯', titleFr: 'Pratiquer 5 compétences',     titleEn: 'Practice 5 skills',     progress: 0, total: 5,  reward: 80),
      _Challenge(icon: '💬', titleFr: 'Traduire 30 phrases',         titleEn: 'Translate 30 phrases',  progress: 0, total: 30, reward: 60),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isFr ? 'Défis' : 'Challenges',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kInk)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: kBlue,
          unselectedLabelColor: kMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          indicatorColor: kBlue,
          tabs: [
            Tab(text: _isFr ? 'QUOTIDIEN' : 'DAILY'),
            Tab(text: _isFr ? 'HEBDOMADAIRE' : 'WEEKLY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ChallengeList(challenges: daily, isFr: _isFr),
          _ChallengeList(challenges: weekly, isFr: _isFr),
        ],
      ),
    );
  }
}

class _Challenge {
  final String icon, titleFr, titleEn;
  final int progress, total, reward;
  const _Challenge({required this.icon, required this.titleFr, required this.titleEn, required this.progress, required this.total, required this.reward});
}

class _ChallengeList extends StatelessWidget {
  final List<_Challenge> challenges;
  final bool isFr;
  const _ChallengeList({required this.challenges, required this.isFr});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: challenges.map((c) => _ChallengeCard(c: c, isFr: isFr)).toList(),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final _Challenge c;
  final bool isFr;
  const _ChallengeCard({required this.c, required this.isFr});

  @override
  Widget build(BuildContext context) {
    final pct = (c.progress / c.total).clamp(0.0, 1.0);
    final done = c.progress >= c.total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF0FDF4) : Colors.white,
        border: Border.all(color: done ? kGreen : kBorder, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(c.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isFr ? c.titleFr : c.titleEn,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: done ? kGreen : kInk)),
            const SizedBox(height: 2),
            Text('${c.progress} / ${c.total}',
                style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: done ? kGreen : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(children: [
              Text('💎', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('+${c.reward}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: done ? Colors.white : const Color(0xFFEA580C))),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation(done ? kGreen : kBlue),
          ),
        ),
        if (done) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.check_circle_rounded, color: kGreen, size: 16),
            const SizedBox(width: 4),
            Text(isFr ? 'Défi complété !' : 'Challenge complete!',
                style: const TextStyle(color: kGreen, fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ],
      ]),
    );
  }
}
