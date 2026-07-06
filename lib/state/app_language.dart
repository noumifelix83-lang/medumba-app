// Shared language state — updated by dashboard, read by all screens
class AppLanguage {
  AppLanguage._();
  static final instance = AppLanguage._();
  bool isFr = true;
}
