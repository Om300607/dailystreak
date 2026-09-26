import 'package:flutter/material.dart';

/// A single habit. Completion is tracked per calendar day (not just a single
/// "done today" flag), which is what lets the app show and edit history for
/// any previous day, and compute a real streak and period stats from it.
class Habit {
  String id;
  String name;
  String icon; // emoji used as the habit's icon
  Color color;
  Set<String> completedDates; // 'yyyy-MM-dd' keys

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? {};

  static String keyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isCompletedOn(DateTime date) => completedDates.contains(keyFor(date));

  void setCompleted(DateTime date, bool value) {
    final key = keyFor(date);
    if (value) {
      completedDates.add(key);
    } else {
      completedDates.remove(key);
    }
  }

  /// Number of consecutive completed days ending at [date] (inclusive),
  /// walking backwards through history.
  int streakEndingAt(DateTime date) {
    int streak = 0;
    DateTime cursor = DateTime(date.year, date.month, date.day);
    while (isCompletedOn(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Count of completed days within [start, end] inclusive. Powers the
  /// Month/Year stats views. Relies on the zero-padded 'yyyy-MM-dd' key
  /// format sorting the same as chronological order.
  int completedCountBetween(DateTime start, DateTime end) {
    final startKey = keyFor(start);
    final endKey = keyFor(end);
    return completedDates
        .where((k) => k.compareTo(startKey) >= 0 && k.compareTo(endKey) <= 0)
        .length;
  }
}
