import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/day_rollover_refresher.dart';
import 'features/onboarding/onboarding_gate.dart';
import 'data/database/app_database.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/account_providers.dart';
import 'providers/home_widget_providers.dart';
import 'providers/locale_providers.dart';
import 'providers/onboarding_providers.dart';
import 'providers/repository_providers.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initFirebase();
  await initializeHomeWidget();
  await initializeReminders();
  final db = await AppDatabase.open();
  final prefs = await SharedPreferences.getInstance();
  await markExistingUsersOnboarded(prefs, db);
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseAvailableProvider.overrideWithValue(firebaseReady),
      ],
      child: const PixelQuestApp(),
    ),
  );
}

/// Accounts and cloud sync need Firebase; without it (no network on first
/// launch is fine, but e.g. a broken config) the app still runs as a guest.
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e, st) {
    debugPrint('Firebase init failed, running guest-only: $e\n$st');
    return false;
  }
}

class PixelQuestApp extends ConsumerWidget {
  const PixelQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      // Null follows the device language (falls back to English).
      locale: ref.watch(appLanguageProvider).locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingGate(
        child: DayRolloverRefresher(child: AppShell()),
      ),
    );
  }
}
