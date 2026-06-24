import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/placeholder_screen.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MedumbaApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (_, __, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/home/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/home/lessons', builder: (_, __) => const PlaceholderScreen(title: 'Leçons', emoji: '📚')),
        GoRoute(path: '/home/phrasebook', builder: (_, __) => const PlaceholderScreen(title: 'Phrasebook Audio', emoji: '🔊')),
        GoRoute(path: '/home/dictionary', builder: (_, __) => const PlaceholderScreen(title: 'Dictionnaire', emoji: '📖')),
        GoRoute(path: '/home/profile', builder: (_, __) => const PlaceholderScreen(title: 'Profil', emoji: '👤')),
      ],
    ),
    GoRoute(path: '/home', redirect: (_, __) => '/home/dashboard'),
  ],
);

class MedumbaApp extends StatelessWidget {
  const MedumbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Medumba.AI',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBlue),
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: kSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}
