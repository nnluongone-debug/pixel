import 'package:flutter/material.dart';

/// Icon names stored in `habits.icon_name`, mapped to Material icons.
/// Names are persisted and synced, so existing keys must never change.
abstract final class HabitIcons {
  static const Map<String, IconData> all = {
    'water_drop': Icons.water_drop_outlined,
    'fitness': Icons.fitness_center,
    'terminal': Icons.terminal,
    'book': Icons.menu_book_outlined,
    'zen': Icons.self_improvement,
    'target': Icons.track_changes,
    'walk': Icons.directions_walk,
    'run': Icons.directions_run,
    'bike': Icons.directions_bike,
    'swim': Icons.pool,
    'sleep': Icons.bedtime_outlined,
    'pill': Icons.medication_outlined,
    'food': Icons.restaurant,
    'journal': Icons.edit_note,
    'heart': Icons.favorite_border,
    'sun': Icons.wb_sunny_outlined,
    'money': Icons.savings_outlined,
    'language': Icons.translate,
    'clean': Icons.cleaning_services_outlined,
    'phone_off': Icons.phone_disabled_outlined,
  };

  static IconData of(String name) => all[name] ?? Icons.track_changes;
}
