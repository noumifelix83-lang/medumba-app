import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});
  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _ctrl = TextEditingController();
  final _state = OnboardingState.instance;
  bool get _isFr => _state.nativeLang == 'french';

  bool get _ok => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_ctrl.text.trim());

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: 0.85,
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isFr ? "Quelle est ton adresse e-mail ? 📧" : "What is your email? 📧",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 40),
          Text((_isFr ? 'Adresse e-mail' : 'Email address').toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kInk),
            decoration: InputDecoration(
              hintText: 'exemple@email.com',
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2.5)),
            ),
          ),
          const Spacer(),
          PillButton(
            label: _isFr ? 'Continuer' : 'Continue',
            onPressed: _ok ? () { _state.email = _ctrl.text.trim(); context.push('/register/password'); } : null,
          ),
        ]),
      ),
    );
  }
}
