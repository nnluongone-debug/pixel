import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension AppL10n on BuildContext {
  /// Localized strings for the current locale (`app_en.arb`, `app_vi.arb`).
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Language tag for `intl` formatters, e.g. `DateFormat('EEE', tag)`.
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}
