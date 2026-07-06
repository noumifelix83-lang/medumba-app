import 'dart:math';
import 'package:flutter/material.dart';
import '../data/lesson_themes.dart';
import '../theme/colors.dart';

typedef _Card = LessonCard;
typedef _Theme = LessonTheme;
final _themes = kLessonThemes;

// ── Screen ────────────────────────────────────────────────────────────────────

class VocabScreen extends StatefulWidget {
  final String? initialThemeId;
  const VocabScreen({super.key, this.initialThemeId});
  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  bool _isFr = true;
  _Theme? _theme;
  String? _mode; // 'flashcard' | 'quiz'

  @override
  void initState() {
    super.initState();
    if (widget.initialThemeId != null) {
      final t = _themes.firstWhere((t) => t.id == widget.initialThemeId, orElse: () => _themes[0]);
      _pickTheme(t);
    }
  }

  List<_Card> _cards = [];
  int _idx = 0;
  bool _flipped = false;
  String? _sel;
  bool _checked = false;
  int _score = 0;
  bool _done = false;

  static const _accent = Color(0xFF1B4FD8);

  void _pickTheme(_Theme t) {
    final shuffled = [...t.cards]..shuffle(Random());
    setState(() {
      _theme = t;
      _mode  = null;
      _cards = shuffled;
      _idx   = 0; _flipped = false; _sel = null;
      _checked = false; _score = 0; _done = false;
    });
  }

  void _pickMode(String m) {
    setState(() {
      _mode    = m;
      _idx     = 0; _flipped = false; _sel = null;
      _checked = false; _score = 0; _done = false;
    });
  }

  void _advance(bool correct) {
    final newScore = correct ? _score + 1 : _score;
    if (_idx < _cards.length - 1) {
      setState(() { _score = newScore; _idx++; _flipped = false; _sel = null; _checked = false; });
    } else {
      setState(() { _score = newScore; _done = true; });
    }
  }

