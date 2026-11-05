import '../../core/utils/search_text_normalizer.dart';
import '../../data/models/habit.dart';

/// A ready-made habit configuration suggested while the user types a title.
/// Names live here rather than in the ARB files because they are catalog
/// data matched against input in both languages.
class HabitTemplate {
  const HabitTemplate({
    required this.nameEn,
    required this.nameVi,
    required this.iconName,
    required this.colorHex,
    required this.type,
    this.unit = '',
    this.target = 1,
    this.schedule = HabitSchedule.daily,
  });

  final String nameEn;
  final String nameVi;
  final String iconName;
  final String colorHex;
  final HabitType type;

  /// Counter unit code (`PG`, `X`, `GL`); empty for timers and checklists.
  final String unit;
  final int target;
  final HabitSchedule schedule;

  String nameFor(String languageCode) => languageCode == 'vi' ? nameVi : nameEn;

  /// Match rank for a normalized [query]: 0 = a name starts with it,
  /// 1 = a word starts with it, 2 = contained, null = no match.
  int? rank(String query) {
    int? best;
    for (final name in [nameVi, nameEn]) {
      final n = SearchTextNormalizer.normalize(name);
      final r = n.startsWith(query)
          ? 0
          : n.contains(' $query')
          ? 1
          : n.contains(query)
          ? 2
          : null;
      if (r != null && (best == null || r < best)) best = r;
    }
    return best;
  }
}
