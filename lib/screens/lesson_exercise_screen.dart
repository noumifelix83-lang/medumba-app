import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/lesson_themes.dart';
import '../data/medumba_expressions.dart';
import '../services/user_service.dart';
import '../state/app_language.dart';
import '../theme/colors.dart';

// ── Loading phase ──────────────────────────────────────────────────────────────

class _LoadingPhase extends StatefulWidget {
  final LessonTheme theme;
  final VoidCallback onReady;
  const _LoadingPhase({required this.theme, required this.onReady});
  @override
  State<_LoadingPhase> createState() => _LoadingPhaseState();
}

class _LoadingPhaseState extends State<_LoadingPhase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onReady();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/images/loading vec.png', height: 200, fit: BoxFit.contain),
                const SizedBox(height: 24),
                Text(widget.theme.emoji,
                    style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(widget.theme.titleFr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kMuted)),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 8,
                          backgroundColor: kBorder,
                          valueColor: const AlwaysStoppedAnimation(kBlue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(AppLanguage.instance.isFr
                              ? 'Chargement… ${(_progress.value * 100).round()}%'
                              : 'Loading… ${(_progress.value * 100).round()}%',
                          style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
                AppLanguage.instance.isFr
                    ? 'Terminez le cours plus vite pour gagner plus de XP'
                    : 'Finish faster to earn more XP',
                style: const TextStyle(fontSize: 12, color: kMuted),
                textAlign: TextAlign.center),
          ),
        ]),
      ),
    );
  }
}

// ── Question model ─────────────────────────────────────────────────────────────

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

// ── Screen ─────────────────────────────────────────────────────────────────────

class LessonExerciseScreen extends StatefulWidget {
  final String lessonId;
  const LessonExerciseScreen({super.key, required this.lessonId});
  @override
  State<LessonExerciseScreen> createState() => _LessonExerciseScreenState();
}

class _LessonExerciseScreenState extends State<LessonExerciseScreen> {
  LessonTheme? _theme;
  List<MExpr> _pool = [];
  List<MExpr> _flashcards = [];
  List<_Question> _questions = [];

  String _phase = 'loading'; // loading | flashcards | exercises | done | failed
  bool _saving = false; // true while writing completion to Supabase
  int _cardIdx = 0;
  bool _flipped = false;

  int _currentQ = 0;
  String? _selectedOption;
  String? _status; // null | correct | wrong
  bool _continueEnabled = false;

  List<int> _placed = []; // for tile: indices into bank

  int _xpEarned = 0;
  int _gemsEarned = 0;
  int _correctCount = 0;

