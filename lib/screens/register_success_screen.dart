import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';
import '../widgets/onboarding_scaffold.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = OnboardingState.instance.name.split(' ').first;
    final isFr = OnboardingState.instance.nativeLang == 'french';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/images/welcom vector.png', height: 220),
              const SizedBox(height: 16),
              Text(
                isFr ? 'Bienvenue, $name !' : 'Welcome, $name!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kInk),
              ),
              const SizedBox(height: 16),
              Text(
                isFr
                  ? 'Ton compte est créé. Tu peux maintenant apprendre le Medumba !'
                  : 'Your account is ready. Start learning Medumba now!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: kMuted, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              PillButton(
                label: isFr ? 'Commencer à apprendre' : 'Start learning',
                onPressed: () => context.go('/home/dashboard'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
