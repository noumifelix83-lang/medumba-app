import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class QuickSetupScreen extends StatefulWidget {
  const QuickSetupScreen({super.key});
  @override
  State<QuickSetupScreen> createState() => _QuickSetupScreenState();
}

class _QuickSetupScreenState extends State<QuickSetupScreen> {
  final _state = OnboardingState.instance;
  int _step = 0;
  bool get _isFr => _state.nativeLang == 'french';

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.push('/register/name');
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: (_step + 1) / 3,
      onBack: _back,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: _step == 0
              ? _LevelStep(state: _state, isFr: _isFr, onNext: _next)
              : _step == 1
                  ? _ReasonStep(state: _state, isFr: _isFr, onNext: _next)
                  : _GoalStep(state: _state, isFr: _isFr, onNext: _next),
        ),
      ),
    );
  }
}

// ── Step 1: Level ─────────────────────────────────────────────────────────────

class _LevelStep extends StatefulWidget {
  final OnboardingState state;
  final bool isFr;
  final VoidCallback onNext;
  const _LevelStep({required this.state, required this.isFr, required this.onNext});
  @override
  State<_LevelStep> createState() => _LevelStepState();
}

class _LevelStepState extends State<_LevelStep> {
  final _options = const [
    _Option(id: 1, icon: Icons.signal_cellular_alt_1_bar_rounded,
        labelFr: 'Débutant absolu', labelEn: 'Absolute beginner',
        subFr: 'Je ne connais aucun mot', subEn: "I know no words"),
    _Option(id: 2, icon: Icons.signal_cellular_alt_2_bar_rounded,
        labelFr: 'Quelques mots', labelEn: 'A few words',
        subFr: 'Entendu à la maison', subEn: 'Heard it at home'),
    _Option(id: 3, icon: Icons.signal_cellular_alt_rounded,
        labelFr: 'Intermédiaire', labelEn: 'Intermediate',
        subFr: 'Je comprends mais hésite', subEn: 'I understand but struggle'),
    _Option(id: 4, icon: Icons.signal_cellular_4_bar_rounded,
        labelFr: 'Avancé', labelEn: 'Advanced',
        subFr: 'Je veux me perfectionner', subEn: 'I want to perfect it'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = widget.isFr ? 'Votre niveau en Medumba ?' : 'How much Medumba do you know?';
    return _StepLayout(
      question: q,
      canContinue: widget.state.level != null,
      onNext: widget.onNext,
      isFr: widget.isFr,
      children: _options.map((o) {
        final selected = widget.state.level == o.id;
        return _OptionCard(
          selected: selected,
          onTap: () => setState(() => widget.state.level = o.id),
          child: Row(children: [
            Icon(o.icon, color: selected ? kBlue : const Color(0xFF94A3B8), size: 28),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.isFr ? o.labelFr : o.labelEn,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: selected ? kBlue : kInk)),
              Text(widget.isFr ? o.subFr : o.subEn,
                  style: const TextStyle(fontSize: 13, color: kMuted)),
            ])),
          ]),
        );
      }).toList(),
    );
  }
}

// ── Step 2: Reason ────────────────────────────────────────────────────────────

class _ReasonStep extends StatefulWidget {
  final OnboardingState state;
  final bool isFr;
  final VoidCallback onNext;
  const _ReasonStep({required this.state, required this.isFr, required this.onNext});
  @override
  State<_ReasonStep> createState() => _ReasonStepState();
}

