import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final _state = OnboardingState.instance;

  final _nativeLangs = const [
    {'value': 'french',  'flag': '🇫🇷', 'label': 'Français'},
    {'value': 'english', 'flag': '🇬🇧', 'label': 'English'},
  ];
  final _learningLangs = const [
    {'value': 'medumba', 'flag': '🇨🇲', 'label': 'Medumba'},
    {'value': 'english', 'flag': '🇬🇧', 'label': 'English'},
  ];

  bool get _isFr => _state.nativeLang == 'french';

  @override
  Widget build(BuildContext context) {
    final canContinue = _state.nativeLang.isNotEmpty && _state.learningLang.isNotEmpty;

    return OnboardingScaffold(
      progress: 0.2,
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isFr ? 'Choisissez vos langues !' : 'Choose your languages!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk),
            ),
            const SizedBox(height: 32),
            _LangLabel(_isFr ? 'Langue maternelle' : 'Native language'),
            const SizedBox(height: 8),
            _LangDropdown(
              value: _state.nativeLang,
              items: _nativeLangs,
              onChanged: (v) => setState(() => _state.nativeLang = v!),
            ),
            const SizedBox(height: 28),
            _LangLabel(_isFr ? 'Langue à apprendre' : 'Language to learn'),
            const SizedBox(height: 8),
            _LangDropdown(
              value: _state.learningLang,
              items: _learningLangs,
              onChanged: (v) => setState(() => _state.learningLang = v!),
            ),
            const Spacer(),
            PillButton(
              label: _isFr ? 'Continuer' : 'Continue',
              onPressed: canContinue ? () => context.push('/quick-setup') : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangLabel extends StatelessWidget {
  final String text;
  const _LangLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.5),
  );
}

class _LangDropdown extends StatelessWidget {
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  const _LangDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kInk),
        items: items.map((lang) => DropdownMenuItem(
          value: lang['value'],
          child: Text('${lang['flag']}  ${lang['label']}'),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
