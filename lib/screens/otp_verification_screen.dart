import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _kLen = 6;
  final _state       = OnboardingState.instance;
  final _controllers = List.generate(_kLen, (_) => TextEditingController());
  final _focusNodes  = List.generate(_kLen, (_) => FocusNode());

  int  _seconds   = 55;
  bool _canResend = false;
  bool _loading   = false;
  String? _error;
  Timer? _timer;

  bool get _isFr     => _state.nativeLang == 'french';
  bool get _complete => _controllers.every((c) => c.text.isNotEmpty);
  String get _otp    => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _seconds = 55; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_seconds <= 1) {
        t.cancel();
        setState(() { _seconds = 0; _canResend = true; });
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _state.email,
      );
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      _startTimer();
    } catch (e) {
      setState(() => _error = _isFr ? 'Erreur lors du renvoi.' : 'Resend failed.');
    }
  }

  Future<void> _confirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _state.email,
        token: _otp,
        type: OtpType.signup,
      );
      if (mounted) context.go('/register/success');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = _isFr ? 'Code invalide.' : 'Invalid code.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _state.email;
    final masked = email.isEmpty
        ? (_isFr ? 'votre e-mail' : 'your email')
        : email.replaceFirstMapped(RegExp(r'^(.{2})(.+?)(@.+)$'), (m) => '${m[1]}***${m[3]}');

    return OnboardingScaffold(
      progress: 1.0,
      onBack: () => context.pop(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _isFr ? "Vous avez du courrier 📬" : "You've got mail 📬",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk),
          ),
          const SizedBox(height: 12),
          Text(
            _isFr
                ? "Nous avons envoyé le code OTP à $masked. Vérifiez votre e-mail et entrez le code ci-dessous."
                : "We have sent the OTP verification code to $masked. Check your email and enter the code below.",
            style: const TextStyle(fontSize: 14, color: kMuted, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),

          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_kLen, (i) => _OtpBox(
              controller: _controllers[i],
              focusNode:  _focusNodes[i],
              onFilled: () {
                if (i < _kLen - 1) _focusNodes[i + 1].requestFocus();
                setState(() {});
              },
              onCleared: () {
                if (i > 0) _focusNodes[i - 1].requestFocus();
                setState(() {});
              },
              onChange: () => setState(() {}),
            )),
          ),
          const SizedBox(height: 32),

          // Resend section
          Center(child: Column(children: [
            Text(
              _isFr ? "Vous n'avez pas reçu l'e-mail ?" : "Didn't receive email?",
              style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _canResend
                ? GestureDetector(
                    onTap: _resend,
                    child: Text(
                      _isFr ? 'Renvoyer le code' : 'Resend code',
                      style: const TextStyle(
                        color: kBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  )
                : Text(
                    _isFr
                        ? 'Vous pouvez renvoyer dans ${_seconds}s'
                        : 'You can resend code in ${_seconds}s',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ])),

          if (_error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: kRed, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],

          const SizedBox(height: 48),
          PillButton(
            label: _isFr ? 'Confirmer' : 'Confirm',
            onPressed: _complete && !_loading ? _confirm : null,
            loading: _loading,
          ),
        ]),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;
  final VoidCallback onCleared;
  final VoidCallback onChange;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
    required this.onCleared,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onCleared();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode:  focusNode,
          textAlign:  TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            if (v.isNotEmpty) {
              onFilled();
            } else {
              onCleared();
            }
          },
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: kBlue,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: filled ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: filled ? kBlue : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: filled ? kBlue : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBlue, width: 2.5),
            ),
          ),
        ),
      ),
    );
  }
}
