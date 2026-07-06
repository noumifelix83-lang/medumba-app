import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/colors.dart';

// Timestamps (sec) dans vocal_count_medumba.ogg — extrait depuis CountingPage.jsx
const _audioMap = <int, List<double>>{
  0:    [2.50,  3.60],
  1:    [5.20,  6.05],
  2:    [7.90,  8.70],
  3:    [10.90, 11.40],
  4:    [13.45, 14.15],
  5:    [16.60, 17.10],
  6:    [18.75, 19.65],
  7:    [21.30, 22.35],
  8:    [23.95, 24.70],
  9:    [26.40, 27.30],
  10:   [28.95, 29.55],
  11:   [31.40, 33.35],
  12:   [34.85, 37.00],
  13:   [38.50, 40.35],
  14:   [41.85, 43.60],
  15:   [45.05, 46.75],
  16:   [48.20, 50.05],
  17:   [51.35, 53.45],
  18:   [54.70, 56.70],
  19:   [57.95, 60.00],
  20:   [73.25, 73.95],
  30:   [74.70, 76.45],
  40:   [77.95, 79.80],
  50:   [80.10, 83.00],
  60:   [83.35, 84.15],
  70:   [86.85, 87.65],
  80:   [90.20, 93.30],
  90:   [94.65, 95.80],
  100:  [97.60, 99.20],
  1000: [100.75,102.55],
};

// ── Traducteur de nombres Medumba (porté depuis medumba_counter.jar) ──────────
const _U = ["bαnbαn","ncʉ'","bα̂","tad","kuὰ","tὰn","ntogə","sὰmbα̂","fomə","bwə̀'ə"];
const _C = ["",       "ncʉ'","bα̂","tad","kuὰ","tὰn","ntôg", "sὰmbα̂","fôm", "bwə̀'ə̂"];
const _T = ["","gham","ŋambα̂","ŋamntad","ŋamkuὰ","ŋamntὰn","ŋamntogə","ŋamsὰmbα̂","ŋamfomə","ŋambwə̀'ə"];
const _B = ["","","bonbα̂","bontad","bonkuὰ","bontὰn","bonntôg","bonsὰmbα̂","bonfôm","bonbwə̀'ə"];
const _H = ["","nkʉ","nkʉbα̂","nkʉtad","nkʉkuὰ","nkʉtὰn","nkʉntogə","nkʉsὰmbα̂","nkʉfomə","nkʉbwə̀'ə"];

String _toMedumba(int n) {
  if (n == 0)    return "bαnbαn";
  if (n == 1000) return "ncaꞌ";
  final h = n ~/ 100;
  final r = n % 100;
  final d = r ~/ 10;
  final u = r % 10;
  if (h > 0) {
    final hun = _H[h];
    if (r == 0)   return hun;
    if (r <= 9)   return "${_C[r]}tû $hun";
    if (r == 10)  return "mɛnmbʉ̂m $hun";
    if (r <= 19)  return "ncòb${_C[u]} mɛnmbʉ̂m $hun";
    final bt = _B[d];
    return u == 0 ? "$bt $hun" : "ncòb${_C[u]} $bt $hun";
  }
  if (n <= 9)   return _U[n];
  if (n == 10)  return "gham";
  if (n <= 19)  return "ncòb${_C[u]} gham";
  return u == 0 ? _T[d] : "ncòb${_C[u]} ${_T[d]}";
}

// ── Liste complète des nombres ────────────────────────────────────────────────
class _Num { final int n; final String medumba, fr, en; const _Num(this.n, this.medumba, this.fr, this.en); }

