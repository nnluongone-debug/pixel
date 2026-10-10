import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/domain/analytics/check_in_record.dart';

/// 2026-10-10, a Saturday.
final DateTime today = DateTime(2026, 10, 10);
final int todayEpoch = DateKeys.epochDay(today);

Habit makeHabit(
  String id, {
  DateTime? created,
  HabitSchedule schedule = HabitSchedule.daily,
  HabitType type = HabitType.checklist,
  int target = 1,
  String unit = '',
}) => Habit(
  id: id,
  name: 'Habit $id',
  type: type,
  target: target,
  currentProgress: 0,
  colorHex: '#2DE38E',
  iconName: 'target',
  createdAt: created ?? DateTime(2026, 1, 1),
  unit: unit,
  schedule: schedule,
);

CheckInRecord record(String habitId, int epochDay, {int xp = 25}) =>
    CheckInRecord(habitId: habitId, epochDay: epochDay, xp: xp);

/// One record per day in `todayEpoch - offsets` for [habitId].
List<CheckInRecord> daysAgo(String habitId, Iterable<int> offsets) => [
  for (final o in offsets) record(habitId, todayEpoch - o),
];
