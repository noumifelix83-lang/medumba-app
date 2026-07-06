import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _page = PageController();
  int _current = 0;

  bool get _isFr => OnboardingState.instance.nativeLang == 'french';

  List<_Slide> get _slides => [
    _Slide(
      image: 'assets/images/tutor.png',
      title: _isFr ? 'Apprenez le Medumba' : 'Learn Medumba',
      subtitle: _isFr
          ? 'La langue du peuple Bangangté.\nGamifiée, intuitive, efficace.'
          : 'The language of the Bangangté people.\nGamified, intuitive, effective.',
      bg: kBlue,
    ),
    _Slide(
      image: 'assets/images/teacher 1.png',
      title: _isFr ? 'Locuteurs natifs' : 'Native speakers',
      subtitle: _isFr
          ? 'Écoutez de vrais locuteurs\net pratiquez votre prononciation.'
          : 'Listen to real native speakers\nand practice your pronunciation.',
      bg: const Color(0xFF7C3AED),
    ),
    _Slide(
      image: 'assets/images/teacher2.png',
      title: _isFr ? 'Gagnez des XP' : 'Earn XP',
      subtitle: _isFr
          ? 'Combos, streaks, diamants —\nchaque leçon est une victoire.'
          : 'Combos, streaks, diamonds —\nevery lesson is a win.',
      bg: const Color(0xFF0891B2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final isFr = _isFr;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _SlideWidget(slide: slides[i]),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _current == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_current == i ? 1 : 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_current < slides.length - 1) {
                          _page.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          context.go('/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _current < slides.length - 1
                            ? (isFr ? 'Suivant' : 'Next')
                            : (isFr ? 'Commencer gratuitement' : 'Start for free'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  if (_current < slides.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(isFr ? 'Passer' : 'Skip',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String image, title, subtitle;
  final Color bg;
  const _Slide({required this.image, required this.title, required this.subtitle, required this.bg});
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: slide.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(slide.image, height: 220, fit: BoxFit.contain),
              const SizedBox(height: 32),
              Text(slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                      color: Colors.white, height: 1.15)),
              const SizedBox(height: 16),
              Text(slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.8),
                      height: 1.6, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
