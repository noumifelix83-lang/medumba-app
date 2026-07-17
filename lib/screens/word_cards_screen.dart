import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/medumba_audio_service.dart';
import '../services/syllable_audio.dart';

const _allCards = [
  // Salutations
  _Card(medumba: 'O zi ὰ?', fr: 'Bonjour !', en: 'Hello!', cat: 'Salutations'),
  _Card(medumba: 'Mə lὰbtə̌.', fr: 'Merci.', en: 'Thank you.', cat: 'Salutations'),
  _Card(medumba: 'Ɔ̂ghɔ.', fr: 'Au revoir.', en: 'Goodbye.', cat: 'Salutations'),
  _Card(medumba: 'Nəco\'o.', fr: 'S\'il te plaît.', en: 'Please.', cat: 'Salutations'),
  _Card(medumba: 'A fi tsə.', fr: 'Ça va bien.', en: 'All is well.', cat: 'Salutations'),
  // Famille
  _Card(medumba: 'Mα.', fr: 'La mère', en: 'Mother', cat: 'Famille'),
  _Card(medumba: 'Tα.', fr: 'Le père', en: 'Father', cat: 'Famille'),
  _Card(medumba: 'Mɛn.', fr: 'L\'enfant', en: 'Child', cat: 'Famille'),
  _Card(medumba: 'Mfɛ̂l ὰm.', fr: 'Mon frère / Ma sœur', en: 'Sibling', cat: 'Famille'),
  // Nourriture
  _Card(medumba: 'Ntsə.', fr: 'L\'eau', en: 'Water', cat: 'Nourriture'),
  _Card(medumba: 'Mbὰb.', fr: 'La viande', en: 'Meat', cat: 'Nourriture'),
  _Card(medumba: 'Bànαnὰ.', fr: 'La banane', en: 'Banana', cat: 'Nourriture'),
  _Card(medumba: 'Kə̀lɔ̀.', fr: 'Le plantain', en: 'Plantain', cat: 'Nourriture'),
  // Nombres
  _Card(medumba: 'Ncʉ\'', fr: 'Un (1)', en: 'One', cat: 'Nombres'),
  _Card(medumba: 'Bαhα', fr: 'Deux (2)', en: 'Two', cat: 'Nombres'),
  _Card(medumba: 'Tad', fr: 'Trois (3)', en: 'Three', cat: 'Nombres'),
  _Card(medumba: 'Gham', fr: 'Dix (10)', en: 'Ten', cat: 'Nombres'),
  // Corps humain
  _Card(medumba: 'Tu.', fr: 'La tête', en: 'Head', cat: 'Corps humain'),
  _Card(medumba: 'Miαg.', fr: 'Les yeux', en: 'Eyes', cat: 'Corps humain'),
  _Card(medumba: 'Bu.', fr: 'La main', en: 'Hand', cat: 'Corps humain'),
  _Card(medumba: 'Kù.', fr: 'Le pied', en: 'Foot', cat: 'Corps humain'),
  // Animaux
  _Card(medumba: 'Mbʉ.', fr: 'Le chien', en: 'Dog', cat: 'Animaux'),
  _Card(medumba: 'Bùsi.', fr: 'Le chat', en: 'Cat', cat: 'Animaux'),
  _Card(medumba: 'Nyu.', fr: 'Le serpent', en: 'Snake', cat: 'Animaux'),
];

class _Card {
  final String medumba, fr, en, cat;
  const _Card({required this.medumba, required this.fr, required this.en, required this.cat});
}

class WordCardsScreen extends StatefulWidget {
  const WordCardsScreen({super.key});
  @override
  State<WordCardsScreen> createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends State<WordCardsScreen> {
  int _index = 0;
  bool _flipped = false;
  bool _isFr = true;
  bool _speaking = false;
  bool _loading = true;
  List<_Card> _cards = [];

  @override
  void initState() {
    super.initState();
    // Ne garde que les mots avec un enregistrement réel unique — pas de
    // TTS ni de composition de syllabes présentée comme une vraie voix.
    SyllableAudio.instance.ensureLoaded().then((_) {
      if (!mounted) return;
      setState(() {
        _cards = _allCards.where((c) => SyllableAudio.instance.hasRealVoice(c.medumba)).toList();
        _loading = false;
      });
    });
  }

  void _stopAudio() {
    MedumbaAudioService.instance.stop();
    _speaking = false;
  }

  void _next()  => setState(() { _stopAudio(); _index = (_index + 1) % _cards.length; _flipped = false; });
  void _prev()  => setState(() { _stopAudio(); _index = (_index - 1 + _cards.length) % _cards.length; _flipped = false; });
  void _flip()  => setState(() { _stopAudio(); _flipped = !_flipped; });

  @override
  void dispose() {
    MedumbaAudioService.instance.stop();
    super.dispose();
  }

  Future<void> _playCurrent() async {
    setState(() => _speaking = true);
    await MedumbaAudioService.instance.playWord(_cards[_index].medumba);
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(_isFr ? 'Fiches de vocabulaire' : 'Word Cards',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kInk)),
        ),
        body: Center(child: Text(_isFr ? 'Contenu à venir…' : 'Content coming soon…',
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600))),
      );
    }
    final card = _cards[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isFr ? 'Fiches de vocabulaire' : 'Word Cards',
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
        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Text('${_index + 1} / ${_cards.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kMuted)),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _cards.length,
                  minHeight: 6,
                  backgroundColor: kBorder,
                  valueColor: const AlwaysStoppedAnimation(kBlue),
                ),
              ),
            ),
          ]),
        ),
        // Catégorie
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: kBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
          child: Text(card.cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kBlue)),
        ),
        const SizedBox(height: 16),

        // Carte (tapez pour retourner)
        Expanded(
          child: GestureDetector(
            onTap: _flip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: _flipped ? kBlue : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _flipped ? kBlue : kBorder, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_flipped ? (card.medumba) : (_isFr ? card.fr : card.en),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w900,
                        color: _flipped ? Colors.white : kInk,
                      )),
                  const SizedBox(height: 12),
                  Text(
                    _flipped ? (_isFr ? card.fr : card.en) : 'Medumba',
                    style: TextStyle(
                      fontSize: _flipped ? 18 : 13,
                      fontWeight: FontWeight.w600,
                      color: _flipped ? Colors.white.withValues(alpha: 0.8) : kMuted,
                      fontStyle: _flipped ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_flipped)
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        if (_speaking) { _stopAudio(); setState(() {}); return; }
                        _playCurrent();
                      },
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: _speaking ? 0.3 : 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Icon(_speaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                            color: Colors.white, size: 22),
                      ),
                    )
                  else
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.touch_app_rounded, color: kMuted, size: 16),
                      const SizedBox(width: 4),
                      Text(_isFr ? 'Tapez pour révéler' : 'Tap to reveal',
                          style: const TextStyle(fontSize: 11, color: kMuted)),
                    ]),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _prev,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: kInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_isFr ? 'Suivant' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
