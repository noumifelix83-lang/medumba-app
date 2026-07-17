import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/phrasebook_screen.dart';
import 'screens/word_cards_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/account_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/quick_setup_screen.dart';
import 'screens/register_name_screen.dart';
import 'screens/register_age_screen.dart';
import 'screens/register_email_screen.dart';
import 'screens/register_password_screen.dart';
import 'screens/register_success_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/counting_screen.dart';
import 'screens/alphabet_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/vocab_screen.dart';
import 'screens/lesson_exercise_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/pronunciation_screen.dart';
import 'screens/video_screen.dart';
import 'screens/chest_screen.dart';
import 'screens/boss_screen.dart';
import 'screens/cepom_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/certification_screen.dart';
import 'theme/colors.dart';

final _authNotifier = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Rafraîchit le routeur à chaque changement d'état d'auth (OAuth Google inclus)
  Supabase.instance.client.auth.onAuthStateChange.listen((_) {
    _authNotifier.value++;
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MedumbaApp());
}

final _router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isAuth = user != null;
    final onPublic = state.matchedLocation == '/' ||
        state.matchedLocation == '/welcome' ||
        state.matchedLocation == '/signin' ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/language') ||
        state.matchedLocation.startsWith('/quick') ||
        state.matchedLocation == '/forgot-password';
    if (isAuth && onPublic) return '/home/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/',                   builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/welcome',            builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/onboarding',         builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/signin',             builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/forgot-password',    builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/language-selection', builder: (_, __) => const LanguageSelectionScreen()),
    GoRoute(path: '/quick-setup',        builder: (_, __) => const QuickSetupScreen()),
    GoRoute(path: '/register/name',      builder: (_, __) => const RegisterNameScreen()),
    GoRoute(path: '/register/age',       builder: (_, __) => const RegisterAgeScreen()),
    GoRoute(path: '/register/email',     builder: (_, __) => const RegisterEmailScreen()),
    GoRoute(path: '/register/password',  builder: (_, __) => const RegisterPasswordScreen()),
    GoRoute(path: '/register/otp',       builder: (_, __) => const OtpVerificationScreen()),
    GoRoute(path: '/register/success',   builder: (_, __) => const RegisterSuccessScreen()),
    GoRoute(path: '/lesson/counting',    builder: (_, __) => const CountingScreen()),
    GoRoute(path: '/lesson/alphabet',    builder: (_, __) => const AlphabetScreen()),
    GoRoute(path: '/lesson/alphabet-intro', builder: (_, __) => const AlphabetScreen(fromLessonPath: true)),
    GoRoute(path: '/lesson/calendar',    builder: (_, __) => const CalendarScreen()),
    GoRoute(path: '/lesson/dictionary',  builder: (_, __) => const DictionaryScreen()),
    GoRoute(path: '/lesson/vocab',         builder: (_, __) => const VocabScreen()),
    GoRoute(path: '/lesson/vocab/:id',     builder: (_, s) => LessonExerciseScreen(lessonId: s.pathParameters['id']!)),
    GoRoute(path: '/lesson/pronunciation', builder: (_, __) => const PronunciationScreen()),
    GoRoute(path: '/lesson/videos',        builder: (_, __) => const VideoScreen()),
    GoRoute(path: '/lesson/chest/:id',     builder: (_, s) => ChestScreen(chestId: s.pathParameters['id']!)),
    GoRoute(path: '/lesson/boss/:id',      builder: (_, s) => BossScreen(bossId: s.pathParameters['id']!)),
    GoRoute(path: '/lesson/cepom',         builder: (_, __) => const CepomScreen()),
    GoRoute(path: '/lesson/contact',       builder: (_, __) => const ContactScreen()),
    GoRoute(path: '/lesson/certification/:unitId', builder: (_, s) => CertificationScreen(unitId: s.pathParameters['unitId']!)),
    ShellRoute(
      builder: (_, __, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/home/dashboard',  builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/home/phrasebook', builder: (_, __) => const PhrasebookScreen()),
        GoRoute(path: '/home/wordcards',  builder: (_, __) => const WordCardsScreen()),
        GoRoute(path: '/home/challenge',  builder: (_, __) => const ChallengeScreen()),
        GoRoute(path: '/home/profile',    builder: (_, __) => const AccountScreen()),
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
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}