const _numbers = [
  _Num(0,   "bαnbαn",             "Zéro",             "Zero"),
  _Num(1,   "ncʉ'",               "Un",               "One"),
  _Num(2,   "bα̂",                 "Deux",              "Two"),
  _Num(3,   "tad",                "Trois",             "Three"),
  _Num(4,   "kuὰ",                "Quatre",            "Four"),
  _Num(5,   "tὰn",                "Cinq",              "Five"),
  _Num(6,   "ntogə",              "Six",               "Six"),
  _Num(7,   "sὰmbα̂",             "Sept",              "Seven"),
  _Num(8,   "fomə",               "Huit",              "Eight"),
  _Num(9,   "bwə̀'ə",             "Neuf",              "Nine"),
  _Num(10,  "gham",               "Dix",               "Ten"),
  _Num(11,  "ncòbncʉ' gham",      "Onze",              "Eleven"),
  _Num(12,  "ncòbbα̂ gham",        "Douze",             "Twelve"),
  _Num(13,  "ncòbtad gham",       "Treize",            "Thirteen"),
  _Num(14,  "ncòbkuὰ gham",       "Quatorze",         "Fourteen"),
  _Num(15,  "ncòbtὰn gham",       "Quinze",            "Fifteen"),
  _Num(16,  "ncòbntôg gham",      "Seize",             "Sixteen"),
  _Num(17,  "ncòbsὰmbα̂ gham",    "Dix-sept",          "Seventeen"),
  _Num(18,  "ncòbfôm gham",       "Dix-huit",          "Eighteen"),
  _Num(19,  "ncòbbwə̀'ə̂ gham",    "Dix-neuf",         "Nineteen"),
  _Num(20,  "ŋambα̂",              "Vingt",             "Twenty"),
  _Num(21,  "ncòbncʉ' ŋambα̂",    "Vingt et un",       "Twenty-one"),
  _Num(22,  "ncòbbα̂ ŋambα̂",      "Vingt-deux",        "Twenty-two"),
  _Num(30,  "ŋamntad",            "Trente",            "Thirty"),
  _Num(40,  "ŋamkuὰ",             "Quarante",          "Forty"),
  _Num(50,  "ŋamntὰn",            "Cinquante",         "Fifty"),
  _Num(60,  "ŋamntogə",           "Soixante",          "Sixty"),
  _Num(70,  "ŋamsὰmbα̂",          "Soixante-dix",      "Seventy"),
  _Num(80,  "ŋamfomə",            "Quatre-vingts",     "Eighty"),
  _Num(90,  "ŋambwə̀'ə",          "Quatre-vingt-dix",  "Ninety"),
  _Num(100, "nkʉ",                "Cent",              "One hundred"),
  _Num(200, "nkʉbα̂",              "Deux cents",        "Two hundred"),
  _Num(300, "nkʉtad",             "Trois cents",       "Three hundred"),
  _Num(500, "nkʉtὰn",             "Cinq cents",        "Five hundred"),
  _Num(1000,"ncaꞌ",               "Mille",             "One thousand"),
];

// Pool quiz (0-30 seulement)
List<_Num> get _quizPool => _numbers.where((n) => n.n <= 30).toList();

