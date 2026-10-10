import 'package:flutter/material.dart';
import 'package:pixel_quest/l10n/app_localizations.dart';

/// MaterialApp with the app's localization delegates, so widgets that call
/// `context.l10n` work in widget tests. Defaults to English.
Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
