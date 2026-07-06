import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/lesson_themes.dart';
import '../services/user_service.dart';
import '../state/app_language.dart';
import '../theme/colors.dart';

class _ChestInfo {
  final List<String> lessonIds;
  final String titleFr, titleEn, descFr, descEn;
  final int gems, xp;
  const _ChestInfo({
    required this.lessonIds,
    required this.titleFr, required this.titleEn,
    required this.descFr, required this.descEn,
    required this.gems, required this.xp,
  });
}

const _kChests = <String, _ChestInfo>{
  'c1': _ChestInfo(
    lessonIds: ['l1', 'l2', 'l3'],
    titleFr: 'Coffre — Les Bases',    titleEn: 'Chest — Foundations',
    descFr:  'Salutations · Corps · Nourriture',
    descEn:  'Greetings · Body · Food',
    gems: 50, xp: 100,
  ),
  'c2': _ChestInfo(
    lessonIds: ['l9', 'l10'],
    titleFr: 'Coffre — Vie Quotidienne', titleEn: 'Chest — Daily Life',
    descFr:  'Temps · Présentations',
    descEn:  'Time · Introductions',
    gems: 50, xp: 100,
  ),
  'c3': _ChestInfo(
    lessonIds: ['l11', 'l12', 'l13', 'l14'],
    titleFr: 'Coffre — Société',  titleEn: 'Chest — Society',
    descFr:  'Maison · Santé · École · Travail',
    descEn:  'Home · Health · School · Work',
    gems: 75, xp: 150,
  ),
  'c4': _ChestInfo(
    lessonIds: ['l15', 'l16', 'l17'],
    titleFr: 'Coffre Final 🏆',   titleEn: 'Final Chest 🏆',
    descFr:  'Conversations · Verbes · Culture',
    descEn:  'Conversations · Verbs · Culture',
    gems: 100, xp: 200,
  ),
};

class ChestScreen extends StatefulWidget {
  final String chestId;
  const ChestScreen({super.key, required this.chestId});
  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  String _phase = 'closed'; // closed | open
  List<({String fr, String medumba})> _words = [];
  int _wordIdx = 0;
  bool _saving = false;

  _ChestInfo get _info => _kChests[widget.chestId] ?? _kChests['c1']!;
  bool get _isFr => AppLanguage.instance.isFr;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _loadWords();
  }

  void _loadWords() {
    final rng = Random();
    final pool = _info.lessonIds
        .expand((id) => getExpressionsForLesson(id))
        .map((e) => (fr: e.fr, medumba: e.medumba))
        .toSet()
        .toList();
    pool.shuffle(rng);
    _words = pool.take(6).toList();
  }

  Future<void> _openChest() async {
    if (_phase != 'closed') return;
    await _ctrl.forward();
    setState(() => _phase = 'open');
  }

  Future<void> _claim() async {
    setState(() => _saving = true);
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      await Future.wait([
        UserService.completeLesson(uid, widget.chestId),
        UserService.addGems(uid, _info.gems),
        UserService.addXp(uid, _info.xp),
      ]);
    }
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: _phase == 'open' ? _buildOpen() : _buildClosed(),
      ),
    );
  }

  Widget _buildClosed() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _isFr ? 'Coffre de récompenses' : 'Reward chest',
            style: const TextStyle(
                color: Colors.white54, fontSize: 13,
                fontWeight: FontWeight.w700, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            _isFr ? _info.titleFr : _info.titleEn,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _isFr ? _info.descFr : _info.descEn,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 52),
          GestureDetector(
            onTap: _openChest,
            child: ScaleTransition(
              scale: _scale,
              child: const Text('🎁', style: TextStyle(fontSize: 96)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _isFr ? 'Appuyez pour ouvrir' : 'Tap to open',
            style: const TextStyle(
                color: Colors.white60, fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💎', style: TextStyle(fontSize: 16)),
            Text(
              '  +${_info.gems}  ',
              style: const TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const Text('⚡', style: TextStyle(fontSize: 16)),
            Text(
              '  +${_info.xp} XP',
              style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildOpen() {
    final totalWords = _words.length;
    final isLast = _wordIdx >= totalWords - 1;
    final word = totalWords == 0 ? null : _words[_wordIdx.clamp(0, totalWords - 1)];

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            _isFr ? 'Mots débloqués' : 'Unlocked words',
            style: const TextStyle(
                color: Colors.white70, fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            '${_wordIdx + 1} / $totalWords',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      Expanded(
        child: word == null
            ? const Center(child: Text('🎁', style: TextStyle(fontSize: 80)))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D2B55), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Text(
                      'FRANÇAIS',
                      style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        word.fr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(height: 1, color: Colors.white12),
                    const SizedBox(height: 28),
                    const Text(
                      'MEDUMBA',
                      style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        word.medumba,
                        style: const TextStyle(
                            color: Color(0xFFBB86FC),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ),
              ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : isLast
                    ? _claim
                    : () => setState(() => _wordIdx++),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isLast ? const Color(0xFFF59E0B) : const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
              elevation: 4,
            ),
            child: _saving
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5)
                : Text(
                    isLast
                        ? (_isFr
                            ? '💎 Récupérer +${_info.gems} diamants'
                            : '💎 Claim +${_info.gems} diamonds')
                        : (_isFr ? 'Mot suivant →' : 'Next word →'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
          ),
        ),
      ),
    ]);
  }
}
