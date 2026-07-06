import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  bool get _isFr => OnboardingState.instance.nativeLang == 'french';
  bool get _ok => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_ctrl.text.trim());

  Future<void> _reset() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.resetPassword(_ctrl.text.trim());
      if (mounted) setState(() { _sent = true; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = _isFr
            ? 'Erreur — vérifiez l\'adresse e-mail.'
            : 'Error — check your email address.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isFr = _isFr;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kInk),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _sent
                    ? _SentView(email: _ctrl.text.trim(), isFr: isFr)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isFr ? 'Mot de passe oublié ? 🔑' : 'Forgot your password? 🔑',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kInk)),
                          const SizedBox(height: 12),
                          Text(
                            isFr
                                ? 'Saisissez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.'
                                : 'Enter your email address and we\'ll send you a link to reset your password.',
                            style: const TextStyle(fontSize: 15, color: kMuted, height: 1.5, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 40),
                          Text('E-MAIL',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kMuted, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ctrl,
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kInk),
                            decoration: InputDecoration(
                              hintText: 'your@email.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2.5)),
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
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _ok && !_loading ? _reset : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: kBlue.withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : Text(isFr ? 'ENVOYER LE LIEN' : 'SEND LINK',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  final String email;
  final bool isFr;
  const _SentView({required this.email, required this.isFr});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Text('📬', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 24),
        Text(isFr ? 'E-mail envoyé !' : 'Email sent!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kInk)),
        const SizedBox(height: 16),
        Text(
          isFr
              ? 'Nous avons envoyé un lien de réinitialisation à\n$email'
              : 'We sent a reset link to\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: kMuted, height: 1.5, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () => context.go('/signin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              elevation: 0,
            ),
            child: Text(isFr ? 'RETOUR À LA CONNEXION' : 'BACK TO SIGN IN',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
