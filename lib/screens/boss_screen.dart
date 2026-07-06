import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/lesson_themes.dart';
import '../data/medumba_expressions.dart';
import '../services/user_service.dart';
import '../state/app_language.dart';
import '../theme/colors.dart';

// ── Boss definitions ────────────────────────────────────────────────────────

class _BossInfo {
  final List<String> lessonIds;
  final String titleFr, titleEn, descFr, descEn;
  final String emoji;
  final Color color;
  final int bonusGems, bonusXp;
  const _BossInfo({
    required this.lessonIds,
    required this.titleFr, required this.titleEn,
    required this.descFr, required this.descEn,
    required this.emoji, required this.color,
    required this.bonusGems, required this.bonusXp,
  });
}

const _kBosses = <String, _BossInfo>{
  'b1': _BossInfo(
    lessonIds: ['l6', 'l7', 'l8'],
    titleFr: 'Défi Boss — Monde Naturel',
    titleEn: 'Boss Fight — Natural World',
    descFr: 'Animaux · Famille · Nature',
    descEn: 'Animals · Family · Nature',
    emoji: '🐾',
    color: Color(0xFF065F46),
    bonusGems: 100, bonusXp: 200,
  ),
  'b2': _BossInfo(
    lessonIds: ['l11', 'l12', 'l13'],
    titleFr: 'Défi Boss — Société',
    titleEn: 'Boss Fight — Society',
    descFr: 'Maison · Santé · École',
    descEn: 'Home · Health · School',
    emoji: '🏛️',
    color: Color(0xFF5B21B6),
    bonusGems: 150, bonusXp: 300,
  ),
  'b3': _BossInfo(
    lessonIds: ['l15', 'l16'],
    titleFr: 'Défi Boss Final',
    titleEn: 'Final Boss Fight',
    descFr: 'Conversations · Verbes d\'action',
    descEn: 'Conversations · Action Verbs',
    emoji: '👑',
    color: Color(0xFF92400E),
    bonusGems: 200, bonusXp: 500,
  ),
};

// ── Question model ───────────────────────────────────────────────────────────

enum _QType { mcqFr2Med, mcqMed2Fr, tile }