  static const _xpPerQ = 10;
  static const _gemsPerQ = 5;
  static const _purple = Color(0xFF7C3AED);
  static const _blue = Color(0xFF0056D2);

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    try {
      _theme = kLessonThemes.firstWhere((t) => t.id == widget.lessonId);
    } catch (_) {
      return;
    }
    final rng = Random();
    _pool = getExpressionsForLesson(widget.lessonId)..shuffle(rng);
    _flashcards = _pool.take(3).toList();
    _questions = _buildQuestions(_flashcards, _pool, rng);
  }

  List<_Question> _buildQuestions(
      List<MExpr> studied, List<MExpr> pool, Random rng) {
    final qs = <_Question>[];

    for (final card in studied) {
      // MCQ French → Medumba: generate 3 distractors from pool
      final distractorsMed = pool
          .where((c) => c.medumba != card.medumba)
          .map((c) => c.medumba)
          .toSet()
          .take(3)
          .toList();
      final optsA = [card.medumba, ...distractorsMed]..shuffle(rng);
      qs.add(_Question(
        type: _QType.mcqFr2Med,
        prompt: card.fr,
        options: optsA,
        answer: card.medumba,
      ));

      // MCQ Medumba → French: generate 3 distractors from pool
      final distractorsFr = pool
          .where((c) => c.fr != card.fr)
          .map((c) => c.fr)
          .toSet()
          .take(3)
          .toList();
      final optsB = [card.fr, ...distractorsFr]..shuffle(rng);
      qs.add(_Question(
        type: _QType.mcqMed2Fr,
        prompt: card.medumba,
        options: optsB,
        answer: card.fr,
      ));
    }

    // Tile questions for multi-word Medumba expressions
    for (final card in studied) {
      final words = card.medumba.trim().split(RegExp(r'\s+'));
      if (words.length < 2 || words.length > 7) continue;
      final allPoolWords = pool
          .where((c) => c.medumba != card.medumba)
          .expand((c) => c.medumba.trim().split(RegExp(r'\s+')))
          .toSet()
          .where((w) => !words.contains(w))
          .toList()
        ..shuffle(rng);
      final distractors = allPoolWords.take(max(2, 8 - words.length)).toList();
      final bank = [...words, ...distractors]..shuffle(rng);
      qs.add(_Question(
        type: _QType.tile,
        prompt: card.fr,
        bank: bank,
        tileAnswer: words,
      ));
    }

    qs.shuffle(rng);
    return qs.take(12).toList();
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
    final correct = q.type == _QType.tile ? _tileCorrect() : _selectedOption == q.answer;
    setState(() {
      _status = correct ? 'correct' : 'wrong';
      _continueEnabled = false;
    });
    if (correct) {
      _xpEarned += _xpPerQ;
      _gemsEarned += _gemsPerQ;
      _correctCount++;
    }
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _continueEnabled = true);
    });
  }

  void _handleContinue() {
    if (_currentQ >= _questions.length - 1) {
      final pct = _questions.isNotEmpty ? _correctCount / _questions.length : 0;
      if (pct >= 0.6) {
        setState(() { _phase = 'done'; _saving = true; });
        _markComplete().whenComplete(() {
          if (mounted) setState(() => _saving = false);
        });
      } else {
        setState(() => _phase = 'failed');
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
      UserService.completeLesson(uid, widget.lessonId),
      UserService.addXp(uid, _xpEarned),
      UserService.addGems(uid, _gemsEarned),
    ]);
  }

  void _restart() {
    final rng = Random();
    final shuffled = [..._pool]..shuffle(rng);
    setState(() {
      _flashcards = shuffled.take(3).toList();
      _questions = _buildQuestions(_flashcards, _pool, rng);
      _phase = 'flashcards';
      _cardIdx = 0;
      _flipped = false;
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

  @override
  Widget build(BuildContext context) {
    if (_theme == null) {
      final isFr = AppLanguage.instance.isFr;
      return Scaffold(
        appBar: AppBar(title: Text(isFr ? 'Leçon' : 'Lesson')),
        body: Center(child: Text(isFr ? 'Leçon introuvable' : 'Lesson not found')),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_phase == 'exercises') {
          _showExitDialog(context);
        } else if (_phase == 'done' || _phase == 'failed') {
          if (!_saving) context.pop();
        } else {
          context.pop();
        }
      },
      child: switch (_phase) {
        'loading'    => _LoadingPhase(
                          theme: _theme!,
                          onReady: () => setState(() => _phase = 'flashcards'),
                        ),
        'flashcards' => _buildFlashcards(context),
        'exercises'  => _buildExercise(context),
        'done'       => _buildCompletion(context),
        'failed'     => _buildFailed(context),
        _            => _buildFlashcards(context),
      },
    );
  }

  // ── Phase 1: Flashcards ─────────────────────────────────────────────────────

  Widget _buildFlashcards(BuildContext context) {
    final card = _flashcards[_cardIdx];
    final isLast = _cardIdx == _flashcards.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              _CircleButton(
                icon: Icons.close,
                onTap: () => context.pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_cardIdx + 1) / _flashcards.length,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation(_purple),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_cardIdx + 1} / ${_flashcards.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _purple)),
            ]),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(children: [
              const Text('📖', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(AppLanguage.instance.isFr ? 'Expressions à retenir' : 'Expressions to study',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: _purple, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(AppLanguage.instance.isFr
                      ? 'Thème : ${_theme!.titleFr} — étudiez avant de commencer.'
                      : 'Theme: ${_theme!.titleEn} — study before starting.',
                  style: const TextStyle(fontSize: 12, color: kMuted),
                  textAlign: TextAlign.center),
            ]),
          ),

          // Flip card
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    color: _flipped ? _purple : Colors.white,
                    border: Border.all(
                        color: _flipped ? const Color(0xFF6D28D9) : const Color(0xFFE2E8F0),
                        width: 2),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      _flipped ? 'Medumba' : (AppLanguage.instance.isFr ? 'Français' : 'French'),
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8,
                          color: _flipped ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _flipped ? card.medumba : card.fr,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, height: 1.4,
                          color: _flipped ? Colors.white : const Color(0xFF0F172A)),
                      textAlign: TextAlign.center,
                    ),
                    if (!_flipped) ...[
                      const SizedBox(height: 12),
                      Text(AppLanguage.instance.isFr
                              ? '👆 Appuyez pour voir la traduction'
                              : '👆 Tap to see the translation',
                          style: const TextStyle(fontSize: 12, color: kMuted)),
                    ],
                  ]),
                ),
              ),
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(children: [
              if (_cardIdx > 0) ...[
                Expanded(
                  child: _PillButton(
                    label: AppLanguage.instance.isFr ? '← Précédent' : '← Previous',
                    onTap: () => setState(() { _cardIdx--; _flipped = false; }),
                    backgroundColor: const Color(0xFFEFF6FF),
                    textColor: _blue,
                    border: const Color(0xFFBFDBFE),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: _PillButton(
                  label: isLast
                      ? (AppLanguage.instance.isFr ? '🚀 Commencer l\'exercice' : '🚀 Start exercise')
                      : (AppLanguage.instance.isFr ? 'Suivant →' : 'Next →'),
                  onTap: isLast
                      ? () => setState(() => _phase = 'exercises')
                      : () => setState(() { _cardIdx++; _flipped = false; }),
                  backgroundColor: isLast ? _blue : _purple,
                  textColor: Colors.white,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Phase 2: Exercises ──────────────────────────────────────────────────────

  Widget _buildExercise(BuildContext context) {
    if (_questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() { _phase = 'done'; _saving = true; });
          _markComplete().whenComplete(() {
            if (mounted) setState(() => _saving = false);
          });
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_currentQ];
    final progress = _questions.isNotEmpty ? _currentQ / _questions.length : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              _CircleButton(icon: Icons.close, onTap: () => _showExitDialog(context)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(
                        Color.lerp(kBlue, const Color(0xFF38BDF8), progress.toDouble()) ?? kBlue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_currentQ + 1} / ${_questions.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _blue)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                    borderRadius: BorderRadius.circular(99)),
                child: Row(children: [
                  const Text('💎', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('+$_gemsEarned',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF16A34A))),
                ]),
              ),
            ]),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: q.type == _QType.tile ? _buildTile(q) : _buildMcq(q),
            ),
          ),

          // Feedback + action bar
          _buildBottomBar(context, q),
        ]),
      ),
    );
  }

  Widget _buildMcq(_Question q) {
    final isFr2Med = q.type == _QType.mcqFr2Med;
    final labels = ['A', 'B', 'C', 'D'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        isFr2Med
            ? (AppLanguage.instance.isFr ? 'Quelle est la traduction en Medumba ?' : 'What is the Medumba translation?')
            : (AppLanguage.instance.isFr ? 'Quelle est la traduction en Français ?' : 'What is the French translation?'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kInk),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Expanded(
            child: Text(q.prompt,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
            child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      ...q.options.asMap().entries.map((e) {
        final idx = e.key;
        final opt = e.value;
        final isSelected = _selectedOption == opt;
        final isCorrect = _status != null && opt == q.answer;
        final isWrong   = _status != null && isSelected && opt != q.answer;

        Color bg = Colors.white;
        Color border = kBorder;
        Color text = kInk;
        Color labelBg = const Color(0xFFF1F5F9);
        Color labelText = kMuted;
        if (isCorrect && _status != null) {
          bg = const Color(0xFFDCFCE7); border = const Color(0xFF4ADE80);
          text = const Color(0xFF15803D); labelBg = const Color(0xFF4ADE80); labelText = Colors.white;
        } else if (isWrong) {
          bg = const Color(0xFFFEF2F2); border = const Color(0xFFFCA5A5);
          text = const Color(0xFFDC2626); labelBg = const Color(0xFFFCA5A5); labelText = Colors.white;
        } else if (isSelected) {
          bg = const Color(0xFFEEF2FF); border = kBlue;
          text = kBlue; labelBg = kBlue; labelText = Colors.white;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: _status != null ? null : () => setState(() => _selectedOption = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: bg, border: Border.all(color: border, width: 2),
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(idx < labels.length ? labels[idx] : '${idx + 1}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: labelText)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(opt,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: text)),
                ),
              ]),
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildTile(_Question q) {
    final usedSet = Set<int>.from(_placed);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppLanguage.instance.isFr ? 'Reconstituez la phrase en Medumba' : 'Reconstruct the Medumba sentence',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kMuted, letterSpacing: 0.5)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(20)),
        child: Text(q.prompt,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk),
            textAlign: TextAlign.center),
      ),
      const SizedBox(height: 24),

      // Answer slots
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: kBorder, width: 2),
            borderRadius: BorderRadius.circular(14)),
        child: _placed.isEmpty
            ? Text(AppLanguage.instance.isFr
                    ? 'Appuyez sur les mots pour former la phrase'
                    : 'Tap words to form the sentence',
                style: const TextStyle(color: kMuted, fontSize: 13), textAlign: TextAlign.center)
            : Wrap(
                spacing: 8, runSpacing: 8,
                children: _placed.asMap().entries.map((e) {
                  final word = q.bank[e.value];
                  return GestureDetector(
                    onTap: _status != null ? null
                        : () => setState(() => _placed.removeAt(e.key)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: _blue, borderRadius: BorderRadius.circular(10)),
                      child: Text(word,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
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
            onTap: (_status != null || used) ? null
                : () => setState(() => _placed.add(e.key)),
            child: AnimatedOpacity(
              opacity: used ? 0.25 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: used ? kBorder : const Color(0xFF94A3B8), width: 2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: used ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]),
                child: Text(e.value,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kInk)),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildBottomBar(BuildContext context, _Question q) {
    final hasInput = q.type == _QType.tile ? _placed.isNotEmpty : _selectedOption != null;
    final isCorrect = _status == 'correct';

    if (_status != null) {
      final bgColor = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
      final lightBg = isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
      final isLast = _currentQ >= _questions.length - 1;
      return Container(
        color: lightBg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: bgColor,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isCorrect
                        ? (AppLanguage.instance.isFr ? 'Correct !' : 'Correct!')
                        : (AppLanguage.instance.isFr ? 'Mauvaise réponse !' : 'Wrong answer!'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                if (!isCorrect) ...[
                  const SizedBox(height: 2),
                  Text('${AppLanguage.instance.isFr ? 'Réponse' : 'Answer'} : ${q.type == _QType.tile ? q.tileAnswer.join(' ') : q.answer}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: _PillButton(
                label: isLast
                    ? (AppLanguage.instance.isFr ? 'Terminer' : 'Finish')
                    : (isCorrect
                        ? (AppLanguage.instance.isFr ? 'CONTINUER' : 'CONTINUE')
                        : 'OK'),
                onTap: _continueEnabled ? _handleContinue : null,
                backgroundColor: bgColor,
                textColor: Colors.white,
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
        child: _PillButton(
          label: AppLanguage.instance.isFr ? 'Vérifier' : 'Check',
          onTap: hasInput ? _checkAnswer : null,
          backgroundColor: hasInput ? _blue : const Color(0xFFE2E8F0),
          textColor: hasInput ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final isFr = AppLanguage.instance.isFr;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isFr ? '😟 Quitter la leçon ?' : '😟 Quit the lesson?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        content: Text(isFr
                ? 'Votre progression dans cet exercice sera perdue.'
                : 'Your progress in this exercise will be lost.',
            style: const TextStyle(fontSize: 14, color: kMuted)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            child: Text(isFr ? 'Quitter' : 'Quit',
                style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
            child: Text(isFr ? 'Continuer ✊' : 'Keep going ✊',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Phase 3: Completion ─────────────────────────────────────────────────────

  Widget _buildCompletion(BuildContext context) {
    final accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length * 100).round() : 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(children: [
            // Title
            Text(AppLanguage.instance.isFr ? 'Leçon terminée !' : 'Lesson complete!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kBlue),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Celebration area
            Image.asset('assets/images/Auto Layout Vertical.png', height: 140, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(_theme!.titleFr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kMuted),
                textAlign: TextAlign.center),

            const SizedBox(height: 32),

            // Diamonds box
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: kBlue, width: 2),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14), topRight: Radius.circular(14))),
                  child: Text(AppLanguage.instance.isFr ? 'Diamants' : 'Diamonds',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('💎', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Text('+$_gemsEarned',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kInk)),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // Stat cards
            Row(children: [
              Expanded(child: _FigmaStatCard(
                  title: 'Total XP',
                  value: '+$_xpEarned',
                  color: const Color(0xFFFFF3CD),
                  textColor: const Color(0xFFF59E0B))),
              const SizedBox(width: 10),
              Expanded(child: _FigmaStatCard(
                  title: AppLanguage.instance.isFr ? 'Précision' : 'Accuracy',
                  value: '$accuracy%',
                  color: const Color(0xFFFFE0E0),
                  textColor: const Color(0xFFEF4444))),
            ]),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: _PillButton(
                label: _saving
                    ? (AppLanguage.instance.isFr ? 'Sauvegarde…' : 'Saving…')
                    : (AppLanguage.instance.isFr ? 'CONTINUER' : 'CONTINUE'),
                onTap: _saving ? null : () => context.pop(),
                backgroundColor: kBlue,
                textColor: Colors.white,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Phase: Failed ────────────────────────────────────────────────────────────

  Widget _buildFailed(BuildContext context) {
    final accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length * 100).round() : 0;
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😓', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(AppLanguage.instance.isFr ? 'Score insuffisant' : 'Score too low',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
            const SizedBox(height: 12),
            Text('$_correctCount / ${_questions.length}  ($accuracy%)',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInk)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(
                AppLanguage.instance.isFr
                    ? 'Vous devez obtenir au moins 60% pour réussir.\nRecommencez !'
                    : 'You need at least 60% to pass.\nTry again!',
                style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _PillButton(
                label: AppLanguage.instance.isFr ? '🔄 Recommencer' : '🔄 Try again',
                onTap: _restart,
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorder, width: 2),
            color: Colors.transparent),
        child: Icon(icon, size: 18, color: kMuted),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? border;
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(99),
            border: border != null ? Border.all(color: border!, width: 2) : null),
        child: Text(label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class _FigmaStatCard extends StatelessWidget {
  final String title, value;
  final Color color, textColor;
  const _FigmaStatCard({
    required this.title, required this.value,
    required this.color, required this.textColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.8))),
      ]),
    );
  }
}
