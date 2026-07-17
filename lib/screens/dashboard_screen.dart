import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';
import '../state/app_language.dart';
import '../theme/colors.dart';

// Lessons that must be completed before each chest/boss unlocks
const _kChestReqs = <String, List<String>>{
  'c1': ['l1', 'l2', 'l3'],
  'c2': ['l9', 'l10'],
  'c3': ['l11', 'l12', 'l13', 'l14'],
  'c4': ['l15', 'l16', 'l17'],
};
const _kBossReqs = <String, List<String>>{
  'b1': ['l6', 'l7', 'l8'],
  'b2': ['l11', 'l12', 'l13'],
  'b3': ['l15', 'l16'],
};

// lessonId → route
const _lessonRoutes = <String, String>{
  'l0': '/lesson/alphabet-intro',
  'l1': '/lesson/vocab/l1',
  'l2': '/lesson/vocab/l2',
  'l3': '/lesson/vocab/l3',
  'l4': '/lesson/vocab/l4',
  'l5': '/lesson/vocab/l5',
  'l6': '/lesson/vocab/l6',
  'l7': '/lesson/vocab/l7',
  'l8': '/lesson/vocab/l8',
  'l9': '/lesson/vocab/l9',
  'l10': '/lesson/vocab/l10',
  'l11': '/lesson/vocab/l11',
  'l12': '/lesson/vocab/l12',
  'l13': '/lesson/vocab/l13',
  'l14': '/lesson/vocab/l14',
  'l15': '/lesson/vocab/l15',
  'l16': '/lesson/vocab/l16',
  'l17': '/lesson/vocab/l17',
  'c1': '/lesson/chest/c1',
  'c2': '/lesson/chest/c2',
  'c3': '/lesson/chest/c3',
  'c4': '/lesson/chest/c4',
  'b1': '/lesson/boss/b1',
  'b2': '/lesson/boss/b2',
  'b3': '/lesson/boss/b3',
};

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _progress;
  List<String> _completedLessons = [];
  bool _loading = true;
  bool? _isFrOverride;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { setState(() => _loading = false); return; }

    // Load profile, progress and completed lessons in parallel
    final profile    = await UserService.getProfile(uid);
    final progress   = await UserService.getProgress(uid);
    final completed  = await UserService.getCompletedLessons(uid);

    // Create progress row if it doesn't exist yet
    if (progress == null) {
      await UserService.saveProgress(uid, {'xp': 0, 'gems': 0, 'hearts': 5, 'streak': 0});
    }

    final newStreak = await UserService.updateStreak(uid);

    if (mounted) {
      setState(() {
        _profile          = profile;
        _progress         = {...?progress, 'streak': newStreak};
        _completedLessons = completed;
        _loading          = false;
      });
    }
  }

  void _toggleLang() {
    final lang = (_profile?['native_lang'] as String?) ?? 'french';
    final currentIsFr = _isFrOverride ?? (lang == 'french');
    setState(() => _isFrOverride = !currentIsFr);
  }

  @override
  Widget build(BuildContext context) {
    final streak = (_progress?['streak'] as int?) ?? 0;
    final xp     = (_progress?['xp']     as int?) ?? 0;
    final gems   = (_progress?['gems']   as int?) ?? 0;
    final name   = ((_profile?['name'] as String?) ?? '').split(' ').first;
    final lang   = (_profile?['native_lang'] as String?) ?? 'french';
    final isFr   = _isFrOverride ?? (lang == 'french');
    AppLanguage.instance.isFr = isFr;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TopBar(streak: streak, xp: xp, gems: gems, isFr: isFr, onToggleLang: _toggleLang),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: kBlue)))
          else
            Expanded(
              child: RefreshIndicator(
                color: kBlue,
                onRefresh: _load,
                child: _LessonPath(
                  name: name,
                  isFr: isFr,
                  xp: xp,
                  completedLessons: _completedLessons,
                  onReturn: _load,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int streak, xp, gems;
  final bool isFr;
  final VoidCallback onToggleLang;
  const _TopBar({required this.streak, required this.xp, required this.gems, required this.isFr, required this.onToggleLang});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggleLang,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Text(isFr ? '🇫🇷' : '🇬🇧', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(isFr ? 'FR' : 'EN',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(Icons.swap_horiz_rounded, color: Colors.white54, size: 14),
                  ]),
                ),
              ),
              const Spacer(),
              _Stat(emoji: '🔥', value: '$streak', color: const Color(0xFFFF9500)),
              const SizedBox(width: 16),
              _Stat(emoji: '💎', value: '$gems',   color: const Color(0xFF00BCD4)),
              const SizedBox(width: 16),
              _Stat(emoji: '⚡', value: '$xp',     color: const Color(0xFFFFC107)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji, value;
  final Color color;
  const _Stat({required this.emoji, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
    ]);
  }
}