class _Question {
  final _QType type;
  final String prompt;
  final List<String> options;
  final String answer;
  final List<String> bank;
  final List<String> tileAnswer;
  const _Question({
    required this.type,
    required this.prompt,
    this.options = const [],
    this.answer = '',
    this.bank = const [],
    this.tileAnswer = const [],
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class BossScreen extends StatefulWidget {
  final String bossId;
  const BossScreen({super.key, required this.bossId});
  @override
  State<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends State<BossScreen> {
  static const _kTotalQ = 15;
  static const _xpPerQ = 20;
  static const _gemsPerQ = 10;

  List<MExpr> _pool = [];
  List<_Question> _questions = [];
  String _phase = 'intro'; // intro | exercises | victory | defeat
  int _currentQ = 0;
  String? _selectedOption;
  String? _status; // correct | wrong | null
  bool _continueEnabled = false;
  List<int> _placed = [];
  int _correctCount = 0;
  int _gemsEarned = 0;
  int _xpEarned = 0;

  _BossInfo get _info => _kBosses[widget.bossId] ?? _kBosses['b1']!;
  bool get _isFr => AppLanguage.instance.isFr;

  @override
  void initState() {
    super.initState();
    _initPool();
  }

  void _initPool() {
    final rng = Random();
    _pool = _info.lessonIds
        .expand((id) => getExpressionsForLesson(id))
        .toSet()
        .toList()
      ..shuffle(rng);
    if (_pool.length < 5) _pool = ([...kAllExpressions]..shuffle(rng));
    _questions = _buildQuestions(rng);
  }

  List<_Question> _buildQuestions(Random rng) {
    final studied = (_pool.toList()..shuffle(rng)).take(5).toList();
    final qs = <_Question>[];

    for (final card in studied) {
      // FR → Medumba MCQ
      final dMed = _pool
          .where((e) => e.medumba != card.medumba)
          .map((e) => e.medumba)
          .toSet()
          .take(3)
          .toList();
      final optsA = [card.medumba, ...dMed]..shuffle(rng);
      qs.add(_Question(
          type: _QType.mcqFr2Med,
          prompt: card.fr,
          options: optsA,
          answer: card.medumba));

      // Medumba → FR MCQ
      final dFr = _pool
          .where((e) => e.fr != card.fr)
          .map((e) => e.fr)
          .toSet()
          .take(3)
          .toList();
      final optsB = [card.fr, ...dFr]..shuffle(rng);
      qs.add(_Question(
          type: _QType.mcqMed2Fr,
          prompt: card.medumba,
          options: optsB,
          answer: card.fr));
    }

    // Tile questions
    for (final card in studied) {
      final words = card.medumba.trim().split(RegExp(r'\s+'));
      if (words.length < 2 || words.length > 7) continue;
      final distractors = _pool
          .where((e) => e.medumba != card.medumba)
          .expand((e) => e.medumba.trim().split(RegExp(r'\s+')))
          .toSet()
          .where((w) => !words.contains(w))
          .take(max(2, 8 - words.length))
          .toList()
        ..shuffle(rng);
      final bank = [...words, ...distractors]..shuffle(rng);
      qs.add(_Question(
          type: _QType.tile,
          prompt: card.fr,
          bank: bank,
          tileAnswer: words));
    }

    qs.shuffle(rng);
    return qs.take(_kTotalQ).toList();
  }

  bool _tileCorrect() {
    final q = _questions[_currentQ];
    final placed = _placed.map((i) => q.bank[i]).toList();
    if (placed.length != q.tileAnswer.length) return false;
    for (int i = 0; i < placed.length; i++) {
      if (placed[i] != q.tileAnswer[i]) return false;
    }
    return true;
  }

  void _checkAnswer() {
    final q = _questions[_currentQ];
    final correct =
        q.type == _QType.tile ? _tileCorrect() : _selectedOption == q.answer;
    setState(() {
      _status = correct ? 'correct' : 'wrong';
      _continueEnabled = false;
    });
    if (correct) {
      _xpEarned += _xpPerQ;
      _gemsEarned += _gemsPerQ;
      _correctCount++;
    }
    Future.delayed(const Duration(milliseconds: 350),
        () { if (mounted) setState(() => _continueEnabled = true); });
  }

  void _handleContinue() {
    if (_currentQ >= _questions.length - 1) {
      final pct = _questions.isNotEmpty ? _correctCount / _questions.length : 0;
      if (pct >= 0.6) {
        _markComplete();
        setState(() => _phase = 'victory');
      } else {
        setState(() => _phase = 'defeat');
      }
    } else {
      setState(() {
        _currentQ++;
        _selectedOption = null;
        _status = null;
        _continueEnabled = false;
        _placed = [];
      });
    }
  }

  Future<void> _markComplete() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    await Future.wait([
      UserService.completeLesson(uid, widget.bossId),
      UserService.addXp(uid, _xpEarned + _info.bonusXp),
      UserService.addGems(uid, _gemsEarned + _info.bonusGems),
    ]);
  }

  void _retry() {
    final rng = Random();
    (_pool..shuffle(rng));
    setState(() {
      _questions = _buildQuestions(rng);
      _phase = 'exercises';
      _currentQ = 0;
      _selectedOption = null;
      _status = null;
      _continueEnabled = false;
      _placed = [];
      _xpEarned = 0;
      _gemsEarned = 0;
      _correctCount = 0;
    });
  }

  void _showExitDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(_isFr ? 'Abandonner le défi ?' : 'Abandon the challenge?'),
        content: Text(_isFr
            ? 'Ta progression sera perdue.'
            : 'Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(_isFr ? 'Quitter' : 'Quit',
                style: const TextStyle(color: kRed)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
                backgroundColor: _info.color, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99))),
            child: Text(_isFr ? 'Continuer ✊' : 'Keep going ✊'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase != 'exercises',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _phase == 'exercises') _showExitDialog(context);
      },
      child: switch (_phase) {
        'exercises' => _buildExercise(),
        'victory'   => _buildVictory(),
        'defeat'    => _buildDefeat(),
        _           => _buildIntro(),
      },
    );
  }

  // ── INTRO ──────────────────────────────────────────────────────────────────

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: _info.color,
      body: SafeArea(
        child: Column(children: [
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
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(_info.emoji, style: const TextStyle(fontSize: 88)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _isFr ? _info.titleFr : _info.titleEn,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isFr ? _info.descFr : _info.descEn,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  _StatPill('📝', '$_kTotalQ',
                      _isFr ? 'Questions' : 'Questions'),
                  _StatPill('✅', '60%',
                      _isFr ? 'Pour réussir' : 'To pass'),
                  _StatPill('💎', '+${_info.bonusGems}',
                      _isFr ? 'Bonus' : 'Bonus'),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => setState(() => _phase = 'exercises'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _info.color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                  elevation: 0,
                ),
                child: Text(
                  _isFr ? '⚔️  Commencer le défi !' : '⚔️  Start the challenge!',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── EXERCISE ───────────────────────────────────────────────────────────────

  Widget _buildExercise() {
    if (_questions.isEmpty) {
      _markComplete();
      WidgetsBinding.instance.addPostFrameCallback(
          (_) { if (mounted) setState(() => _phase = 'victory'); });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_currentQ];
    final progress = (_currentQ + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // progress bar row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => _showExitDialog(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kBorder, width: 2)),
                  child: const Icon(Icons.close, size: 18, color: kMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(_info.color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentQ + 1}/${_questions.length}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _info.color),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                    borderRadius: BorderRadius.circular(99)),
                child: Row(children: [
                  const Text('💎', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('+$_gemsEarned',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFF16A34A))),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: q.type == _QType.tile ? _buildTile(q) : _buildMcq(q),
            ),
          ),
          _buildBottomBar(q),
        ]),
      ),
    );
  }

  Widget _buildMcq(_Question q) {
    final isFr2Med = q.type == _QType.mcqFr2Med;
    const labels = ['A', 'B', 'C', 'D'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        isFr2Med
            ? (_isFr
                ? 'Quelle est la traduction en Medumba ?'
                : 'What is the Medumba translation?')
            : (_isFr
                ? 'Quelle est la traduction en Français ?'
                : 'What is the French translation?'),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: kInk),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(16)),
        child: Text(q.prompt,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
      ),
      const SizedBox(height: 20),
      ...q.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        final isSelected = _selectedOption == opt;
        final isCorrect = _status != null && opt == q.answer;
        final isWrong = _status != null && isSelected && opt != q.answer;

        Color bg = Colors.white, borderColor = kBorder, textColor = kInk;
        Color labelBg = const Color(0xFFF1F5F9),
            labelText = kMuted;

        if (isCorrect) {
          bg = const Color(0xFFDCFCE7);
          borderColor = const Color(0xFF4ADE80);
          textColor = const Color(0xFF15803D);
          labelBg = const Color(0xFF4ADE80);
          labelText = Colors.white;
        } else if (isWrong) {
          bg = const Color(0xFFFEF2F2);
          borderColor = const Color(0xFFFCA5A5);
          textColor = const Color(0xFFDC2626);
          labelBg = const Color(0xFFFCA5A5);
          labelText = Colors.white;
        } else if (isSelected) {
          bg = Color.alphaBlend(
              _info.color.withValues(alpha: 0.08), Colors.white);
          borderColor = _info.color;
          textColor = _info.color;
          labelBg = _info.color;
          labelText = Colors.white;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: _status != null
                ? null
                : () => setState(() => _selectedOption = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(14)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: labelBg,
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(
                    idx < labels.length ? labels[idx] : '${idx + 1}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: labelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(opt,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ),
              ]),
            ),
          ),
        );
      }),
    ]);
  }

  Widget _buildTile(_Question q) {
    final usedSet = Set<int>.from(_placed);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _isFr
            ? 'Reconstituez la phrase en Medumba'
            : 'Reconstruct the Medumba sentence',
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kMuted,
            letterSpacing: 0.5),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(20)),
        child: Text(q.prompt,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: kInk),
            textAlign: TextAlign.center),
      ),
      const SizedBox(height: 24),
      // Answer area
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: kBorder, width: 2),
            borderRadius: BorderRadius.circular(14)),
        child: _placed.isEmpty
            ? Text(
                _isFr
                    ? 'Appuyez sur les mots pour former la phrase'
                    : 'Tap words to form the sentence',
                style:
                    const TextStyle(color: kMuted, fontSize: 13),
                textAlign: TextAlign.center)
            : Wrap(
                spacing: 8, runSpacing: 8,
                children: _placed.asMap().entries.map((e) {
                  return GestureDetector(
                    onTap: _status != null
                        ? null
                        : () => setState(() => _placed.removeAt(e.key)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: _info.color,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(q.bank[e.value],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  );
                }).toList(),
              ),
      ),
      const SizedBox(height: 16),
      // Word bank
      Wrap(
        spacing: 8, runSpacing: 8,
        children: q.bank.asMap().entries.map((e) {
          final used = usedSet.contains(e.key);
          return GestureDetector(
            onTap: (_status != null || used)
                ? null
                : () => setState(() => _placed.add(e.key)),
            child: AnimatedOpacity(
              opacity: used ? 0.25 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: used
                            ? kBorder
                            : const Color(0xFF94A3B8),
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: used
                        ? []
                        : [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ]),
                child: Text(e.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kInk)),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildBottomBar(_Question q) {
    final hasInput = q.type == _QType.tile
        ? _placed.isNotEmpty
        : _selectedOption != null;
    final isCorrect = _status == 'correct';
    final isLast = _currentQ >= _questions.length - 1;

    if (_status != null) {
      final barColor =
          isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
      final lightBg =
          isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
      return Container(
        color: lightBg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: barColor,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    isCorrect
                        ? (_isFr ? 'Correct !' : 'Correct!')
                        : (_isFr ? 'Mauvaise réponse !' : 'Wrong answer!'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${_isFr ? 'Réponse' : 'Answer'} : '
                      '${q.type == _QType.tile ? q.tileAnswer.join(' ') : q.answer}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueEnabled ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: barColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  isLast
                      ? (_isFr ? 'Terminer' : 'Finish')
                      : (isCorrect
                          ? (_isFr ? 'CONTINUER' : 'CONTINUE')
                          : 'OK'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasInput ? _checkAnswer : null,
          style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasInput ? _info.color : const Color(0xFFE2E8F0),
              foregroundColor:
                  hasInput ? Colors.white : const Color(0xFF94A3B8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(
            _isFr ? 'Vérifier' : 'Check',
            style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── VICTORY ────────────────────────────────────────────────────────────────

  Widget _buildVictory() {
    final accuracy = _questions.isNotEmpty
        ? (_correctCount / _questions.length * 100).round()
        : 0;
    return Scaffold(
      backgroundColor: _info.color,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(_info.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              _isFr ? 'Boss vaincu ! 🎉' : 'Boss defeated! 🎉',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isFr ? _info.titleFr : _info.titleEn,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                _StatPill('⚡', '+${_xpEarned + _info.bonusXp}', 'XP'),
                _StatPill('💎', '+${_gemsEarned + _info.bonusGems}',
                    _isFr ? 'Diamants' : 'Diamonds'),
                _StatPill('🎯', '$accuracy%',
                    _isFr ? 'Précision' : 'Accuracy'),
              ]),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 58,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _info.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99))),
                child: Text(
                  _isFr ? 'CONTINUER' : 'CONTINUE',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── DEFEAT ─────────────────────────────────────────────────────────────────

  Widget _buildDefeat() {
    final accuracy = _questions.isNotEmpty
        ? (_correctCount / _questions.length * 100).round()
        : 0;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Text('💀', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              _isFr ? 'Défi échoué' : 'Challenge failed',
              style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 28,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount/${_questions.length} ($accuracy%)',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF2D1B1B),
                  border: Border.all(
                      color:
                          const Color(0xFFEF4444).withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(
                _isFr
                    ? 'Il faut 60% pour vaincre le boss.\nRessayez !'
                    : 'You need 60% to beat the boss.\nTry again!',
                style: const TextStyle(
                    color: Color(0xFFFC8181),
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99))),
                child: Text(
                  _isFr ? '⚔️ Réessayer' : '⚔️ Try again',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                _isFr
                    ? 'Retourner au tableau de bord'
                    : 'Back to dashboard',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Shared stat pill ─────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String emoji, value, label;
  const _StatPill(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]);
}
