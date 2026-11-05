import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/core/utils/habit_icons.dart';
import 'package:pixel_quest/core/utils/search_text_normalizer.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/domain/templates/habit_template_catalog.dart';
import 'package:pixel_quest/features/habit_editor/habit_draft.dart';

void main() {
  test('normalizer folds Vietnamese diacritics and case', () {
    expect(SearchTextNormalizer.normalize('  Uống   NƯỚC '), 'uong nuoc');
    expect(SearchTextNormalizer.normalize('Đạp xe'), 'dap xe');
    expect(SearchTextNormalizer.normalize('U\u031Bo\u0301ng'), 'uong');
  });

  test('suggests by accent-free prefix in either language', () {
    final vi = HabitTemplateCatalog.suggest('doc');
    expect(vi.first.nameVi, 'Đọc sách');
    final en = HabitTemplateCatalog.suggest('Med');
    expect(en.first.nameEn, 'Meditate');
  });

  test('prefix matches rank before word and substring matches', () {
    final names = HabitTemplateCatalog.suggest(
      'khong',
      limit: 10,
    ).map((t) => t.nameVi);
    expect(names, everyElement(startsWith('Không')));
  });

  test('empty, unknown or exact input yields nothing', () {
    expect(HabitTemplateCatalog.suggest(''), isEmpty);
    expect(HabitTemplateCatalog.suggest('zzqx'), isEmpty);
    expect(HabitTemplateCatalog.suggest('Uống nước'), isEmpty);
    expect(HabitTemplateCatalog.suggest('uong nuoc').first.nameVi, 'Uống nước');
  });

  test('respects the limit', () {
    expect(HabitTemplateCatalog.suggest('a', limit: 3), hasLength(3));
  });

  test('every template uses a known icon and a valid quota', () {
    for (final t in HabitTemplateCatalog.all) {
      expect(HabitIcons.all, contains(t.iconName), reason: t.nameEn);
      expect(t.target, greaterThan(0), reason: t.nameEn);
      expect(t.schedule.isValid, isTrue, reason: t.nameEn);
      if (t.type == HabitType.counter) expect(t.unit, isNotEmpty);
    }
  });

  test('withTemplate fills the draft and keeps reminders', () {
    final swim = HabitTemplateCatalog.all.firstWhere((t) => t.nameEn == 'Swim');
    const base = HabitDraft(remindersOn: true, reminderTimes: [480]);
    final d = base.withTemplate(swim, 'vi');
    expect(d.name, 'Bơi');
    expect(d.iconName, 'swim');
    expect(d.type, HabitType.timer);
    expect(d.target, 30);
    expect(d.cadence, HabitCadence.custom);
    expect(d.customDays, {
      DateTime.tuesday,
      DateTime.thursday,
      DateTime.saturday,
    });
    expect(d.remindersOn, isTrue);
    expect(d.reminderTimes, [480]);
  });
}
