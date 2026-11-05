import '../../core/utils/search_text_normalizer.dart';
import '../../data/models/habit.dart';
import 'habit_template.dart';

/// Built-in habit presets offered as title suggestions in the editor.
abstract final class HabitTemplateCatalog {
  static const _mint = '#2DE38E';
  static const _cyan = '#00D2FF';
  static const _amber = '#F9CA24';
  static const _lavender = '#A29BFE';
  static const _rose = '#FF7675';
  static const _orange = '#FF9F43';
  static const _pink = '#FF4D94';

  static const _timer = HabitType.timer;
  static const _check = HabitType.checklist;
  static const _count = HabitType.counter;

  // ISO weekday bits: Monday = bit 0 … Sunday = bit 6.
  static const _monWedFri = HabitSchedule(0x15);
  static const _tueThuSat = HabitSchedule(0x2A);
  static const _monday = HabitSchedule(0x01);

  static const List<HabitTemplate> all = [
    // Sport
    HabitTemplate(
      nameEn: 'Walk',
      nameVi: 'Đi bộ',
      iconName: 'walk',
      colorHex: _mint,
      type: _timer,
      target: 30,
    ),
    HabitTemplate(
      nameEn: 'Run',
      nameVi: 'Chạy bộ',
      iconName: 'run',
      colorHex: _orange,
      type: _timer,
      target: 20,
    ),
    HabitTemplate(
      nameEn: 'Yoga',
      nameVi: 'Yoga',
      iconName: 'zen',
      colorHex: _lavender,
      type: _timer,
      target: 15,
    ),
    HabitTemplate(
      nameEn: 'Workout',
      nameVi: 'Tập thể dục',
      iconName: 'fitness',
      colorHex: _mint,
      type: _timer,
      target: 30,
    ),
    HabitTemplate(
      nameEn: 'Stretch',
      nameVi: 'Giãn cơ',
      iconName: 'zen',
      colorHex: _cyan,
      type: _timer,
      target: 10,
    ),
    HabitTemplate(
      nameEn: 'Swim',
      nameVi: 'Bơi',
      iconName: 'swim',
      colorHex: _cyan,
      type: _timer,
      target: 30,
      schedule: _tueThuSat,
    ),
    HabitTemplate(
      nameEn: 'Cycling',
      nameVi: 'Đạp xe',
      iconName: 'bike',
      colorHex: _orange,
      type: _timer,
      target: 30,
    ),
    HabitTemplate(
      nameEn: 'Dance',
      nameVi: 'Khiêu vũ',
      iconName: 'heart',
      colorHex: _pink,
      type: _timer,
      target: 20,
    ),
    HabitTemplate(
      nameEn: 'HIIT',
      nameVi: 'HIIT',
      iconName: 'fitness',
      colorHex: _rose,
      type: _timer,
      target: 15,
      schedule: _monWedFri,
    ),
    // Health
    HabitTemplate(
      nameEn: 'Drink water',
      nameVi: 'Uống nước',
      iconName: 'water_drop',
      colorHex: _cyan,
      type: _count,
      unit: 'GL',
      target: 8,
    ),
    HabitTemplate(
      nameEn: 'Take vitamins',
      nameVi: 'Uống vitamin',
      iconName: 'pill',
      colorHex: _amber,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Sleep early',
      nameVi: 'Ngủ sớm',
      iconName: 'sleep',
      colorHex: _lavender,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'No snacks',
      nameVi: 'Không ăn vặt',
      iconName: 'food',
      colorHex: _rose,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'No sugar',
      nameVi: 'Không đường',
      iconName: 'food',
      colorHex: _pink,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Weigh in',
      nameVi: 'Cân nặng',
      iconName: 'target',
      colorHex: _mint,
      type: _check,
      schedule: _monday,
    ),
    HabitTemplate(
      nameEn: 'Track calories',
      nameVi: 'Theo dõi calo',
      iconName: 'food',
      colorHex: _orange,
      type: _check,
    ),
    // Mind
    HabitTemplate(
      nameEn: 'Meditate',
      nameVi: 'Thiền',
      iconName: 'zen',
      colorHex: _lavender,
      type: _timer,
      target: 10,
    ),
    HabitTemplate(
      nameEn: 'Journal',
      nameVi: 'Viết nhật ký',
      iconName: 'journal',
      colorHex: _amber,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Read',
      nameVi: 'Đọc sách',
      iconName: 'book',
      colorHex: _amber,
      type: _count,
      unit: 'PG',
      target: 20,
    ),
    HabitTemplate(
      nameEn: 'Learn something new',
      nameVi: 'Học điều mới',
      iconName: 'terminal',
      colorHex: _cyan,
      type: _timer,
      target: 20,
    ),
    HabitTemplate(
      nameEn: 'Practice gratitude',
      nameVi: 'Thực hành biết ơn',
      iconName: 'heart',
      colorHex: _pink,
      type: _count,
      unit: 'X',
      target: 3,
    ),
    HabitTemplate(
      nameEn: 'Positive affirmations',
      nameVi: 'Khẳng định tích cực',
      iconName: 'sun',
      colorHex: _amber,
      type: _count,
      unit: 'X',
      target: 3,
    ),
    HabitTemplate(
      nameEn: 'No phone in the morning',
      nameVi: 'Không điện thoại buổi sáng',
      iconName: 'phone_off',
      colorHex: _rose,
      type: _check,
    ),
    // Lifestyle
    HabitTemplate(
      nameEn: 'Wake up early',
      nameVi: 'Dậy sớm',
      iconName: 'sun',
      colorHex: _orange,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Cold shower',
      nameVi: 'Tắm nước lạnh',
      iconName: 'water_drop',
      colorHex: _cyan,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Tidy your desk',
      nameVi: 'Dọn bàn làm việc',
      iconName: 'clean',
      colorHex: _mint,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Save money',
      nameVi: 'Tiết kiệm tiền',
      iconName: 'money',
      colorHex: _amber,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Cook at home',
      nameVi: 'Nấu ăn tại nhà',
      iconName: 'food',
      colorHex: _orange,
      type: _check,
    ),
    HabitTemplate(
      nameEn: 'Practice a language',
      nameVi: 'Luyện ngoại ngữ',
      iconName: 'language',
      colorHex: _lavender,
      type: _timer,
      target: 15,
    ),
    HabitTemplate(
      nameEn: 'No social media',
      nameVi: 'Không mạng xã hội',
      iconName: 'phone_off',
      colorHex: _pink,
      type: _check,
    ),
  ];

  /// Up to [limit] templates matching [input], best rank first. Empty input
  /// or an input that is literally a template name yields nothing.
  static List<HabitTemplate> suggest(String input, {int limit = 4}) {
    final query = SearchTextNormalizer.normalize(input);
    if (query.isEmpty) return const [];
    final ranked = <(int, int, HabitTemplate)>[];
    for (final (index, template) in all.indexed) {
      // Only the literal name (as a pick leaves it) hides the list, so a
      // typed "uong nuoc" still offers the preset.
      final exact = [template.nameVi, template.nameEn].contains(input.trim());
      if (exact) return const [];
      final r = template.rank(query);
      if (r != null) ranked.add((r, index, template));
    }
    ranked.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [for (final (_, _, t) in ranked.take(limit)) t];
  }
}