// ── Lesson path ───────────────────────────────────────────────────────────────

const _xpToNext = 500;

class _LessonPath extends StatelessWidget {
  final String name;
  final bool isFr;
  final int xp;
  final List<String> completedLessons;
  final VoidCallback? onReturn;
  const _LessonPath({required this.name, required this.isFr, required this.xp, required this.completedLessons, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _GreetingCard(name: name, isFr: isFr, xp: xp),
        _QuickAccessRow(isFr: isFr),
        ..._buildSections(),
      ],
    );
  }

  List<Widget> _buildSections() {
    // Structure exacte du web app (unitsMedumba)
    final sections = [
      _SectionData(
        titleFr: 'Les Bases', titleEn: 'Foundations',
        subFr: 'Apprenez les bases du Medumba', subEn: 'Learn the basics of Medumba',
        color: const Color(0xFF0056D2), emoji: '🔤',
        lessons: [
          const _Lesson(id: 'l0', titleFr: 'Alphabet',     titleEn: 'Alphabet'),
          const _Lesson(id: 'l1', titleFr: 'Salutations',  titleEn: 'Greetings'),
          const _Lesson(id: 'l2', titleFr: 'Corps humain', titleEn: 'Body Parts'),
          const _Lesson(id: 'l3', titleFr: 'Nourriture',   titleEn: 'Food'),
          const _Lesson(id: 'c1', titleFr: 'Coffre',       titleEn: 'Chest', baseType: _NodeType.chest),
          const _Lesson(id: 'l4', titleFr: 'Couleurs',     titleEn: 'Colors'),
          const _Lesson(id: 'l5', titleFr: 'Chiffres',     titleEn: 'Numbers'),
        ],
      ),
      _SectionData(
        titleFr: 'Personnes & Monde', titleEn: 'People & World',
        subFr: 'Animaux, famille et le monde qui vous entoure', subEn: 'Animals, family and the world around you',
        color: const Color(0xFF2563EB), emoji: '👥',
        lessons: [
          const _Lesson(id: 'l6', titleFr: 'Animaux',    titleEn: 'Animals'),
          const _Lesson(id: 'l7', titleFr: 'Famille',    titleEn: 'Family'),
          const _Lesson(id: 'l8', titleFr: 'Nature',     titleEn: 'Nature'),
          const _Lesson(id: 'b1', titleFr: 'Défi Boss',  titleEn: 'Boss Fight', baseType: _NodeType.boss),
        ],
      ),
      _SectionData(
        titleFr: 'Vie Quotidienne', titleEn: 'Daily Life',
        subFr: 'Expressions pour tous les jours', subEn: 'Everyday expressions & phrases',
        color: const Color(0xFF0891B2), emoji: '🌿',
        lessons: [
          const _Lesson(id: 'l9',  titleFr: 'Temps',         titleEn: 'Time'),
          const _Lesson(id: 'l10', titleFr: 'Présentations', titleEn: 'Introductions'),
          const _Lesson(id: 'c2',  titleFr: 'Coffre',        titleEn: 'Chest', baseType: _NodeType.chest),
        ],
      ),
      _SectionData(
        titleFr: 'Société & Santé', titleEn: 'Society & Health',
        subFr: 'De la classe à la cuisine — Medumba du quotidien', subEn: 'From classroom to kitchen — real-world Medumba',
        color: const Color(0xFF7C3AED), emoji: '🏫',
        lessons: [
          const _Lesson(id: 'l11', titleFr: 'Cuisine',    titleEn: 'Kitchen'),
          const _Lesson(id: 'l12', titleFr: 'Maladies',   titleEn: 'Illnesses'),
          const _Lesson(id: 'l13', titleFr: 'École',      titleEn: 'School'),
          const _Lesson(id: 'b2',  titleFr: 'Défi Boss',  titleEn: 'Boss Fight', baseType: _NodeType.boss),
          const _Lesson(id: 'l14', titleFr: 'Métiers',    titleEn: 'Professions'),
          const _Lesson(id: 'c3',  titleFr: 'Coffre',     titleEn: 'Chest', baseType: _NodeType.chest),
        ],
      ),
      _SectionData(
        titleFr: 'Culture & Langue', titleEn: 'Culture & Language',
        subFr: 'Conversations, verbes et rites culturels Medumba', subEn: 'Conversations, verbs and Medumba cultural rites',
        color: const Color(0xFFB45309), emoji: '🥁',
        lessons: [
          const _Lesson(id: 'l15', titleFr: 'Conversations',   titleEn: 'Conversations'),
          const _Lesson(id: 'l16', titleFr: "Verbes d'action", titleEn: 'Action Verbs'),
          const _Lesson(id: 'b3',  titleFr: 'Défi Boss',       titleEn: 'Boss Fight', baseType: _NodeType.boss),
          const _Lesson(id: 'l17', titleFr: 'Culture & Rites', titleEn: 'Culture & Rites'),
          const _Lesson(id: 'c4',  titleFr: 'Coffre',          titleEn: 'Chest', baseType: _NodeType.chest),
        ],
      ),
    ];

    // Progression linéaire : seule la première leçon non-complétée est active
    final allLessons = sections.expand((s) => s.lessons).toList();
    final statuses = <String, _NodeType>{};

    String? firstActive;
    for (final l in allLessons) {
      if (l.baseType == _NodeType.chest || l.baseType == _NodeType.boss) continue;
      if (!completedLessons.contains(l.id)) { firstActive = l.id; break; }
    }

    for (final l in allLessons) {
      if (completedLessons.contains(l.id)) {
        statuses[l.id] = _NodeType.done;
      } else if (l.baseType == _NodeType.chest) {
        final reqs = _kChestReqs[l.id] ?? <String>[];
        final unlocked = reqs.every((r) => completedLessons.contains(r));
        statuses[l.id] = unlocked ? _NodeType.chest : _NodeType.chestLocked;
      } else if (l.baseType == _NodeType.boss) {
        final reqs = _kBossReqs[l.id] ?? <String>[];
        final unlocked = reqs.every((r) => completedLessons.contains(r));
        statuses[l.id] = unlocked ? _NodeType.boss : _NodeType.bossLocked;
      } else if (l.id == firstActive) {
        statuses[l.id] = _NodeType.active;
      } else {
        statuses[l.id] = _NodeType.locked;
      }
    }

    // Decorator images — mirrors web app decorators at global node indices
    const decoratorMap = <int, _Decorator>{
      0: _Decorator('assets/images/person2.png', false, 82),
      2: _Decorator('assets/images/laptop 1.png', true,  76),
      4: _Decorator('assets/images/globe 1.png',  false, 70),
      6: _Decorator('assets/images/person1.png',  true,  82),
      8: _Decorator('assets/images/person2.png',  false, 78),
    };

    int globalOffset = 0;
    final result = <Widget>[];
    for (final s in sections) {
      final nodeTypes  = s.lessons.map((l) => statuses[l.id] ?? _NodeType.locked).toList();
      final labels     = s.lessons.map((l) => isFr ? l.titleFr : l.titleEn).toList();
      final lessonIds  = s.lessons.map((l) => l.id).toList();
      final localDeco  = <int, _Decorator>{};
      for (var li = 0; li < s.lessons.length; li++) {
        final gIdx = globalOffset + li;
        if (decoratorMap.containsKey(gIdx)) localDeco[li] = decoratorMap[gIdx]!;
      }
      result.add(_SectionWidget(s: s, isFr: isFr, nodeTypes: nodeTypes, labels: labels, lessonIds: lessonIds, decorators: localDeco, onReturn: onReturn));
      globalOffset += s.lessons.length;
    }
    return result;
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  final bool isFr;
  final int xp;
  const _GreetingCard({required this.name, required this.isFr, required this.xp});

  @override
  Widget build(BuildContext context) {
    final progress = (xp % _xpToNext) / _xpToNext;
    final greeting = isFr ? 'Bonjour${name.isNotEmpty ? ', $name' : ''} 👋' : 'Hello${name.isNotEmpty ? ', $name' : ''} 👋';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBlue.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(greeting, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: kBorder,
                valueColor: const AlwaysStoppedAnimation(kBlue),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${(xp % _xpToNext)} / $_xpToNext XP',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kMuted)),
        ]),
      ]),
    );
  }
}