class _ReasonStepState extends State<_ReasonStep> {
  final _options = const [
    _StrOption(id: 'family',  emoji: '🏡', labelFr: 'Famille',  labelEn: 'Family'),
    _StrOption(id: 'culture', emoji: '🎭', labelFr: 'Culture',  labelEn: 'Culture'),
    _StrOption(id: 'career',  emoji: '💼', labelFr: 'Carrière', labelEn: 'Career'),
    _StrOption(id: 'fun',     emoji: '😁', labelFr: 'Plaisir',  labelEn: 'Just for fun'),
    _StrOption(id: 'other',   emoji: '🧩', labelFr: 'Autre',    labelEn: 'Others reason'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = widget.isFr ? 'Pourquoi apprenez-vous ?' : 'Why are you learning?';
    return _StepLayout(
      question: q,
      canContinue: widget.state.reason != null,
      onNext: widget.onNext,
      isFr: widget.isFr,
      children: _options.map((o) {
        final selected = widget.state.reason == o.id;
        return _OptionCard(
          selected: selected,
          onTap: () => setState(() => widget.state.reason = o.id),
          child: Row(children: [
            Text(o.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(widget.isFr ? o.labelFr : o.labelEn,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: selected ? kBlue : kInk)),
          ]),
        );
      }).toList(),
    );
  }
}

// ── Step 3: Goal ──────────────────────────────────────────────────────────────

class _GoalStep extends StatefulWidget {
  final OnboardingState state;
  final bool isFr;
  final VoidCallback onNext;
  const _GoalStep({required this.state, required this.isFr, required this.onNext});
  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
  final _options = const [
    _GoalOption(id: 'relaxed', time: '5 mins / jour',  labelFr: 'Détendu',  labelEn: 'Relax'),
    _GoalOption(id: 'normal',  time: '10 mins / jour', labelFr: 'Normal',   labelEn: 'Normal'),
    _GoalOption(id: 'serious', time: '15 mins / jour', labelFr: 'Sérieux',  labelEn: 'Serious'),
    _GoalOption(id: 'intense', time: '30 mins / jour', labelFr: 'Intensif', labelEn: 'Great'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = widget.isFr ? 'Objectif quotidien ?' : 'What is your daily study target?';
    return _StepLayout(
      question: q,
      canContinue: widget.state.dailyGoal != null,
      onNext: widget.onNext,
      isFr: widget.isFr,
      children: _options.map((o) {
        final selected = widget.state.dailyGoal == o.id;
        return _OptionCard(
          selected: selected,
          onTap: () => setState(() => widget.state.dailyGoal = o.id),
          child: Row(children: [
            Expanded(
              child: Text(o.time,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: selected ? kBlue : kInk)),
            ),
            Text(widget.isFr ? o.labelFr : o.labelEn,
                style: const TextStyle(fontSize: 14, color: kMuted, fontWeight: FontWeight.w500)),
          ]),
        );
      }).toList(),
    );
  }
}

// ── Shared step layout ────────────────────────────────────────────────────────

class _StepLayout extends StatelessWidget {
  final String question;
  final bool canContinue;
  final bool isFr;
  final VoidCallback onNext;
  final List<Widget> children;
  const _StepLayout({
    required this.question,
    required this.canContinue,
    required this.isFr,
    required this.onNext,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Speech bubble
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: kBlue,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/images/logo-medumba.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(question,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kInk)),
            ),
          ),
        ]),
      ),

      const SizedBox(height: 16),
      const Divider(height: 1, color: kBorder),
      const SizedBox(height: 8),

      // Options
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => children[i],
        ),
      ),

      // Continue button
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: PillButton(
          label: isFr ? 'Continuer' : 'Continue',
          onPressed: canContinue ? onNext : null,
        ),
      ),
    ]);
  }
}

// ── Option card ───────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  const _OptionCard({required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
          border: Border.all(
              color: selected ? kBlue : kBorder,
              width: selected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Option {
  final int id;
  final IconData icon;
  final String labelFr, labelEn, subFr, subEn;
  const _Option({required this.id, required this.icon,
      required this.labelFr, required this.labelEn,
      required this.subFr, required this.subEn});
}

class _StrOption {
  final String id, emoji, labelFr, labelEn;
  const _StrOption({required this.id, required this.emoji,
      required this.labelFr, required this.labelEn});
}

class _GoalOption {
  final String id, time, labelFr, labelEn;
  const _GoalOption({required this.id, required this.time,
      required this.labelFr, required this.labelEn});
}