// ── Vocabulaire mathématique (medumbaMath.js — 63 termes) ─────────────────
class _Math { final String fr, medumba; const _Math(this.fr, this.medumba); }
const _mathTerms = [
  _Math('Addition',                        'tnə̀cùbə'),
  _Math('Autant',                          "tNjòŋncʉ'"),
  _Math('Calcul',                          'tata'),
  _Math('Calcul réfléchi',                 'kwànta'),
  _Math('Capacité',                        "Mfì'ntʉ̂mju'"),
  _Math('Carré',                           'Kàmcɛd'),
  _Math('Classification',                  'Nə̀yαbtə / nə̀tətə'),
  _Math('Commutativité',                   'Bwɔ̀njàmbαhα'),
  _Math('Comparaison',                     "tLò'mfì'"),
  _Math('Complément',                      'mìb'),
  _Math('Composantes',                     'Cû…'),
  _Math('Compter',                         'Nə̀ tʉntə'),
  _Math('Conversion De Mesure',            "tKàŋfì'"),
  _Math('Cube',                            'tSagntogə / Kumntogə'),
  _Math('Décomposition',                   "tNə̀co'tə"),
  _Math('Dénombrement',                    'tDiàgnjòŋ'),
  _Math('Différence',                      'tFàgtə'),
  _Math('Dizaines',                        'Cû gham'),
  _Math('Double',                          'fag'),
  _Math('Durée',                           'Nə̀tswə'),
  _Math("Ensemble",                        "Nca'"),
  _Math('Espace',                          "Dʉ'"),
  _Math("Figure Géométrique",              "Sə̂və̀ Ngα̂mmfì'"),
  _Math('Fraction',                        'mfè'),
  _Math('Inférieur',                       'Nə̀kαgncʉα̂'),
  _Math('Largeur',                         'Nəzi / zi'),
  _Math('Lettre',                          "Lα̂gŋwà'nì"),
  _Math('Ligne',                           'nka'),
  _Math('Longueur',                        'Nə̀sàgə / sàg'),
  _Math('Masse',                           'Lɛ̀d'),
  _Math('Mesure',                          "Mfì'"),
  _Math('Mesure Du Temps',                 "Mfì' ngə̀laŋ"),
  _Math('Moitié',                          'kàm'),
  _Math('Mesure de longueur',              "Mfì'sàg"),
  _Math('Multiplication',                  'Nə̀yòŋə / nə̀ fǎ'),
  _Math('Nombre',                          'tJutʉntə̀'),
  _Math('Nombre Consécutif',               'Jûnjǒŋtʉntə̀ nkànkà'),
  _Math('Orientation Du Plan Géométrique', 'Nə̀yαbnzə̀ nka'),
  _Math('Pavé droit',                      'Tô\'nsα̌nkumntogə'),
  _Math('Partage',                         'Ghὰbtə̀'),
  _Math('Plus grand que',                  'Nə̀yαmncʉα̂'),
  _Math('plus petit que',                  'Nə̀kαgncʉα̂'),
  _Math('Problème',                        'kwànta'),
  _Math('Produit',                         'tαmyòŋ'),
  _Math('Propriété',                       'Jûl̀ɛ̀n'),
  _Math('Ranger',                          'Nə cαbə'),
  _Math('Rectangle',                       'Nsὰcɛd'),
  _Math('Règle',                           'kὰn'),
  _Math('Relation',                        'Làdtə̀ / lì'),
  _Math("Repérage",                        "Kì' / nətənkə̀kì'"),
  _Math('Repère',                          "Kə̀kì'"),
  _Math('Reproduction',                    'mfunì'),
  _Math('Résoudre',                        "Nə̀mǎ'tu"),
  _Math('Résultat',                        'Cɔ̀'),
  _Math('Réunion',                         'Ntàmtə̀'),
  _Math('Retenu',                          "Lě'ju"),
  _Math('Solide',                          'Jûnə̀ta'),
  _Math('Somme',                           'Cɔ̀cùb'),
  _Math('Suite Des Nombres Naturels',      'Tǔncûnjǒŋtʉntə̀'),
  _Math('Suite Des Nombres Pairs',         'Tàŋnka fâg njǒŋtʉntə̀'),
  _Math('Symbole',                         "Kə̀kì'"),
  _Math('Système De Numération',           'Màd nə̀ tʉntə'),
  _Math('Table',                           'Cɛd'),
];

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});
  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _isFr = true;

  // Quiz state
  late _QuizQ _quiz;
  int? _picked;
  int _score = 0;
  int _quizNum = 1;
  bool _quizDone = false;
  static const _quizTotal = 10;

  // Converter
  final _convCtrl = TextEditingController();

  // Math search
  String _mathQuery = '';

  // Audio
  final _player = AudioPlayer();
  int? _speaking;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _quiz = _makeQuiz();
    _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed && mounted) {
        setState(() => _speaking = null);
      }
    });
  }

  @override
  void dispose() { _tab.dispose(); _convCtrl.dispose(); _player.dispose(); super.dispose(); }

  Future<void> _playNumber(int n) async {
    final seg = _audioMap[n];
    if (seg == null) return;
    if (_speaking != null) { await _player.stop(); }
    setState(() => _speaking = n);
    try {
      final start = Duration(milliseconds: (seg[0] * 1000).toInt());
      final end   = Duration(milliseconds: (seg[1] * 1000).toInt());
      await _player.setAudioSource(ClippingAudioSource(
        child: AudioSource.asset('assets/audio/vocal_count_medumba.ogg'),
        start: start,
        end: end,
      ));
      _player.play();
    } catch (_) {
      if (mounted) setState(() => _speaking = null);
    }
  }

  _QuizQ _makeQuiz() {
    final pool = List<_Num>.from(_quizPool)..shuffle();
    final q = pool.first;
    final wrong = (pool..removeWhere((x) => x.n == q.n)).take(3).toList();
    final opts = [q, ...wrong]..shuffle();
    return _QuizQ(q: q, opts: opts);
  }

  void _pick(int n) {
    if (_picked != null) return;
    setState(() {
      _picked = n;
      if (n == _quiz.q.n) _score++;
    });
  }

  void _nextQuiz() {
    if (_quizNum >= _quizTotal) {
      setState(() => _quizDone = true);
    } else {
      setState(() { _quizNum++; _picked = null; _quiz = _makeQuiz(); });
    }
  }

  void _restartQuiz() {
    setState(() { _score = 0; _quizNum = 1; _quizDone = false; _picked = null; _quiz = _makeQuiz(); });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0891B2);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(116),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF67E8F9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_isFr ? '110 nombres · 0 – 1 000' : '110 numbers · 0 – 1,000',
                        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    Text('🔢 ${_isFr ? 'Compter' : 'Counting'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  ])),
                  TextButton(
                    onPressed: () => setState(() => _isFr = !_isFr),
                    child: Text(_isFr ? 'EN' : 'FR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
              TabBar(
                controller: _tab,
                labelColor: accent,
                unselectedLabelColor: Colors.white70,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                tabs: [
                  Tab(text: _isFr ? 'LISTE' : 'LIST'),
                  Tab(text: 'QUIZ'),
                  Tab(text: _isFr ? 'CONVERTIR' : 'CONVERT'),
                  Tab(text: 'MATHS'),
                ],
              ),
            ]),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList(accent),
          _buildQuiz(accent),
          _buildConverter(accent),
          _buildMath(accent),
        ],
      ),
    );
  }

  // ── Tab 1 : Liste ──────────────────────────────────────────────────────────

  Widget _buildList(Color accent) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _numbers.length,
      itemBuilder: (_, i) {
        final num = _numbers[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF67E8F9)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('${num.n}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(num.medumba, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
              Text(_isFr ? num.fr : num.en, style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
            ])),
            GestureDetector(
              onTap: () => _playNumber(num.n),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _audioMap.containsKey(num.n)
                      ? accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _speaking == num.n
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2, color: accent))
                    : Icon(Icons.volume_up_rounded,
                        color: _audioMap.containsKey(num.n)
                            ? accent
                            : accent.withValues(alpha: 0.25),
                        size: 20),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── Tab 2 : Quiz ──────────────────────────────────────────────────────────

  Widget _buildQuiz(Color accent) {
    if (_quizDone) {
      final passed = _score / _quizTotal >= 0.6;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(passed ? '🎉' : '😓', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('$_score / $_quizTotal', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: kInk)),
            Text('${(_score / _quizTotal * 100).round()}%', style: const TextStyle(fontSize: 16, color: kMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: passed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                border: Border.all(color: passed ? kGreen : kRed),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                passed
                  ? (_isFr ? '✅ Bravo ! Vous avez réussi.' : '✅ Well done! You passed.')
                  : (_isFr ? '❌ Score insuffisant (min. 60%). Recommencez !' : '❌ Score too low (min. 60%). Restart!'),
                style: TextStyle(fontWeight: FontWeight.w700, color: passed ? kGreen : kRed),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: passed ? kGreen : kRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
                child: Text(_isFr ? '🔄 Recommencer' : '🔄 Play again', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Barre de progression
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: (_quizNum - 1) / _quizTotal, minHeight: 8, backgroundColor: kBorder, valueColor: AlwaysStoppedAnimation(accent)),
          )),
          const SizedBox(width: 10),
          Text('$_quizNum / $_quizTotal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(99)),
            child: Text('⭐ $_score', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent)),
          ),
        ]),
        const SizedBox(height: 20),

        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            Text(_isFr ? 'Que signifie ce mot Medumba ?' : 'What does this Medumba word mean?',
                style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(_quiz.q.medumba, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accent)),
          ]),
        ),
        const SizedBox(height: 16),

        // Options (grille 2x2)
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
          children: _quiz.opts.map((opt) {
            final isCorrect = _picked != null && opt.n == _quiz.q.n;
            final isWrong   = _picked == opt.n && opt.n != _quiz.q.n;
            Color bg = Colors.white, border = const Color(0xFFBAE6FD), textColor = kInk;
            if (isCorrect) { bg = const Color(0xFFDCFCE7); border = kGreen; textColor = kGreen; }
            if (isWrong)   { bg = const Color(0xFFFEE2E2); border = kRed;   textColor = kRed; }
            if (_picked != null && !isCorrect && !isWrong) { bg = const Color(0xFFF8FAFC); border = kBorder; textColor = kMuted; }

            return GestureDetector(
              onTap: () => _pick(opt.n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 2), borderRadius: BorderRadius.circular(16)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${opt.n}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                  Text(_isFr ? opt.fr : opt.en, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: 0.7))),
                ]),
              ),
            );
          }).toList(),
        ),

        if (_picked != null) ...[
          const SizedBox(height: 16),
          Text(
            _picked == _quiz.q.n
              ? (_isFr ? '✅ Correct !' : '✅ Correct!')
              : (_isFr ? '❌ C\'était : ${_quiz.q.n} — ${_quiz.q.medumba}' : '❌ It was: ${_quiz.q.n} — ${_quiz.q.medumba}'),
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _picked == _quiz.q.n ? kGreen : kRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _nextQuiz,
              style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
              child: Text(
                _quizNum >= _quizTotal
                  ? (_isFr ? 'Voir les résultats →' : 'See results →')
                  : (_isFr ? 'Suivant →' : 'Next →'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  // ── Tab 3 : Convertisseur ──────────────────────────────────────────────────

  Widget _buildConverter(Color accent) {
    return StatefulBuilder(builder: (_, setS) {
      final raw = _convCtrl.text.trim();
      final n = raw.isEmpty ? null : int.tryParse(raw);
      final valid = n != null && n >= 0 && n <= 1000;
      final medumba = valid ? _toMedumba(n) : null;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_isFr ? 'Entrez un nombre (0 – 1000)' : 'Enter a number (0 – 1,000)',
                  style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              TextField(
                controller: _convCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (_) => setS(() {}),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kInk),
                decoration: InputDecoration(
                  hintText: 'ex: 347',
                  hintStyle: const TextStyle(color: kBorder),
                  filled: true, fillColor: const Color(0xFFF0F9FF),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withValues(alpha: 0.4))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withValues(alpha: 0.4))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent, width: 2)),
                ),
              ),
              if (raw.isNotEmpty && !valid)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_isFr ? 'Nombre invalide (0 – 1000)' : 'Invalid number (0 – 1,000)',
                      style: const TextStyle(color: kRed, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
            ]),
          ),
          if (medumba != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                Text(_isFr ? 'En Medumba' : 'In Medumba',
                    style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(medumba, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: accent, height: 1.3)),
                const SizedBox(height: 4),
                Text('= $n', style: const TextStyle(fontSize: 16, color: kMuted, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
          if (raw.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(_isFr ? 'Tapez un nombre pour voir sa traduction' : 'Type a number to see its translation',
                  style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ),
        ]),
      );
    });
  }

  // ── Tab 4 : Mathématiques ──────────────────────────────────────────────────

  Widget _buildMath(Color accent) {
    final filtered = _mathTerms.where((m) {
      final q = _mathQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return m.fr.toLowerCase().contains(q) || m.medumba.toLowerCase().contains(q);
    }).toList();

    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: TextField(
          onChanged: (v) => setState(() => _mathQuery = v),
          decoration: InputDecoration(
            hintText: _isFr ? 'Rechercher un terme…' : 'Search a term…',
            hintStyle: const TextStyle(color: kMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
            suffixIcon: _mathQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: kMuted, size: 18),
                    onPressed: () => setState(() => _mathQuery = ''))
                : null,
            filled: true, fillColor: const Color(0xFFF0F9FF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(children: [
          Text('${filtered.length} / ${_mathTerms.length} ${_isFr ? "termes" : "terms"}',
              style: const TextStyle(fontSize: 11, color: kMuted, fontWeight: FontWeight.w600)),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final m = filtered[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.6)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('∑', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.fr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInk)),
                  Text(m.medumba, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: accent)),
                ])),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _QuizQ { final _Num q; final List<_Num> opts; _QuizQ({required this.q, required this.opts}); }
