import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';

// ── Données ──────────────────────────────────────────────────────────────────

enum _LetterType { vowel, consonant }

class _Letter {
  final String letter;
  final _LetterType type;
  final String ipa, phoneFr, phoneEn, color, example, exMeanFr, exMeanEn;
  const _Letter(this.letter, this.type, this.ipa, this.phoneFr, this.phoneEn, this.color, this.example, this.exMeanFr, this.exMeanEn);
  bool get isSpecial => letter.length > 1;
}

const _vowel = _LetterType.vowel;
const _cons  = _LetterType.consonant;
const _blue  = '#0056D2';
const _green = '#16a34a';
const _purple = '#7c3aed';

const _letters = [
  _Letter('a',  _vowel, '[a]',  'comme "a" dans "patte"',        'like "a" in "father"',        _blue,   'a tə̂',    'et',         'and'),
  _Letter('α',  _vowel, '[ɑ]',  '"a" postérieur / nasalisé',     'back "a", nasalized',          _blue,   'Mα̂',      'mère',       'mother'),
  _Letter('ε',  _vowel, '[ɛ]',  'comme "è" dans "fête"',         'like "e" in "bed"',            _blue,   'mεn',     'enfant',     'child'),
  _Letter('b',  _cons,  '[b]',  'comme "b" français',            'like "b" in "boy"',            _green,  "baꞌ",     'maison',     'house'),
  _Letter('c',  _cons,  '[tʃ]', 'comme "tch"',                   'like "ch" in "church"',        _green,  "cα̂ꞌ",    'chien',      'dog'),
  _Letter('d',  _cons,  '[d]',  'comme "d" français',            'like "d" in "day"',            _green,  'ndα',     'main',       'hand'),
  _Letter('e',  _vowel, '[e]',  'comme "é" dans "été"',          'like "ay" in "day"',           _blue,   'meꞌe',    'chèvre',     'goat'),
  _Letter('ə',  _vowel, '[ə]',  'comme "e" dans "le"',           'like "a" in "about"',          _blue,   "bwə̀ꞌə",  'neuf',       'nine'),
  _Letter('f',  _cons,  '[f]',  'comme "f" français',            'like "f" in "fish"',           _green,  'fomə',    'huit',       'eight'),
  _Letter('g',  _cons,  '[g]',  'comme "g" dans "gare"',         'like "g" in "go"',             _green,  'ngàb',    'chèvre',     'goat'),
  _Letter('gh', _cons,  '[ɣ]',  'fricative vélaire sonore',      'voiced velar fricative',       _purple, 'ghom',    'corps',      'body'),
  _Letter('h',  _cons,  '[h]',  'h aspiré (anglais)',             'like "h" in "hello"',          _green,  'hàm',     'bouche',     'mouth'),
  _Letter('i',  _vowel, '[i]',  'comme "i" dans "vie"',          'like "ee" in "see"',           _blue,   'ŋgi',     'arbre',      'tree'),
  _Letter('j',  _cons,  '[dʒ]', 'comme "dj"',                    'like "j" in "jam"',            _green,  'jàm',     'guerre',     'war'),
  _Letter('k',  _cons,  '[k]',  'comme "k" français',            'like "k" in "key"',            _green,  'nkwǐ',    'singe',      'monkey'),
  _Letter('l',  _cons,  '[l]',  'comme "l" français',            'like "l" in "love"',           _green,  "leꞌe",    'jour',       'day'),
  _Letter('m',  _cons,  '[m]',  'comme "m" français',            'like "m" in "mother"',         _green,  'mɛn',     'enfant',     'child'),
  _Letter('n',  _cons,  '[n]',  'comme "n" français',            'like "n" in "no"',             _green,  'ntsə',    'eau',        'water'),
  _Letter('ŋ',  _cons,  '[ŋ]',  'comme "ng" dans "ring"',        'like "ng" in "ring"',          _purple, 'ŋgi',     'arbre',      'tree'),
  _Letter('ny', _cons,  '[ɲ]',  'comme "gn" dans "agneau"',      'like "ny" in "canyon"',        _purple, 'nyàm',    'soleil',     'sun'),
  _Letter('o',  _vowel, '[o]',  'comme "o" dans "eau"',          'like "o" in "go"',             _blue,   'o zi ὰ?', 'bonjour',    'hello'),
  _Letter('ɔ',  _vowel, '[ɔ]',  'comme "o" ouvert dans "or"',    'like "o" in "or"',             _blue,   'bɔ',      'nous',       'we'),
  _Letter('s',  _cons,  '[s]',  'comme "s" français',            'like "s" in "sun"',            _green,  'saŋə',    'vache',      'cow'),
  _Letter('sh', _cons,  '[ʃ]',  'comme "ch" français',           'like "sh" in "show"',          _purple, 'nshùm',   'garçon',     'boy'),
  _Letter('t',  _cons,  '[t]',  'comme "t" français',            'like "t" in "top"',            _green,  'Tα̂',     'père',       'father'),
  _Letter('ts', _cons,  '[ts]', 'comme "ts" dans "tsé-tsé"',     'like "ts" in "bits"',          _purple, 'tswəꞌ',   'nuit',       'night'),
  _Letter('u',  _vowel, '[u]',  'comme "ou" dans "lune"',        'like "oo" in "moon"',          _blue,   'ntu',     'tête',       'head'),
  _Letter('ɨ',  _vowel, '[ɨ]',  'voyelle centrale non-arrondie', 'central unrounded vowel',      _blue,   'bʉn',     'lait',       'milk'),
  _Letter('v',  _cons,  '[v]',  'comme "v" français',            'like "v" in "very"',           _green,  'vwɔ',     'vous',       'you (pl.)'),
  _Letter('w',  _cons,  '[w]',  'comme "ou" dans "oui"',         'like "w" in "water"',          _green,  'wud',     'nuit',       'night'),
  _Letter('y',  _cons,  '[j]',  'comme "y" dans "yeux"',         'like "y" in "yes"',            _green,  'nyàm',    'soleil',     'sun'),
  _Letter('z',  _cons,  '[z]',  'comme "z" français',            'like "z" in "zero"',           _green,  'zα',      'moi',        'me'),
];

