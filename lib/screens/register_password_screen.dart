import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class RegisterPasswordScreen extends StatefulWidget {
  const RegisterPasswordScreen({super.key});
  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  final _ctrl    = TextEditingController();
  final _state   = OnboardingState.instance;
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;
  bool get _isFr => _state.nativeLang == 'french';
  bool get _ok   => _ctrl.text.length >= 6;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.registerUser(
        name:      _state.name,
        email:     _state.email,
        password:  _ctrl.text,
        age:       _state.age.isNotEmpty ? _state.age : null,
        language:  _state.nativeLang,
        reason:    _state.reason,
        dailyGoal: _state.dailyGoal ?? 'normal',
      );
      if (mounted) context.go('/register/otp');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = _isFr ? 'Erreur : réessayez.' : 'Error: try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: 1.0,
      onBack: () => context.pop(),
      child: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isFr ? "Crée un mot de passe 🔒" : "Create a password 🔒",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 40),
          Text((_isFr ? 'Mot de passe' : 'Password').toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kInk),
            decoration: InputDecoration(
              hintText: _isFr ? 'Minimum 6 caractères' : 'Minimum 6 characters',
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2.5)),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: kRed, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 40),
          PillButton(
            label: _isFr ? "C'est parti !" : "Let's go!",
            onPressed: _ok && !_loading ? _register : null,
            loading: _loading,
          ),
        ]),
      ),
    );
  }
}
