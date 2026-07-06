import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class RegisterAgeScreen extends StatefulWidget {
  const RegisterAgeScreen({super.key});
  @override
  State<RegisterAgeScreen> createState() => _RegisterAgeScreenState();
}

class _RegisterAgeScreenState extends State<RegisterAgeScreen> {
  final _state = OnboardingState.instance;
  bool get _isFr => _state.nativeLang == 'french';

  final _ranges = ['< 13', '13-17', '18-24', '25-34', '35-44', '45-54', '55+'];
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: 0.75,
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _isFr ? "Quelle est ta tranche d'âge ? 🎂" : "What is your age range? 🎂",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk),
          ),
          const SizedBox(height: 8),
          Text(
            _isFr ? 'Optionnel — aide à personnaliser ton parcours' : 'Optional — helps personalize your journey',
            style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _ranges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = _ranges[i];
                final sel = _selected == r;
                return GestureDetector(
                  onTap: () => setState(() => _selected = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: sel ? kBlue : kBorder, width: 2),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: sel
                          ? [BoxShadow(color: kBlue.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(children: [
                      Text(r, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: sel ? kBlue : kInk)),
                      const Spacer(),
                      if (sel)
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PillButton(
            label: _isFr ? 'Continuer' : 'Continue',
            onPressed: () {
              if (_selected != null) _state.age = _selected!;
              context.push('/register/email');
            },
          ),
          if (_selected == null) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => context.push('/register/email'),
                child: Text(
                  _isFr ? 'Passer cette étape' : 'Skip this step',
                  style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