Color _parseHex(String hex) {
  return Color(int.parse(hex.replaceAll('#', ''), radix: 16) | 0xFF000000);
}

// ── Écran principal ──────────────────────────────────────────────────────────

class AlphabetScreen extends StatefulWidget {
  // Vrai quand cet écran est ouvert depuis le parcours de leçons ("Les
  // Bases" → l0) plutôt que depuis l'accès rapide : affiche un bouton
  // "Continuer" qui marque la leçon comme terminée.
  final bool fromLessonPath;
  const AlphabetScreen({super.key, this.fromLessonPath = false});
  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String? _selected;
  bool _isFr = true;
  bool _completing = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); _tab.addListener(() => setState(() { _selected = null; })); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _completeAndReturn() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      setState(() => _completing = true);
      await UserService.completeLesson(uid, 'l0');
    }
    if (mounted) Navigator.of(context).pop();
  }

  List<_Letter> get _filtered {
    switch (_tab.index) {
      case 1: return _letters.where((l) => l.type == _LetterType.vowel).toList();
      case 2: return _letters.where((l) => l.type == _LetterType.consonant).toList();
      default: return _letters;
    }
  }

  _Letter? get _selectedLetter => _selected == null ? null : _letters.firstWhere((l) => l.letter == _selected, orElse: () => _letters.first);

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFD97706);
    final vowelCount    = _letters.where((l) => l.type == _LetterType.vowel).length;
    final consonantCount = _letters.where((l) => l.type == _LetterType.consonant).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(116),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$vowelCount voyelles · $consonantCount consonnes',
                        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    Text('🔤 ${_isFr ? 'Alphabet' : 'Alphabet'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
                    tooltip: 'Tableau de référence',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('assets/images/alphabet-medumba.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                  Tab(text: _isFr ? 'TOUTES' : 'ALL'),
                  Tab(text: _isFr ? 'VOYELLES' : 'VOWELS'),
                  Tab(text: _isFr ? 'CONSONNES' : 'CONSONANTS'),
                ],
              ),
            ]),
          ),
        ),
      ),
      body: Column(children: [
        // Légende des couleurs
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(children: [
            _Legend(color: const Color(0xFF0056D2), label: _isFr ? 'Voyelles'    : 'Vowels'),
            const SizedBox(width: 8),
            _Legend(color: const Color(0xFF16A34A), label: _isFr ? 'Consonnes'   : 'Consonants'),
            const SizedBox(width: 8),
            _Legend(color: const Color(0xFF7C3AED), label: _isFr ? 'Spéciales'   : 'Special'),
          ]),
        ),
        const SizedBox(height: 8),

        // Panneau de détail (si une lettre est sélectionnée)
        if (_selectedLetter != null) _DetailPanel(letter: _selectedLetter!, isFr: _isFr, onClose: () => setState(() => _selected = null)),

        // Grille de lettres
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [0, 1, 2].map((i) => _buildGrid(i)).toList(),
          ),
        ),

        if (widget.fromLessonPath)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completing ? null : _completeAndReturn,
                  style: ElevatedButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(_isFr ? 'Continuer' : 'Continue',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildGrid(int tabIdx) {
    final list = tabIdx == 0
      ? _letters
      : tabIdx == 1
        ? _letters.where((l) => l.type == _LetterType.vowel).toList()
        : _letters.where((l) => l.type == _LetterType.consonant).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _LetterCard(
        letter: list[i],
        isFr: _isFr,
        isActive: _selected == list[i].letter,
        onTap: () => setState(() => _selected = _selected == list[i].letter ? null : list[i].letter),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kMuted)),
  ]);
}