  void _restart() {
    final shuffled = [..._theme!.cards]..shuffle(Random());
    setState(() {
      _cards = shuffled; _idx = 0; _flipped = false; _sel = null;
      _checked = false; _score = 0; _done = false;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_theme == null) return _buildThemeGrid();
    if (_mode  == null) return _buildModeSelector();
    return _buildExercise();
  }

  // ── View 1: Theme Grid ─────────────────────────────────────────────────────

  Widget _buildThemeGrid() => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(_isFr ? 'Vocabulaire' : 'Vocabulary',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kInk)),
      actions: [
        TextButton(
          onPressed: () => setState(() => _isFr = !_isFr),
          child: Text(_isFr ? 'EN' : 'FR',
              style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Text(_isFr ? 'Choisissez un thème' : 'Choose a theme',
            style: const TextStyle(fontSize: 14, color: kMuted, fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.55,
          ),
          itemCount: _themes.length,
          itemBuilder: (_, i) {
            final t = _themes[i];
            return GestureDetector(
              onTap: () => _pickTheme(t),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(_isFr ? t.titleFr : t.titleEn,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('${t.cards.length} ${_isFr ? "mots" : "words"}',
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                ]),
              ),
            );
          },
        ),
      ),
    ]),
  );

  // ── View 2: Mode Selector ──────────────────────────────────────────────────

  Widget _buildModeSelector() {
    final modes = [
      ('flashcard', '🃏', _isFr ? 'Cartes'  : 'Flashcards', _isFr ? 'Retournez les cartes'       : 'Flip the cards'),
      ('quiz',      '🎯', 'Quiz',             _isFr ? 'Choisissez la bonne réponse'  : 'Choose the right answer'),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kInk),
          onPressed: () => setState(() => _theme = null),
        ),
        title: Text('${_theme!.emoji}  ${_isFr ? _theme!.titleFr : _theme!.titleEn}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: kInk)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_cards.length} ${_isFr ? "mots" : "words"}',
              style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...modes.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _pickMode(m.$1),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Text(m.$2, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.$3, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kInk)),
                    Text(m.$4, style: const TextStyle(fontSize: 12, color: kMuted)),
                  ])),
                  const Icon(Icons.chevron_right_rounded, color: kMuted),
                ]),
              ),
            ),
          )),
        ]),
      ),
    );
  }

  // ── View 3: Exercise ───────────────────────────────────────────────────────

  Widget _buildExercise() {
    final card = _done ? null : _cards[_idx];
    final total = _cards.length;
    final progress = _done ? 1.0 : (_idx + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kInk),
          onPressed: () => setState(() => _mode = null),
        ),
        title: Row(children: [
          Text(_mode == 'flashcard'
              ? (_isFr ? '🃏 Cartes' : '🃏 Flashcards')
              : '🎯 Quiz',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kInk)),
          const Spacer(),
          _Pill('${_done ? total : _idx + 1}/$total', const Color(0xFFE2E8F0), const Color(0xFF475569)),
          const SizedBox(width: 6),
          _Pill('✓ $_score', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
        ]),
        actions: const [SizedBox(width: 12)],
      ),
      body: Column(children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE2E8F0),
          color: _accent,
          minHeight: 4,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _done
                ? _buildDone(total)
                : _mode == 'flashcard'
                    ? _buildFlashcard(card!)
                    : _buildQuiz(card!),
          ),
        ),
      ]),
    );
  }

  // ── Done screen ────────────────────────────────────────────────────────────

  Widget _buildDone(int total) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✅', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(_isFr ? 'Terminé !' : 'Done!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk)),
        const SizedBox(height: 8),
        Text(_isFr ? 'Votre score' : 'Your score',
            style: const TextStyle(fontSize: 14, color: kMuted)),
        const SizedBox(height: 12),
        RichText(text: TextSpan(children: [
          TextSpan(text: '$_score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _accent)),
          TextSpan(text: ' / $total', style: const TextStyle(fontSize: 32, color: kMuted, fontWeight: FontWeight.w400)),
        ])),
        const SizedBox(height: 32),
        SizedBox(width: 260, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: _restart,
          child: Text(_isFr ? 'Recommencer' : 'Restart',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        )),
        const SizedBox(height: 10),
        SizedBox(width: 260, child: OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: kMuted,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () => setState(() => _mode = null),
          child: Text(_isFr ? 'Changer de mode' : 'Change mode',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        )),
      ]),
    ),
  );

  // ── Flashcard ──────────────────────────────────────────────────────────────

  Widget _buildFlashcard(_Card card) {
    final question = _isFr ? card.fr : card.en;
    return Column(children: [
      GestureDetector(
        onTap: () => setState(() => _flipped = !_flipped),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _flipped
              ? _CardFace(key: const ValueKey('back'), color: const Color(0xFFEFF6FF),
                  borderColor: const Color(0x331B4FD8),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(card.medumba,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _accent)),
                    const SizedBox(height: 8),
                    Text(_isFr ? 'Medumba' : 'Medumba',
                        style: const TextStyle(fontSize: 11, color: kMuted)),
                  ]))
              : _CardFace(key: const ValueKey('front'), color: Colors.white,
                  borderColor: kBorder,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kInk)),
                    const SizedBox(height: 12),
                    Text(_isFr ? 'Appuyez pour révéler' : 'Tap to reveal',
                        style: const TextStyle(fontSize: 12, color: kMuted)),
                  ])),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _ActionBtn(
          label: _isFr ? '✗  À revoir' : '✗  Review',
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFFF1F2),
          border: const Color(0xFFFECACA),
          onTap: () => _advance(false),
        )),
        const SizedBox(width: 10),
        Expanded(child: _ActionBtn(
          label: _isFr ? '✓  Je sais !' : '✓  I know!',
          color: const Color(0xFF16A34A),
          bg: const Color(0xFFF0FDF4),
          border: const Color(0xFFBBF7D0),
          onTap: () => _advance(true),
        )),
      ]),
    ]);
  }

  // ── Quiz ───────────────────────────────────────────────────────────────────

  Widget _buildQuiz(_Card card) {
    final question = _isFr ? card.fr : card.en;
    final correct  = card.medumba;
    final isRight  = _sel == correct;

    return Column(children: [
      // Question card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kInk)),
      ),
      const SizedBox(height: 16),
      // Options 2×2
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
        children: card.opts.map((opt) {
          Color bg = Colors.white;
          Color border = kBorder;
          Color text = kInk;
          if (!_checked) {
            if (_sel == opt) { bg = const Color(0xFFEFF6FF); border = _accent; text = _accent; }
          } else {
            if (opt == correct) { bg = const Color(0xFFF0FDF4); border = const Color(0xFF22C55E); text = const Color(0xFF15803D); }
            else if (_sel == opt) { bg = const Color(0xFFFFF1F2); border = const Color(0xFFEF4444); text = const Color(0xFFDC2626); }
            else { bg = const Color(0xFFFAFAFA); text = kMuted; }
          }
          return GestureDetector(
            onTap: () { if (!_checked) setState(() => _sel = opt); },
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(opt,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: text)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      // Feedback
      if (_checked)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isRight ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
            border: Border.all(color: isRight ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Text(isRight ? '🎉' : '💡', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              isRight
                  ? (_isFr ? 'Bonne réponse !' : 'Correct!')
                  : (_isFr ? 'La bonne réponse : $correct' : 'Correct answer: $correct'),
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13,
                color: isRight ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
            )),
          ]),
        ),
      const SizedBox(height: 12),
      // Check / Continue
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (_sel != null || _checked) ? _accent : const Color(0xFFE2E8F0),
            foregroundColor: (_sel != null || _checked) ? Colors.white : kMuted,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          onPressed: (_sel == null && !_checked)
              ? null
              : () {
                  if (!_checked) setState(() => _checked = true);
                  else _advance(isRight);
                },
          child: Text(
            _checked
                ? (_isFr ? 'Continuer →' : 'Continue →')
                : (_isFr ? 'Vérifier →' : 'Check →'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    ]);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String text; final Color bg, fg;
  const _Pill(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
  );
}

class _CardFace extends StatelessWidget {
  final Color color, borderColor;
  final Widget child;
  const _CardFace({super.key, required this.color, required this.borderColor, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 200,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: 1.5),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}

class _ActionBtn extends StatelessWidget {
  final String label; final Color color, bg, border; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.bg, required this.border, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: bg, border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}
