import 'package:flutter/material.dart';

const _levels = [
  ['01', 'Les Bases', 'Foundations', 'Alphabet, premiers mots, salutations', 'Alphabet, first words, greetings'],
  ['02', 'Personnes & Monde', 'People & World', 'Famille, corps, couleurs, chiffres', 'Family, body, colors, numbers'],
  ['03', 'Vie Quotidienne', 'Daily Life', 'Nourriture, maison, conversation courante', 'Food, home, everyday conversation'],
  ['04', 'Société & Santé', 'Society & Health', 'Santé, communauté, vie sociale', 'Health, community, social life'],
  ['05', 'Culture & Langue', 'Culture & Language', 'Traditions, calendrier, grammaire avancée', 'Traditions, calendar, deeper grammar'],
];

class CepomScreen extends StatefulWidget {
  const CepomScreen({super.key});
  @override
  State<CepomScreen> createState() => _CepomScreenState();
}

class _CepomScreenState extends State<CepomScreen> {
  bool _isFr = true;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0056D2);
    const gold = Color(0xFFB45309);
    const ink = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);
    const sand = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: Container(
          color: blue,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isFr ? 'CERTIFICATION' : 'CERTIFICATION',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  Text('🎓 CEPOM', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                ])),
                TextButton(
                  onPressed: () => setState(() => _isFr = !_isFr),
                  child: Text(_isFr ? 'EN' : 'FR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Certificate-style card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.3), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              const Text('🎓', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(_isFr ? 'PARTENARIAT OFFICIEL' : 'OFFICIAL PARTNERSHIP',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: gold, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              const Text('Medumba.AI × CEPOM',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink)),
              const SizedBox(height: 10),
              Text(
                _isFr
                    ? "Le CEPOM certifie les enseignants qui animent les classes en ligne et les cours particuliers de Medumba.AI, et supervise la structure pédagogique du parcours d'apprentissage."
                    : "CEPOM certifies the teachers who lead Medumba.AI's live classes and private lessons, and oversees the pedagogical structure of the learning path.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, color: muted, height: 1.6),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Curriculum structure
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sand, width: 1.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_isFr ? 'Une structure pédagogique reconnue' : 'A recognized learning structure',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: ink)),
              const SizedBox(height: 8),
              Text(
                _isFr
                    ? "L'application n'est pas un contenu isolé : chaque leçon s'inscrit dans un parcours à plusieurs niveaux, le même que celui suivi en classe avec un enseignant CEPOM."
                    : "The app isn't standalone content: every lesson fits into a multi-level path, the same one followed in class with a CEPOM teacher.",
                style: const TextStyle(fontSize: 13, color: muted, height: 1.6),
              ),
              const SizedBox(height: 14),
              ..._levels.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 30, height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(9)),
                        child: Text(l[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_isFr ? l[1] : l[2], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: ink)),
                        Text(_isFr ? l[3] : l[4], style: const TextStyle(fontSize: 12, color: muted)),
                      ])),
                    ]),
                  )),
            ]),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sand, width: 1.5),
            ),
            child: Text(
              _isFr
                  ? 'Une question sur la certification ou les classes CEPOM ? Écrivez-nous depuis la page Contact.'
                  : 'A question about CEPOM certification or classes? Reach out from the Contact page.',
              style: const TextStyle(fontSize: 13, color: muted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