// ── Decorator image placed beside a node ─────────────────────────────────────

class _Decorator {
  final String image;
  final bool isLeft;
  final double size;
  const _Decorator(this.image, this.isLeft, this.size);
}

// ── Lesson/node model ────────────────────────────────────────────────────────

enum _NodeType { active, done, chest, boss, chestLocked, bossLocked, locked }

class _Lesson {
  final String id, titleFr, titleEn;
  final _NodeType baseType; // chest or boss are special, else regular lesson
  const _Lesson({required this.id, required this.titleFr, required this.titleEn, this.baseType = _NodeType.active});
}

class _SectionData {
  final String titleFr, titleEn, subFr, subEn, emoji;
  final Color color;
  final List<_Lesson> lessons;
  const _SectionData({
    required this.titleFr, required this.titleEn,
    required this.subFr, required this.subEn, required this.emoji,
    required this.color, required this.lessons,
  });
}

// ── Section widget ────────────────────────────────────────────────────────────

class _SectionWidget extends StatelessWidget {
  final _SectionData s;
  final bool isFr;
  final List<_NodeType> nodeTypes;
  final List<String> labels;
  final List<String> lessonIds;
  final Map<int, _Decorator> decorators;
  final VoidCallback? onReturn;
  const _SectionWidget({required this.s, required this.isFr, required this.nodeTypes, required this.labels, required this.lessonIds, this.decorators = const {}, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isFr ? s.titleFr : s.titleEn,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 2),
            Text(isFr ? s.subFr : s.subEn,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          ])),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 24))),
          ),
        ]),
      ),
      _ZigzagNodes(nodes: nodeTypes, labels: labels, lessonIds: lessonIds, decorators: decorators, onReturn: onReturn),
    ]);
  }
}

