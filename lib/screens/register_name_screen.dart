import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});
  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  final _ctrl = TextEditingController();
  final _state = OnboardingState.instance;
  bool get _isFr => _state.nativeLang == 'french';

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ok = _ctrl.text.trim().isNotEmpty;
    return OnboardingScaffold(
      progress: 0.65,
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isFr ? "Comment t'appelles-tu ? 👨🏽👧🏽" : "What is your name? 👨🏽👧🏽",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 40),
          Text((_isFr ? 'Nom complet' : 'Full Name').toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kInk),
            decoration: InputDecoration(
              hintText: _isFr ? 'ex. Jean Dupont' : 'e.g. John Doe',
              hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2.5)),
            ),
          ),
          const Spacer(),
          PillButton(
            label: _isFr ? 'Continuer' : 'Continue',
            onPressed: ok ? () { _state.name = _ctrl.text.trim(); context.push('/register/age'); } : null,
          ),
        ]),
      ),
    );
  }
}
