import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_key_utils.dart';
import '../../domain/demo/love_pattern.dart';
import '../../domain/progression/streak_calculator.dart';
import '../../domain/progression/xp_rules.dart';
import '../models/habit.dart';
import '../repositories/user_stats_repository.dart';

/// Replaces the local data with a presentation demo: 25 daily habits whose
/// check-ins over the last 10 days stack into a 10x15 matrix spelling LOVE
/// (pink letter habits on dark background habits). Guest mode only — the
/// caller must not run it while an account is syncing.
class LoveDemoSeeder {
  LoveDemoSeeder(this._db, {Clock? clock, Uuid? uuid})
    : _clock = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid();

  static const letterColor = '#FF4D94';
  static const backgroundColor = '#323A52';

  final Database _db;
  final Clock _clock;
  final Uuid _uuid;

  static const _letterNames = {
    'vi': [
      'Nhắn chúc ngủ ngon',
      'Ôm người thương',
      'Nói lời yêu thương',
      'Nấu bữa tối cho nhau',
      'Viết thư tay',
      'Đi dạo cùng nhau',
      'Tặng một bông hoa',
      'Nghe chung bài hát',
      'Gọi video',
      'Cười thật nhiều',
    ],
    'en': [
      'Goodnight text',
      'Hug my person',
      'Say I love you',
      'Cook dinner together',
      'Write a love note',
      'Evening walk together',
      'Bring a flower',
      'Share a song',
      'Video call',
      'Laugh together',
    ],
  };

  static const _backgroundNames = {
    'vi': [
      'Uống nước',
      'Đọc sách',
      'Tập thể dục',
      'Thiền',
      'Ngủ sớm',
      'Ăn rau',
      'Đi bộ',
      'Học tiếng Anh',
      'Dọn phòng',
      'Viết nhật ký',
      'Bớt mạng xã hội',
      'Giãn cơ',
      'Tưới cây',
      'Lên kế hoạch ngày',
      'Uống vitamin',
    ],
    'en': [
      'Drink water',
      'Read',
      'Workout',
      'Meditate',
      'Sleep early',
      'Eat greens',
      'Walk',
      'Study English',
      'Tidy up',
      'Journal',
      'Less social media',
      'Stretch',
      'Water plants',
      'Plan the day',
      'Take vitamins',
    ],
  };

  static const _letterIcons = ['zen', 'target', 'book', 'water_drop', 'book'];
  static const _backgroundIcons = [
    'water_drop',
    'book',
    'fitness',
    'zen',
    'target',
    'terminal',
  ];

  /// Wipes habits, check-ins and the sync outbox, then writes the demo.
  Future<void> seed({required String lang}) async {
    final now = _clock();
    final today = DateKeys.epochDay(now);
    final firstDay = today - LovePattern.columns + 1;
    String key(String k) => _letterNames.containsKey(k) ? k : 'en';
    final letters = _habits(
      _letterNames[key(lang)]!,
      letterColor,
      _letterIcons,
      firstDay,
      hour: 8,
    );
    final background = _habits(
      _backgroundNames[key(lang)]!,
      backgroundColor,
      _backgroundIcons,
      firstDay,
      hour: 9,
    );

    await _db.transaction((txn) async {
      await txn.delete('check_ins');
      await txn.delete('habits');
      await txn.delete('sync_outbox');
      final todayKey = DateKeys.fromDate(now);
      final doneToday = <String>{};
      final activeDays = <String, Set<int>>{};
      final checkIns = <Map<String, Object?>>[];

      for (var column = 0; column < LovePattern.columns; column++) {
        final day = firstDay + column;
        final dateKey = DateKeys.shift(
          todayKey,
          column - LovePattern.columns + 1,
        );
        var nextLetter = 0;
        var nextBackground = 0;
        for (var slot = 0; slot < LovePattern.rows; slot++) {
          final habit = LovePattern.isLetter(column, slot)
              ? letters[nextLetter++]
              : background[nextBackground++];
          final days = activeDays.putIfAbsent(habit.id, () => {});
          final prior = StreakCalculator.streakBefore(days, day);
          days.add(day);
          if (day == today) doneToday.add(habit.id);
          checkIns.add({
            'id': _uuid.v4(),
            'habit_id': habit.id,
            'date': dateKey,
            'xp_earned': XpRules.xpForCheckIn(priorStreakDays: prior),
            'grid_x': day,
            'grid_y': slot,
            'updated_at': now.millisecondsSinceEpoch,
          });
        }
      }

      for (final habit in [...letters, ...background]) {
        await txn.insert('habits', {
          ...habit.toMap(),
          'current_progress': doneToday.contains(habit.id) ? 1 : 0,
          'progress_date': todayKey,
          'updated_at': now.millisecondsSinceEpoch,
        });
      }
      for (final row in checkIns) {
        await txn.insert('check_ins', row);
      }
      await UserStatsRepository(_db, clock: _clock).recalculate(txn, now: now);
    });
  }

  List<Habit> _habits(
    List<String> names,
    String color,
    List<String> icons,
    int firstDay, {
    required int hour,
  }) {
    final created = DateTime.fromMillisecondsSinceEpoch(
      firstDay * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return [
      for (var i = 0; i < names.length; i++)
        Habit(
          id: _uuid.v4(),
          name: names[i],
          type: HabitType.checklist,
          target: 1,
          currentProgress: 0,
          colorHex: color,
          iconName: icons[i % icons.length],
          createdAt: DateTime(
            created.year,
            created.month,
            created.day,
            hour,
            i,
          ),
        ),
    ];
  }
}
