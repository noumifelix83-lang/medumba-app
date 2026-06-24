import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _page = PageController();
  int _current = 0;

  final List<_Slide> _slides = const [
    _Slide(
      emoji: '🎯',
      title: 'Apprenez le Medumba',
      subtitle: 'La langue du peuple Bangangté.\nGamifiée, intuitive, efficace.',
      bg: kBlue,
    ),
    _Slide(
      emoji: '🔊',
      title: 'Locuteurs natifs',
      subtitle: 'Écoutez de vrais locuteurs\net pratiquez votre prononciation.',
      bg: Color(0xFF7C3AED),
    ),
    _Slide(
      emoji: '🏆',
      title: 'Gagnez des XP',
      subtitle: 'Combos, streaks, diamants —\nchaque leçon est une victoire.',
      bg: Color(0xFF0891B2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => AnimatedContainer(
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
                        if (_current < _slides.length - 1) {
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
                        _current < _slides.length - 1 ? 'Suivant' : 'Commencer gratuitement',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  if (_current < _slides.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text('Passer', style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
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
  final String emoji, title, subtitle;
  final Color bg;
  const _Slide({required this.emoji, required this.title, required this.subtitle, required this.bg});
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
              Text(slide.emoji, style: const TextStyle(fontSize: 96)),
              const SizedBox(height: 40),
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
