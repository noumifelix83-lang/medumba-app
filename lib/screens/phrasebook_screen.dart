import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../services/medumba_audio_service.dart';

const _categories = [
  _Cat(emoji: '👋', titleFr: 'Salutations',  titleEn: 'Greetings',   color: Color(0xFF4F46E5)),
  _Cat(emoji: '🏠', titleFr: 'Famille',       titleEn: 'Family',      color: Color(0xFF7C3AED)),
  _Cat(emoji: '🍜', titleFr: 'Nourriture',    titleEn: 'Food',        color: Color(0xFFEA580C)),
  _Cat(emoji: '🌿', titleFr: 'Nature',        titleEn: 'Nature',      color: Color(0xFF16A34A)),
  _Cat(emoji: '🔢', titleFr: 'Nombres',       titleEn: 'Numbers',     color: Color(0xFF0891B2)),
  _Cat(emoji: '🐾', titleFr: 'Animaux',       titleEn: 'Animals',     color: Color(0xFF059669)),
  _Cat(emoji: '🎨', titleFr: 'Couleurs',      titleEn: 'Colors',      color: Color(0xFFCA8A04)),
  _Cat(emoji: '🖐️', titleFr: 'Corps humain',  titleEn: 'Body Parts',  color: Color(0xFF0D9488)),
];

// Phrases par catégorie — données authentiques
const _phrases = {
  'Salutations': [
    _Phrase(fr: 'Bonjour !', medumba: 'O zi ὰ?', phonetic: 'o zi à'),
    _Phrase(fr: 'Salut !', medumba: 'Ndà\'ndà\' lα!', phonetic: 'ndà\'ndà\' la'),
    _Phrase(fr: 'Comment ça va ?', medumba: 'Ndʉ̂kə? / Â ndʉ̂kə?', phonetic: 'ndʉ̂kə'),
    _Phrase(fr: 'Ça va bien.', medumba: 'A fi tsə.', phonetic: 'a fi tsə'),
    _Phrase(fr: 'Au revoir.', medumba: 'Ɔ̂ghɔ.', phonetic: 'ɔ̂ghɔ'),
    _Phrase(fr: 'Merci.', medumba: 'Mə lὰbtə̌.', phonetic: 'mə làbtə̌'),
  ],
  'Famille': [
    _Phrase(fr: 'La famille', medumba: 'Tǔnndα.', phonetic: 'tǔnndα'),
    _Phrase(fr: 'Le père', medumba: 'Tα. Bὰbα.', phonetic: 'ta. bàba'),
    _Phrase(fr: 'La mère', medumba: 'Mα. Mὰmα.', phonetic: 'ma. màma'),
    _Phrase(fr: 'Mon frère / Ma sœur', medumba: 'Mfɛ̂l ὰm.', phonetic: 'mfɛ̂l àm'),
    _Phrase(fr: 'L\'enfant', medumba: 'Mɛn.', phonetic: 'mɛn'),
    _Phrase(fr: 'Mes parents', medumba: 'Tα bôὰ mα cαm.', phonetic: 'ta bôà ma cam'),
  ],
  'Nourriture': [
    _Phrase(fr: 'J\'ai faim.', medumba: 'Nzìkû\' cwɛ̌d nja αm.', phonetic: 'nzìkû\' cwɛ̌d nja am'),
    _Phrase(fr: 'Bon appétit !', medumba: 'À cʉα̂ ncǔ bin.', phonetic: 'à cʉα̂ ncǔ bin'),
    _Phrase(fr: 'La banane', medumba: 'Bànαnὰ.', phonetic: 'bànana'),
    _Phrase(fr: 'La viande', medumba: 'Mbὰb.', phonetic: 'mbàb'),
    _Phrase(fr: 'Je veux manger.', medumba: 'Mə kɔ̌ nə̀ jʉ caŋ.', phonetic: 'mə kɔ̌ nə jʉ caŋ'),
    _Phrase(fr: 'Je suis rassasié.', medumba: 'Mə ywɛd.', phonetic: 'mə ywɛd'),
  ],
  'Nature': [
    _Phrase(fr: 'Il pleut.', medumba: 'Mbǎŋ cwɛ̌d ndo.', phonetic: 'mbǎŋ cwɛ̌d ndo'),
    _Phrase(fr: 'Il fait chaud.', medumba: 'Dʉ̌\' cwɛ̌d ndûmə.', phonetic: 'dʉ̌\' cwɛ̌d ndûmə'),
    _Phrase(fr: 'Il fait froid.', medumba: 'Mfʉαg cwɛ̌d nko.', phonetic: 'mfʉαg cwɛ̌d nko'),
    _Phrase(fr: 'Le soleil brille.', medumba: 'Nyǎm cwɛ̌d ntα.', phonetic: 'nyǎm cwɛ̌d ntα'),
    _Phrase(fr: 'Il vente.', medumba: 'Fə̀dmbǎŋ cwɛ̌d nshʉm.', phonetic: 'fə̀dmbǎŋ cwɛ̌d nshʉm'),
    _Phrase(fr: 'Il fait beau.', medumba: 'Ncʉ̌ njʉ bwɔ̌.', phonetic: 'ncʉ̌ njʉ bwɔ̌'),
  ],
  'Nombres': [
    _Phrase(fr: 'Zéro (0)', medumba: 'Bα̌nbαn', phonetic: 'bα̌nbαn'),
    _Phrase(fr: 'Un (1)', medumba: 'Ncʉ\'', phonetic: 'ncʉ\''),
    _Phrase(fr: 'Deux (2)', medumba: 'Bαhα', phonetic: 'bαhα'),
    _Phrase(fr: 'Trois (3)', medumba: 'Tad', phonetic: 'tad'),
    _Phrase(fr: 'Quatre (4)', medumba: 'Kuὰ', phonetic: 'kuὰ'),
    _Phrase(fr: 'Cinq (5)', medumba: 'Tα̂n', phonetic: 'tα̂n'),
  ],
  'Animaux': [
    _Phrase(fr: 'Le chien', medumba: 'Mbʉ.', phonetic: 'mbʉ'),
    _Phrase(fr: 'Le chat', medumba: 'Bùsi.', phonetic: 'bùsi'),
    _Phrase(fr: 'La souris', medumba: 'Cə̌dkù.', phonetic: 'cə̌dkù'),
    _Phrase(fr: 'Le serpent', medumba: 'Nyu.', phonetic: 'nyu'),
    _Phrase(fr: 'La chèvre', medumba: 'Mbwə.', phonetic: 'mbwə'),
    _Phrase(fr: 'La poule', medumba: 'Ngab.', phonetic: 'ngab'),
  ],
  'Corps humain': [
    _Phrase(fr: 'La tête', medumba: 'Tu.', phonetic: 'tu'),
    _Phrase(fr: 'Les yeux', medumba: 'Miαg.', phonetic: 'miαg'),
    _Phrase(fr: 'Les oreilles', medumba: 'Ntòŋ.', phonetic: 'ntòŋ'),
    _Phrase(fr: 'La main', medumba: 'Bu.', phonetic: 'bu'),
    _Phrase(fr: 'La bouche', medumba: 'Ncù.', phonetic: 'ncù'),
    _Phrase(fr: 'Le pied', medumba: 'Kù.', phonetic: 'kù'),
  ],
};

