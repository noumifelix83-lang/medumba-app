import 'medumba_expressions.dart';
import 'lesson_keywords.dart';

// Keep LessonCard as a typedef alias so vocab_screen.dart still compiles
class LessonCard {
  final String medumba, fr, en;
  final List<String> opts;
  const LessonCard(this.medumba, this.fr, this.en, this.opts);
}

class LessonTheme {
  final String id, emoji, titleFr, titleEn;
  final List<LessonCard> cards; // kept for vocab_screen compatibility
  const LessonTheme(this.id, this.emoji, this.titleFr, this.titleEn, [this.cards = const []]);
}

const kLessonThemes = <LessonTheme>[
  LessonTheme('l1',  '👋', 'Salutations',      'Greetings'),
  LessonTheme('l2',  '🧍', 'Le Corps',          'The Body'),
  LessonTheme('l3',  '🍽️', 'Nourriture',        'Food & Drink'),
  LessonTheme('l4',  '👗', 'Vêtements',         'Clothes & Colors'),
  LessonTheme('l5',  '💰', 'Argent & Chiffres', 'Money & Numbers'),
  LessonTheme('l6',  '🐄', 'Animaux',           'Animals'),
  LessonTheme('l7',  '👨‍👩‍👧', 'La Famille',         'Family'),
  LessonTheme('l8',  '🌳', 'Nature',            'Nature'),
  LessonTheme('l9',  '📅', 'Temps & Date',      'Time & Date'),
  LessonTheme('l10', '🤝', 'Se Présenter',      'Introductions'),
  LessonTheme('l11', '🏠', 'La Maison',         'The House'),
  LessonTheme('l12', '🏥', 'Santé',             'Health'),
  LessonTheme('l13', '📚', 'École',             'School'),
  LessonTheme('l14', '💼', 'Travail',           'Work'),
  LessonTheme('l15', '💬', 'Conversations',     'Conversations'),
  LessonTheme('l16', '🏃', "Verbes d'action",  'Action Verbs'),
  LessonTheme('l17', '🥁', 'Culture & Rites',  'Culture & Rites'),
];

/// Returns expressions filtered by lesson keywords + difficulty cap.
/// Mirrors expressionsByLesson.js from the web app.
List<MExpr> getExpressionsForLesson(String lessonId) {
  final keywords = kLessonKeywords[lessonId];
  if (keywords == null) return kAllExpressions;

  final cap = kDifficultyWordCap[lessonId]; // null = no cap

  final filtered = kAllExpressions.where((e) {
    final frLower = e.fr.toLowerCase();
    final matches = keywords.any((kw) => frLower.contains(kw.toLowerCase()));
    if (!matches) return false;
    if (cap != null && e.fr.trim().split(RegExp(r'\s+')).length > cap) return false;
    return true;
  }).toList();

  return filtered.length >= 5 ? filtered : kAllExpressions;
}
