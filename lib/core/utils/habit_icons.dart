import 'package:flutter/material.dart';

/// Icon names stored in `habits.icon_name`, mapped to Material icons.
abstract final class HabitIcons {
  static const Map<String, IconData> all = {
    'water_drop': Icons.water_drop_outlined,
    'fitness': Icons.fitness_center,
    'terminal': Icons.terminal,
    'book': Icons.menu_book_outlined,
    'zen': Icons.self_improvement,
    'target': Icons.track_changes,
  };

  static IconData of(String name) => all[name] ?? Icons.track_changes;
}
