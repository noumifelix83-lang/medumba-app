import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class _Video {
  final String thumb, titleFr, titleEn, descFr, descEn;
  final String? youtube;
  const _Video({
    required this.thumb,
    required this.titleFr,
    required this.titleEn,
    required this.descFr,
    required this.descEn,
    this.youtube,
  });
}

class _Category {
  final String icon, labelFr, labelEn, descFr, descEn;
  final Color color;
  final List<_Video> videos;
  const _Category({
    required this.icon,
    required this.labelFr,
    required this.labelEn,
    required this.descFr,
    required this.descEn,
    required this.color,
    required this.videos,
  });
}

const _kCategories = <_Category>[
  _Category(
    icon: '🎬', labelFr: 'Introduction', labelEn: 'Introduction',
    descFr: 'Commencez ici — bases du Medumba', descEn: 'Start here — Medumba basics',
    color: Color(0xFF7C3AED),
    videos: [
      _Video(thumb: '👋', titleFr: "Salutation (Cà'tə̀)",    titleEn: "Greeting (Cà'tə̀)",      descFr: 'Comment saluer',           descEn: 'How to greet'),
      _Video(thumb: '📅', titleFr: '7 jours de la semaine',  titleEn: '7 days of the week',     descFr: 'Les 7 jours en Medumba',   descEn: '7 days in Medumba'),
      _Video(thumb: '🏺', titleFr: 'Bǎgwud',                 titleEn: 'Bǎgwud',                 descFr: 'Vocabulaire culturel',     descEn: 'Cultural vocabulary'),
      _Video(thumb: '🌅', titleFr: 'Le matin',               titleEn: 'The morning',            descFr: 'Expressions du matin',     descEn: 'Morning expressions'),
      _Video(thumb: '🗓️', titleFr: '8 jours (calendrier)',   titleEn: '8-day calendar',         descFr: 'Calendrier Medumba',       descEn: 'Medumba calendar'),
      _Video(thumb: '📆', titleFr: "Mois de l'année",         titleEn: 'Months of the year',     descFr: 'Les 12 mois en Medumba',   descEn: '12 months in Medumba'),
      _Video(thumb: '🏠', titleFr: 'La maison (Tǔnndα)',     titleEn: 'The house (Tǔnndα)',     descFr: 'Vocabulaire de la maison', descEn: 'Home vocabulary'),
      _Video(thumb: '🔢', titleFr: 'Les mots (Tʉntə̀)',      titleEn: 'Words (Tʉntə̀)',         descFr: 'Mots et chiffres de base', descEn: 'Basic words & numbers'),
    ],
  ),
  _Category(
    icon: '📗', labelFr: 'Niveau 1', labelEn: 'Level 1',
    descFr: 'Conversations du quotidien', descEn: 'Everyday conversations',
    color: Color(0xFF16A34A),
    videos: [
      _Video(thumb: '🤝', titleFr: 'Salutations 1',           titleEn: 'Greetings 1',            descFr: 'Formules de salutation',   descEn: 'Greeting formulas'),
      _Video(thumb: '😊', titleFr: 'Salutations 2',           titleEn: 'Greetings 2',            descFr: 'Salutations approfondies', descEn: 'Extended greetings'),
      _Video(thumb: '🪪', titleFr: "Mon nom (Mfǎ' nὰ)",       titleEn: "My name (Mfǎ' nὰ)",     descFr: 'Se présenter',             descEn: 'Introducing yourself'),
      _Video(thumb: '🛒', titleFr: 'Au marché — partie 1',    titleEn: 'At the market — part 1', descFr: 'Dialogue au marché',       descEn: 'Market dialogue'),
      _Video(thumb: '💰', titleFr: 'Au marché — partie 2',    titleEn: 'At the market — part 2', descFr: 'Négocier et acheter',      descEn: 'Haggling & buying'),
      _Video(thumb: '❓', titleFr: 'Demander le jour',         titleEn: 'Asking the day',         descFr: 'Demander la date',         descEn: 'Asking for the date'),
      _Video(thumb: '🙏', titleFr: 'Demander quelque chose',  titleEn: 'Asking for something',   descFr: 'Formuler une demande',     descEn: 'Making a request'),
      _Video(thumb: '🍽️', titleFr: 'Manger un repas',         titleEn: 'Eating a meal',          descFr: 'Vocabulaire des repas',    descEn: 'Meal vocabulary'),
      _Video(thumb: '😴', titleFr: 'Dormir (tswǐ wud)',       titleEn: 'Sleeping (tswǐ wud)',    descFr: 'Expressions du soir',      descEn: 'Evening expressions'),
    ],
  ),
  _Category(
    icon: '📘', labelFr: 'Niveau 2', labelEn: 'Level 2',
    descFr: 'Sujets avancés', descEn: 'Advanced topics',
    color: Color(0xFF0891B2),
    videos: [
      _Video(thumb: '🎵', titleFr: 'Chanson Medumba (Caŋ)',  titleEn: 'Medumba song (Caŋ)',     descFr: 'Apprendre par la chanson', descEn: 'Learn through song'),
      _Video(thumb: '🌙', titleFr: 'Bonne nuit, enfant',     titleEn: 'Goodnight, child',        descFr: 'Expressions pour enfants', descEn: 'For children'),
    ],
  ),
  _Category(
    icon: '🎨', labelFr: 'Dessins', labelEn: 'Drawings',
    descFr: 'Leçons animées visuelles', descEn: 'Animated visual lessons',
    color: Color(0xFFE11D48),
    videos: [
      _Video(thumb: '✏️', titleFr: 'Dessin 01',              titleEn: 'Drawing 01',             descFr: 'Leçon animée n°1',         descEn: 'Lesson #1'),
      _Video(thumb: '🖍️', titleFr: 'Dessin 02',              titleEn: 'Drawing 02',             descFr: 'Leçon animée n°2',         descEn: 'Lesson #2'),
      _Video(thumb: '🎨', titleFr: 'Dessin 03',              titleEn: 'Drawing 03',             descFr: 'Leçon animée n°3',         descEn: 'Lesson #3'),
      _Video(thumb: '🖌️', titleFr: 'Dessin 04',              titleEn: 'Drawing 04',             descFr: 'Leçon animée n°4',         descEn: 'Lesson #4'),
      _Video(thumb: '✏️', titleFr: 'Dessin 05',              titleEn: 'Drawing 05',             descFr: 'Leçon animée n°5',         descEn: 'Lesson #5'),
      _Video(thumb: '⏰', titleFr: 'Lecture du temps',        titleEn: 'Telling Time',           descFr: "Lire et dire l'heure",     descEn: 'Reading & telling time',  youtube: 'avB2s12HFlY'),
      _Video(thumb: '🦁', titleFr: 'Animaux de la savane',   titleEn: 'Savanna Animals',        descFr: 'Faune de la savane',       descEn: 'African savanna wildlife', youtube: 'O5eIMhubaQM'),
      _Video(thumb: '🌈', titleFr: 'Les couleurs',            titleEn: 'Colors',                 descFr: 'Nommer les couleurs',      descEn: 'Naming colors',            youtube: 'wcKfYEYkGqA'),
      _Video(thumb: '🔷', titleFr: 'Formes géométriques',    titleEn: 'Geometric Shapes',       descFr: 'Les formes en Medumba',    descEn: 'Shapes in Medumba',        youtube: 'K6bxqnMXrhg'),
      _Video(thumb: '🐾', titleFr: 'Animaux domestiques',    titleEn: 'Domestic Animals',       descFr: 'Les animaux de la maison', descEn: 'Animals at home',          youtube: 'SZLGo44APac'),
      _Video(thumb: '🤝', titleFr: 'Salutation (Dessin)',     titleEn: 'Greetings (Drawing)',    descFr: 'Saluer en Medumba',        descEn: 'Greetings in Medumba',     youtube: '2R8aIlUErfo'),
      _Video(thumb: '🎵', titleFr: 'Chanson Mà we',           titleEn: 'Song Mà we',             descFr: 'Chanson traditionnelle',   descEn: 'Traditional song',         youtube: 'y7fWROWtMkY'),
      _Video(thumb: '🐢', titleFr: 'Conte : la tortue et la panthère', titleEn: 'Tale: The Tortoise & Panther', descFr: 'Conte traditionnel Medumba', descEn: 'Traditional Medumba tale', youtube: 'zMaHWxA1MPc'),
    ],
  ),
  _Category(
    icon: '📖', labelFr: 'Zenù', labelEn: 'Zenù',
    descFr: 'Patrimoine & tradition orale Medumba', descEn: 'Medumba heritage & oral tradition',
    color: Color(0xFF7C3AED),
    videos: [
      _Video(thumb: '🎶', titleFr: 'Zenù — Musique',                        titleEn: 'Zenù — Music',                  descFr: 'Chanson Zenù',               descEn: 'Zenù song',               youtube: 'vQMADuRX7Hs'),
      _Video(thumb: '📜', titleFr: 'Histoire : Kebwog nzwimfèn',            titleEn: 'Story: Kebwog nzwimfèn',        descFr: 'Conte traditionnel Medumba', descEn: 'Traditional Medumba tale', youtube: 'IdOO9KJk2Io'),
      _Video(thumb: '⚔️', titleFr: 'La femme guerrière de Bangoulap',       titleEn: 'The Warrior Woman of Bangoulap', descFr: 'Histoire héroïque Bangangté', descEn: 'Bangangté heroic history', youtube: '_W7BXXZJTgk'),
      _Video(thumb: '🗓️', titleFr: 'Les 8 jours de la semaine Medumba',    titleEn: 'The 8-Day Medumba Week',        descFr: 'Calendrier traditionnel',    descEn: 'Traditional calendar',    youtube: 'sEvxMvx6sXs'),
    ],
  ),
];

