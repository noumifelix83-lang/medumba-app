import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _remember = true;
  bool _loading  = false;
  bool _googleLoading = false;
  String? _error;

  bool get _isFr => OnboardingState.instance.nativeLang == 'french';

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.loginUser(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home/dashboard');
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.toLowerCase().contains('invalid login credentials') ||
          msg.toLowerCase().contains('invalid_credentials')) {
        msg = _isFr
            ? 'Email ou mot de passe incorrect.\nSi vous venez de créer un compte, vérifiez votre boîte mail pour confirmer votre email.'
            : 'Incorrect email or password.\nIf you just created an account, check your inbox to confirm your email.';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = _isFr ? 'Une erreur est survenue' : 'An error occurred');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.medumbaapp://login-callback/',
      );
      // La navigation vers dashboard est gérée automatiquement par le refresh du routeur
    } catch (e) {
      if (mounted) setState(() => _error = _isFr ? 'Impossible de se connecter avec Google.' : 'Could not sign in with Google.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hello there 👋',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kInk)),
                    const SizedBox(height: 40),
                    const Text('Email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kMuted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kInk),
                      decoration: InputDecoration(
                        hintText: 'votre@email.com',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kBorder, width: 1.5)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kBlue, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Password',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kMuted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kInk),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kBorder, width: 1.5)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kBlue, width: 2)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                              color: kMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Checkbox(
                        value: _remember,
                        onChanged: (v) => setState(() => _remember = v ?? false),
                        activeColor: kBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const Text('Remember me',
                          style: TextStyle(fontWeight: FontWeight.w500, color: kInk)),
                    ]),
                    const Divider(height: 32),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Forgot Password?',
                            style: TextStyle(color: kBlue, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(_isFr ? 'ou' : 'or', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _googleLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorder, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        ),
                        child: _googleLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBlue))
                          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.red[600])),
                              const SizedBox(width: 10),
                              Text(_isFr ? 'Continuer avec Google' : 'Continue with Google',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: kInk, fontSize: 15)),
                            ]),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(_error!,
                            style: const TextStyle(color: kRed, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('SIGN IN',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