class _Cat {
  final String emoji, titleFr, titleEn;
  final Color color;
  const _Cat({required this.emoji, required this.titleFr, required this.titleEn, required this.color});
}

class _Phrase {
  final String fr, medumba, phonetic;
  const _Phrase({required this.fr, required this.medumba, required this.phonetic});
}

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});
  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  bool _isFr = true;
  _Cat? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isFr ? 'Phrasebook' : 'Phrasebook',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kInk)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: _selected == null ? _CatGrid(isFr: _isFr, onSelect: (c) => setState(() => _selected = c))
                              : _PhraseList(cat: _selected!, isFr: _isFr, onBack: () => setState(() => _selected = null)),
    );
  }
}

class _CatGrid extends StatelessWidget {
  final bool isFr;
  final void Function(_Cat) onSelect;
  const _CatGrid({required this.isFr, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Ressources de référence ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isFr ? 'Ressources de référence' : 'Reference resources',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.3)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _ResourceCard(
                  emoji: '🔤',
                  titleFr: 'Alphabet',
                  titleEn: 'Alphabet',
                  subtitleFr: '32 lettres Medumba',
                  subtitleEn: '32 Medumba letters',
                  color: const Color(0xFFD97706),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/alphabet'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ResourceCard(
                  emoji: '🔢',
                  titleFr: 'Compter',
                  titleEn: 'Counting',
                  subtitleFr: '0 à 1000 + Quiz + Audio',
                  subtitleEn: '0 to 1,000 + Quiz + Audio',
                  color: const Color(0xFF0891B2),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/counting'),
                )),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _ResourceCard(
                  emoji: '📅',
                  titleFr: 'Calendrier',
                  titleEn: 'Calendar',
                  subtitleFr: 'Semaine 8 jours Medumba',
                  subtitleEn: 'Medumba 8-day week',
                  color: const Color(0xFF16A34A),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/calendar'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ResourceCard(
                  emoji: '📖',
                  titleFr: 'Dictionnaire',
                  titleEn: 'Dictionary',
                  subtitleFr: 'Vocabulaire essentiel',
                  subtitleEn: 'Essential vocabulary',
                  color: const Color(0xFF7C3AED),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/dictionary'),
                )),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _ResourceCard(
                  emoji: '🎯',
                  titleFr: 'Vocabulaire',
                  titleEn: 'Vocabulary',
                  subtitleFr: '17 thèmes • Cartes & Quiz',
                  subtitleEn: '17 themes • Cards & Quiz',
                  color: const Color(0xFF1B4FD8),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/vocab'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ResourceCard(
                  emoji: '🔤',
                  titleFr: 'Syllabaire',
                  titleEn: 'Syllabary',
                  subtitleFr: '1 147 syllabes + IPA',
                  subtitleEn: '1,147 syllables + IPA',
                  color: const Color(0xFF7C3AED),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/pronunciation'),
                )),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _ResourceCard(
                  emoji: '🎥',
                  titleFr: 'Vidéos',
                  titleEn: 'Videos',
                  subtitleFr: '5 catégories • YouTube',
                  subtitleEn: '5 categories • YouTube',
                  color: const Color(0xFFE11D48),
                  isFr: isFr,
                  onTap: () => context.push('/lesson/videos'),
                )),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: 14),
              Text(isFr ? 'Phrases par thème' : 'Phrases by topic',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.3)),
              const SizedBox(height: 8),
            ]),
          ),
        ),
        // ── Grille catégories ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final c = _categories[i];
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.1),
              border: Border.all(color: c.color.withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(c.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(isFr ? c.titleFr : c.titleEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.color)),
            ]),
          ),
        );
              },
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String emoji, titleFr, titleEn, subtitleFr, subtitleEn;
  final Color color;
  final bool isFr;
  final VoidCallback onTap;
  const _ResourceCard({required this.emoji, required this.titleFr, required this.titleEn, required this.subtitleFr, required this.subtitleEn, required this.color, required this.isFr, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.06)]),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isFr ? titleFr : titleEn, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Text(isFr ? subtitleFr : subtitleEn, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kMuted)),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withValues(alpha: 0.6)),
      ]),
    ),
  );
}