Future<void> _openYoutube(BuildContext context, String id) async {
  final appUri = Uri.parse('vnd.youtube:$id');
  final webUri = Uri.parse('https://www.youtube.com/watch?v=$id');
  try {
    bool launched = false;
    if (await canLaunchUrl(appUri)) {
      launched = await launchUrl(appUri);
    }
    if (!launched) {
      launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible d\'ouvrir la vidéo. Vérifiez votre connexion.'),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isFr = true;
  int _catIdx = 3; // start on Dessins — most videos available

  @override
  Widget build(BuildContext context) {
    final cat = _kCategories[_catIdx];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isFr ? 'Vidéos' : 'Videos',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kInk)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isFr = !_isFr),
            child: Text(_isFr ? 'EN' : 'FR',
                style: const TextStyle(color: kBlue, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Column(children: [
        // Category selector
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _kCategories[i];
              final selected = i == _catIdx;
              return GestureDetector(
                onTap: () => setState(() => _catIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? c.color : Colors.white,
                    border: Border.all(color: selected ? c.color : kBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(c.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(_isFr ? c.labelFr : c.labelEn,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : kInk)),
                  ]),
                ),
              );
            },
          ),
        ),
        // Category description
        Container(
          width: double.infinity,
          color: cat.color.withValues(alpha: 0.08),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(_isFr ? cat.descFr : cat.descEn,
              style: TextStyle(fontSize: 12, color: cat.color, fontWeight: FontWeight.w700)),
        ),
        // Video list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: cat.videos.length,
            itemBuilder: (_, i) {
              final v = cat.videos[i];
              final hasYoutube = v.youtube != null;
              return GestureDetector(
                onTap: hasYoutube ? () => _openYoutube(context, v.youtube!) : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: hasYoutube ? cat.color.withValues(alpha: 0.3) : kBorder,
                        width: hasYoutube ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    // Thumbnail
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(13), bottomLeft: Radius.circular(13)),
                      ),
                      child: Center(
                        child: Text(v.thumb, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    // Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_isFr ? v.titleFr : v.titleEn,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: hasYoutube ? kInk : kMuted)),
                          const SizedBox(height: 3),
                          Text(_isFr ? v.descFr : v.descEn,
                              style: const TextStyle(
                                  fontSize: 11, color: kMuted, fontWeight: FontWeight.w500)),
                          if (!hasYoutube) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text('Bientôt disponible',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: kMuted)),
                            ),
                          ],
                        ]),
                      ),
                    ),
                    // Play icon
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        hasYoutube ? Icons.play_circle_rounded : Icons.lock_rounded,
                        color: hasYoutube ? cat.color : kBorder,
                        size: 28,
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
