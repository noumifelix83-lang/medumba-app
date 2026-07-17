import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/lesson_themes.dart';
import '../data/medumba_expressions.dart';
import '../services/user_service.dart';
import '../state/app_language.dart';
import '../theme/colors.dart';

// Recap exam per unit — passing (>= 80%) earns a CEPOM certificate.
// Mirrors src/data/certification.js / CertificationPage.jsx on the web app.

const kPassThreshold = 0.8;
const kExamQuestionCount = 12;

class _UnitCert {
  final List<String> lessonIds;
  final String titleFr, titleEn;
  const _UnitCert({required this.lessonIds, required this.titleFr, required this.titleEn});
}

const kUnitCertifications = <String, _UnitCert>{
  '1': _UnitCert(lessonIds: ['l0', 'l1', 'l2', 'l3', 'l4', 'l5'], titleFr: 'Les Bases', titleEn: 'Foundations'),
  '2': _UnitCert(lessonIds: ['l6', 'l7', 'l8'], titleFr: 'Personnes & Monde', titleEn: 'People & World'),
  '3': _UnitCert(lessonIds: ['l9', 'l10'], titleFr: 'Vie Quotidienne', titleEn: 'Daily Life'),
  '4': _UnitCert(lessonIds: ['l11', 'l12', 'l13', 'l14'], titleFr: 'Société & Santé', titleEn: 'Society & Health'),
  '5': _UnitCert(lessonIds: ['l15', 'l16', 'l17'], titleFr: 'Culture & Langue', titleEn: 'Culture & Language'),
};

class _Question {
  final _QType type;
  final String prompt;
  final List<String> options;
  final String answer;
  const _Question({required this.type, required this.prompt, required this.options, required this.answer});
}

enum _QType { mcqFr2Med, mcqMed2Fr }

class CertificationScreen extends StatefulWidget {
  final String unitId;
  const CertificationScreen({super.key, required this.unitId});
  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  List<MExpr> _pool = [];
  List<_Question> _questions = [];
  String _phase = 'intro'; // intro | exam | passed | failed
  int _currentQ = 0;
  String? _selectedOption;
  String? _status; // correct | wrong | null
  bool _continueEnabled = false;
  int _correctCount = 0;

  _UnitCert get _unit => kUnitCertifications[widget.unitId] ?? kUnitCertifications['1']!;
  bool get _isFr => AppLanguage.instance.isFr;

  @override
  void initState() {
    super.initState();
    _initPool();
  }

  void _initPool() {
    final rng = Random();
    _pool = _unit.lessonIds
        .expand((id) => getExpressionsForLesson(id))
        .toSet()
        .toList()
      ..shuffle(rng);
    if (_pool.length < 5) _pool = ([...kAllExpressions]..shuffle(rng));
    _questions = _buildQuestions(rng);
  }

  List<_Question> _buildQuestions(Random rng) {
    final studied = (_pool.toList()..shuffle(rng)).take((kExamQuestionCount / 2).ceil()).toList();
    final qs = <_Question>[];
    for (final card in studied) {
      final dMed = _pool.where((e) => e.medumba != card.medumba).map((e) => e.medumba).toSet().take(3).toList();
      qs.add(_Question(type: _QType.mcqFr2Med, prompt: card.fr, options: [card.medumba, ...dMed]..shuffle(rng), answer: card.medumba));

      final dFr = _pool.where((e) => e.fr != card.fr).map((e) => e.fr).toSet().take(3).toList();
      qs.add(_Question(type: _QType.mcqMed2Fr, prompt: card.medumba, options: [card.fr, ...dFr]..shuffle(rng), answer: card.fr));
    }
    qs.shuffle(rng);
    return qs.take(kExamQuestionCount).toList();
  }