// ── Zigzag nodes ──────────────────────────────────────────────────────────────

class _ZigzagNodes extends StatelessWidget {
  final List<_NodeType> nodes;
  final List<String> labels;
  final List<String> lessonIds;
  final Map<int, _Decorator> decorators;
  final VoidCallback? onReturn;
  const _ZigzagNodes({required this.nodes, required this.labels, required this.lessonIds, this.decorators = const {}, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final center = w / 2 - 36;
    const amp = 80.0;
    const step = 96.0;
    final xOffsets = [0.0, amp, 0.0, -amp, 0.0, amp, 0.0, -amp];

    final children = <Widget>[];
    for (var i = 0; i < nodes.length; i++) {
      final x = center + xOffsets[i % xOffsets.length];
      final y = i * step + 8.0;
      children.add(Positioned(
        left: x, top: y,
        child: _Node(
          type: nodes[i],
          label: i < labels.length ? labels[i] : '',
          lessonId: i < lessonIds.length ? lessonIds[i] : '',
          onReturn: onReturn,
        ),
      ));
      // Decorator image beside the node
      final deco = decorators[i];
      if (deco != null) {
        final decoX = deco.isLeft
            ? x - deco.size - 8
            : x + 72 + 8;
        children.add(Positioned(
          left: decoX, top: y + (72 - deco.size) / 2,
          child: Image.asset(deco.image, width: deco.size, height: deco.size, fit: BoxFit.contain),
        ));
      }
    }

    return SizedBox(
      height: nodes.length * step + 20,
      child: Stack(children: children),
    );
  }
}

class _Node extends StatelessWidget {
  final _NodeType type;
  final String label;
  final String lessonId;
  final VoidCallback? onReturn;
  const _Node({required this.type, required this.label, required this.lessonId, this.onReturn});

