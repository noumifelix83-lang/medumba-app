// Singleton léger pour partager les données d'onboarding entre écrans
class OnboardingState {
  OnboardingState._();
  static final OnboardingState instance = OnboardingState._();

  String nativeLang   = 'french';
  String learningLang = 'medumba';
  int?   level;
  String? reason;
  String? dailyGoal;
  String name  = '';
  String age   = '';
  String email = '';
}
