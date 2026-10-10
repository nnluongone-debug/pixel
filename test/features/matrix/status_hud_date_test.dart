import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pixel_quest/features/home/widgets/status_hud_card.dart';
import 'package:pixel_quest/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('vi');
  });

  final saturday = DateTime(2026, 10, 10);

  test('English HUD date is month first', () {
    expect(
      StatusHudCard.dateLabel(
        saturday,
        lookupAppLocalizations(const Locale('en')),
      ),
      'SAT, OCT 10',
    );
  });

  test('Vietnamese HUD date is day first, Sunday is CN', () {
    expect(
      StatusHudCard.dateLabel(
        DateTime(2026, 10, 11),
        lookupAppLocalizations(const Locale('vi')),
      ),
      'CN, 11 THG 10',
    );
    expect(
      StatusHudCard.dateLabel(
        saturday,
        lookupAppLocalizations(const Locale('vi')),
      ),
      'T7, 10 THG 10',
    );
  });
}
