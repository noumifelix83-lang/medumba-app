import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                ),
                const SizedBox(width: 10),
                const Text('Medumba.AI', style: TextStyle(fontWeight: FontWeight.w900, color: kInk, fontSize: 18)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: kAmber, size: 20),
                    const SizedBox(width: 2),
                    const Text('7', style: TextStyle(fontWeight: FontWeight.w800, color: kAmber)),
                    const SizedBox(width: 12),
                    const Icon(Icons.diamond_rounded, color: Color(0xFF06B6D4), size: 20),
                    const SizedBox(width: 2),
                    const Text('120', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF06B6D4))),
                  ],
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingCard(),
                const SizedBox(height: 16),
                _ProgressCard(),
                const SizedBox(height: 16),
                _SectionTitle('Continuer l\'apprentissage'),
                const SizedBox(height: 10),
                _LessonCard(
                  title: 'Salutations',
                  subtitle: 'Leçon 1 · Débutant',
                  progress: 0.6,
                  emoji: '👋',
                  xp: 50,
                ),
                const SizedBox(height: 10),
                _LessonCard(
                  title: 'La famille',
                  subtitle: 'Leçon 2 · Débutant',
                  progress: 0.2,
                  emoji: '👨‍👩‍👧',
                  xp: 60,
                ),
                const SizedBox(height: 10),
                _LessonCard(
                  title: 'Les chiffres',
                  subtitle: 'Leçon 3 · Débutant',
                  progress: 0.0,
                  emoji: '🔢',
                  xp: 40,
                ),
                const SizedBox(height: 16),
                _SectionTitle('Phrase du jour'),
                const SizedBox(height: 10),
                _PhraseOfDay(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kBlue, Color(0xFF3B82F6)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bonjour ! 👋', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Continuez votre streak de 7 jours !',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 28))),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progression du jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kInk)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 10,
                    backgroundColor: kBorder,
                    valueColor: const AlwaysStoppedAnimation(kBlue),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('40%', style: TextStyle(fontWeight: FontWeight.w700, color: kBlue, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _Stat(icon: Icons.star_rounded, value: '320', label: 'XP', color: kAmber),
              _Stat(icon: Icons.diamond_rounded, value: '120', label: 'Diamants', color: Color(0xFF06B6D4)),
              _Stat(icon: Icons.military_tech_rounded, value: 'A1', label: 'Niveau', color: kGreen),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Stat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 10, color: kMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kInk));
  }
}

class _LessonCard extends StatelessWidget {
  final String title, subtitle, emoji;
  final double progress;
  final int xp;
  const _LessonCard({required this.title, required this.subtitle, required this.progress, required this.emoji, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kInk)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: kBorder,
                    valueColor: const AlwaysStoppedAnimation(kBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Icon(Icons.bolt_rounded, color: kAmber, size: 18),
              Text('+$xp', style: const TextStyle(fontWeight: FontWeight.w800, color: kAmber, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhraseOfDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.format_quote_rounded, color: kGreen, size: 20),
              SizedBox(width: 6),
              Text('Phrase du jour', style: TextStyle(fontWeight: FontWeight.w700, color: kGreen, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Mbə̀ wap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 4),
          const Text('Bonjour / Bonsoir', style: TextStyle(fontSize: 15, color: kMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              _Tag('Salutations'),
              const SizedBox(width: 8),
              _Tag('A1'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: kGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
    );
  }
}