class _LetterCard extends StatelessWidget {
  final _Letter letter;
  final bool isFr, isActive;
  final VoidCallback onTap;
  const _LetterCard({required this.letter, required this.isFr, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(letter.color);
    final isVowel = letter.type == _LetterType.vowel;
    final bgColor = isActive ? accent : (isVowel ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4));
    final borderColor = isActive ? accent : (isVowel ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0));
    final textColor = isActive ? Colors.white : accent;
    final subColor = isActive ? Colors.white70 : kMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
            ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(letter.letter,
              style: TextStyle(fontSize: letter.isSpecial ? 20 : 26, fontWeight: FontWeight.w900, color: textColor, height: 1.1)),
          const SizedBox(height: 3),
          Text(isFr ? (letter.type == _LetterType.vowel ? 'Voyelle' : 'Consonne')
                    : (letter.type == _LetterType.vowel ? 'Vowel'   : 'Consonant'),
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: subColor, letterSpacing: 0.3)),
          const SizedBox(height: 1),
          Text(letter.ipa, style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: subColor, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final _Letter letter;
  final bool isFr;
  final VoidCallback onClose;
  const _DetailPanel({required this.letter, required this.isFr, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(letter.color);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Grand glyphe
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(letter.letter,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: accent))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(letter.ipa, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
            const SizedBox(height: 3),
            Text(isFr ? letter.phoneFr : letter.phoneEn,
                style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
          ])),
          IconButton(icon: const Icon(Icons.close, color: kMuted, size: 20), onPressed: onClose),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isFr ? 'Exemple' : 'Example',
                  style: const TextStyle(fontSize: 10, color: kMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(letter.example, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
              Text(isFr ? letter.exMeanFr : letter.exMeanEn,
                  style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
            ])),
            Icon(Icons.volume_up_rounded, color: accent.withValues(alpha: 0.5), size: 24),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _Badge(label: isFr ? (letter.type == _LetterType.vowel ? 'Voyelle' : 'Consonne')
                              : (letter.type == _LetterType.vowel ? 'Vowel'   : 'Consonant'),
               color: accent),
          if (letter.isSpecial) ...[
            const SizedBox(width: 6),
            _Badge(label: isFr ? 'Digramme' : 'Digraph', color: const Color(0xFF7C3AED)),
          ],
        ]),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
  );
}