  void _handleTap(BuildContext context) {
    if (type == _NodeType.locked) return;
    if (type == _NodeType.chestLocked || type == _NodeType.bossLocked) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLanguage.instance.isFr
            ? '🔒 Terminez les leçons précédentes pour débloquer !'
            : '🔒 Complete previous lessons to unlock!'),
        backgroundColor: kInk,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final route = _lessonRoutes[lessonId];
    if (route != null) {
      context.push(route).then((_) => onReturn?.call());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$label — leçon à venir bientôt !'),
        backgroundColor: kInk,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = type == _NodeType.locked;

    Widget inner;

    if (type == _NodeType.chest || type == _NodeType.chestLocked) {
      inner = Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kInk), textAlign: TextAlign.center),
      ]);
    } else if (type == _NodeType.boss || type == _NodeType.bossLocked) {
      inner = Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kInk), textAlign: TextAlign.center),
      ]);
    } else if (type == _NodeType.active) {
      inner = Column(children: [
        Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: kBlue, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kBlue.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 38),
          ),
          Positioned(
            top: -30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(8)),
              child: const Text('START!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kBlue), textAlign: TextAlign.center),
      ]);
    } else if (type == _NodeType.done) {
      inner = Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107), shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kInk), textAlign: TextAlign.center),
      ]);
    } else {
      // Locked
      inner = Column(children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Color(0xFFDDE0E5), shape: BoxShape.circle),
          child: const Icon(Icons.lock_rounded, color: Color(0xFF9AA0AB), size: 26),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF9AA0AB)), textAlign: TextAlign.center),
      ]);
    }

    return GestureDetector(
      onTap: locked ? null : () => _handleTap(context),
      child: inner,
    );
  }
}

// ── Accès rapide (Alphabet + Compter) ────────────────────────────────────────

class _QuickAccessRow extends StatelessWidget {
  final bool isFr;
  const _QuickAccessRow({required this.isFr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(children: [
        Row(children: [
          _QuickBtn(
            emoji: '🔤',
            label: isFr ? 'Alphabet' : 'Alphabet',
            color: const Color(0xFFD97706),
            onTap: () => context.push('/lesson/alphabet'),
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            emoji: '🔢',
            label: isFr ? 'Compter' : 'Counting',
            color: const Color(0xFF0891B2),
            onTap: () => context.push('/lesson/counting'),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _QuickBtn(
            emoji: '📅',
            label: isFr ? 'Calendrier' : 'Calendar',
            color: const Color(0xFF16A34A),
            onTap: () => context.push('/lesson/calendar'),
          ),
          const SizedBox(width: 8),
          _QuickBtn(
            emoji: '📖',
            label: isFr ? 'Dictionnaire' : 'Dictionary',
            color: const Color(0xFF7C3AED),
            onTap: () => context.push('/lesson/dictionary'),
          ),
        ]),
      ]),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 16, color: color.withValues(alpha: 0.6)),
        ]),
      ),
    ),
  );
}
