import 'dart:ui';

import '../../../data/models/check_in.dart';

/// UI-ready brick for the pixel matrix: one completed habit on one day.
class CheckInBlock {
  const CheckInBlock({
    required this.id,
    required this.habitId,
    required this.dateKey,
    required this.stackIndex,
    required this.color,
  });

  factory CheckInBlock.fromCheckIn(CheckIn checkIn, Color color) {
    return CheckInBlock(
      id: checkIn.id,
      habitId: checkIn.habitId,
      dateKey: checkIn.date,
      stackIndex: checkIn.gridY,
      color: color,
    );
  }

  /// Stable identity; a new id appearing triggers the drop animation.
  final String id;
  final String habitId;

  /// `YYYY-MM-DD` day whose column this brick sits in.
  final String dateKey;

  /// Stacking order inside the day (0 = base). Only the order matters; the
  /// grid closes any gaps itself.
  final int stackIndex;
  final Color color;
}
