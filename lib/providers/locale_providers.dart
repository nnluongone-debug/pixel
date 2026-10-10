import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Language choice offered in Config. [system] follows the device.
enum AppLanguage {
  system(null),
  english(Locale('en')),
  vietnamese(Locale('vi'));

  const AppLanguage(this.locale);

  /// Locale forced on the app, or null to follow the device.
  final Locale? locale;

  static AppLanguage fromName(String? name) => AppLanguage.values.firstWhere(
    (l) => l.name == name,
    orElse: () => AppLanguage.system,
  );
}

/// Loaded once in `main()` and injected via `ProviderScope.overrides`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

/// Persists the user's language choice across launches.
class AppLanguageController extends Notifier<AppLanguage> {
  static const _key = 'app_language';

  @override
  AppLanguage build() => AppLanguage.fromName(
    ref.watch(sharedPreferencesProvider).getString(_key),
  );

  Future<void> select(AppLanguage language) async {
    state = language;
    await ref.read(sharedPreferencesProvider).setString(_key, language.name);
  }
}

/// The locale the UI actually renders in, resolving [AppLanguage.system]
/// against the device languages. Used for text built outside the widget
/// tree (notifications, home screen widget).
final effectiveLocaleProvider = Provider<Locale>((ref) {
  final forced = ref.watch(appLanguageProvider).locale;
  if (forced != null) return forced;
  for (final device in PlatformDispatcher.instance.locales) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == device.languageCode) return supported;
    }
  }
  return const Locale('en');
});

/// Localized strings for code without a [BuildContext].
final appStringsProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(effectiveLocaleProvider)),
);