class _PhraseList extends StatefulWidget {
  final _Cat cat;
  final bool isFr;
  final VoidCallback onBack;
  const _PhraseList({required this.cat, required this.isFr, required this.onBack});

  @override
  State<_PhraseList> createState() => _PhraseListState();
}

class _PhraseListState extends State<_PhraseList> {
  String? _speaking;

  @override
  void dispose() {
    MedumbaAudioService.instance.stop();
    super.dispose();
  }

  Future<void> _play(String medumba) async {
    setState(() => _speaking = medumba);
    await MedumbaAudioService.instance.playWord(medumba);
    if (mounted) setState(() => _speaking = null);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final isFr = widget.isFr;
    final phrases = _phrases[cat.titleFr] ?? [];
    return Column(children: [
      Container(
        color: cat.color,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: widget.onBack),
          const SizedBox(width: 4),
          Text(cat.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(isFr ? cat.titleFr : cat.titleEn,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
      ),
      Expanded(
        child: phrases.isEmpty
          ? Center(child: Text(isFr ? 'Contenu à venir…' : 'Content coming soon…',
                style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: phrases.length,
              itemBuilder: (_, i) {
                final p = phrases[i];
                final speaking = _speaking == p.medumba;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(isFr ? p.fr : p.medumba,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kInk)),
                      const SizedBox(height: 4),
                      Text(isFr ? p.medumba : p.fr,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cat.color)),
                      Text('[${p.phonetic}]',
                          style: const TextStyle(fontSize: 11, color: kMuted, fontStyle: FontStyle.italic)),
                    ])),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _play(p.medumba),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(speaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                            color: cat.color, size: 22),
                      ),
                    ),
                  ]),
                );
              },
            ),
      ),
    ]);
  }
}