  void _checkAnswer() {
    final q = _questions[_currentQ];
    final correct = _selectedOption == q.answer;
    setState(() { _status = correct ? 'correct' : 'wrong'; _continueEnabled = false; });
    if (correct) _correctCount++;
    Future.delayed(const Duration(milliseconds: 350), () { if (mounted) setState(() => _continueEnabled = true); });
  }

  void _handleContinue() {
    if (_currentQ >= _questions.length - 1) {
      final pct = _questions.isNotEmpty ? _correctCount / _questions.length : 0;
      if (pct >= kPassThreshold) {
        _markPassed();
        setState(() => _phase = 'passed');
      } else {
        setState(() => _phase = 'failed');
      }
    } else {
      setState(() { _currentQ++; _selectedOption = null; _status = null; _continueEnabled = false; });
    }
  }

  Future<void> _markPassed() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    await UserService.completeCertification(uid, widget.unitId);
  }

  void _retry() {
    final rng = Random();
    setState(() {
      _questions = _buildQuestions(rng);
      _phase = 'exam';
      _currentQ = 0;
      _selectedOption = null;
      _status = null;
      _continueEnabled = false;
      _correctCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase != 'exam',
      onPopInvokedWithResult: (didPop, _) {},
      child: switch (_phase) {
        'exam'   => _buildExam(),
        'passed' => _buildPassed(),
        'failed' => _buildFailed(),
        _        => _buildIntro(),
      },
    );
  }

  // ── INTRO ──────────────────────────────────────────────────────────────
  Widget _buildIntro() {
    const blue = kBlue;
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Align(alignment: Alignment.centerLeft,
                child: IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => context.pop())),
          ),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🎓', style: TextStyle(fontSize: 88)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _isFr ? 'Examen de certification' : 'Certification exam',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(_isFr ? _unit.titleFr : _unit.titleEn, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _StatPill('📝', '$kExamQuestionCount', _isFr ? 'Questions' : 'Questions'),
                  _StatPill('✅', '80%', _isFr ? 'Pour réussir' : 'To pass'),
                  _StatPill('🎓', 'CEPOM', _isFr ? 'Certificat' : 'Certificate'),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity, height: 58,
              child: ElevatedButton(
                onPressed: () => setState(() => _phase = 'exam'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
                child: Text(_isFr ? "Commencer l'examen" : 'Start the exam', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── EXAM ───────────────────────────────────────────────────────────────
  Widget _buildExam() {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = _questions[_currentQ];
    final progress = (_currentQ + 1) / _questions.length;
    const blue = kBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBorder, width: 2)),
                  child: const Icon(Icons.close, size: 18, color: kMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: progress, minHeight: 14, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation(blue)),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_currentQ + 1}/${_questions.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: blue)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 0), child: _buildMcq(q))),
          _buildBottomBar(q),
        ]),
      ),
    );
  }

  Widget _buildMcq(_Question q) {
    final isFr2Med = q.type == _QType.mcqFr2Med;
    const labels = ['A', 'B', 'C', 'D'];
    const blue = kBlue;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        isFr2Med
            ? (_isFr ? 'Quelle est la traduction en Medumba ?' : 'What is the Medumba translation?')
            : (_isFr ? 'Quelle est la traduction en Français ?' : 'What is the French translation?'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kInk),
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(16)),
        child: Text(q.prompt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
      ),
      const SizedBox(height: 20),
      ...q.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        final isSelected = _selectedOption == opt;
        final isCorrect = _status != null && opt == q.answer;
        final isWrong = _status != null && isSelected && opt != q.answer;

        Color bg = Colors.white, borderColor = kBorder, textColor = kInk;
        Color labelBg = const Color(0xFFF1F5F9), labelText = kMuted;

        if (isCorrect) {
          bg = const Color(0xFFDCFCE7); borderColor = const Color(0xFF4ADE80); textColor = const Color(0xFF15803D);
          labelBg = const Color(0xFF4ADE80); labelText = Colors.white;
        } else if (isWrong) {
          bg = const Color(0xFFFEF2F2); borderColor = const Color(0xFFFCA5A5); textColor = const Color(0xFFDC2626);
          labelBg = const Color(0xFFFCA5A5); labelText = Colors.white;
        } else if (isSelected) {
          bg = Color.alphaBlend(blue.withValues(alpha: 0.08), Colors.white);
          borderColor = blue; textColor = blue; labelBg = blue; labelText = Colors.white;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: _status != null ? null : () => setState(() => _selectedOption = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(color: bg, border: Border.all(color: borderColor, width: 2), borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(idx < labels.length ? labels[idx] : '${idx + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: labelText)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(opt, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor))),
              ]),
            ),
          ),
        );
      }),
    ]);
  }

  Widget _buildBottomBar(_Question q) {
    final hasInput = _selectedOption != null;
    final isCorrect = _status == 'correct';
    final isLast = _currentQ >= _questions.length - 1;
    const blue = kBlue;

    if (_status != null) {
      final barColor = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
      final lightBg = isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
      return Container(
        color: lightBg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: barColor, padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                child: Icon(isCorrect ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isCorrect ? (_isFr ? 'Correct !' : 'Correct!') : (_isFr ? 'Mauvaise réponse !' : 'Wrong answer!'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  if (!isCorrect) ...[
                    const SizedBox(height: 2),
                    Text('${_isFr ? 'Réponse' : 'Answer'} : ${q.answer}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
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
                style: ElevatedButton.styleFrom(backgroundColor: barColor, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(isLast ? (_isFr ? 'Terminer' : 'Finish') : (isCorrect ? (_isFr ? 'CONTINUER' : 'CONTINUE') : 'OK'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: kBorder))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasInput ? _checkAnswer : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: hasInput ? blue : const Color(0xFFE2E8F0),
              foregroundColor: hasInput ? Colors.white : const Color(0xFF94A3B8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(_isFr ? 'Vérifier' : 'Check', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }

  // ── PASSED — CEPOM certificate ──────────────────────────────────────────
  Widget _buildPassed() {
    final accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length * 100).round() : 0;
    const gold = Color(0xFFB45309);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: gold.withValues(alpha: 0.35), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 28, offset: const Offset(0, 10))],
              ),
              child: Column(children: [
                const Text('🎓', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 10),
                Text(_isFr ? 'CERTIFICAT CEPOM' : 'CEPOM CERTIFICATE', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: gold, letterSpacing: 1.4)),
                const SizedBox(height: 10),
                Text(_isFr ? _unit.titleFr : _unit.titleEn,
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kInk)),
                const SizedBox(height: 6),
                Text(_isFr ? 'Certification obtenue avec $accuracy% de réussite.' : 'Certification earned with $accuracy% accuracy.',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: kMuted)),
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 58,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
                child: Text(_isFr ? 'CONTINUER' : 'CONTINUE', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── FAILED ───────────────────────────────────────────────────────────────
  Widget _buildFailed() {
    final accuracy = _questions.isNotEmpty ? (_correctCount / _questions.length * 100).round() : 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('📘', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(_isFr ? 'Pas encore certifié' : 'Not certified yet',
                style: const TextStyle(color: kInk, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('$_correctCount/${_questions.length} ($accuracy%)', style: const TextStyle(color: kMuted, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFBFDBFE)), borderRadius: BorderRadius.circular(16)),
              child: Text(
                _isFr ? 'Il faut 80% pour obtenir la certification CEPOM.\nRévisez et réessayez !' : 'You need 80% to earn the CEPOM certification.\nReview and try again!',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w700, fontSize: 14), textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
                child: Text(_isFr ? 'Réessayer' : 'Try again', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.pop(), child: Text(_isFr ? 'Retourner au tableau de bord' : 'Back to dashboard', style: const TextStyle(color: kMuted))),
          ]),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji, value, label;
  const _StatPill(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11, fontWeight: FontWeight.w600)),
      ]);
}
