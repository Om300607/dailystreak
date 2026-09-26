import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows the Mon-Sun week containing [selectedDate], with prev/next-week
/// arrows so the user can browse and select any previous day (future days
/// are locked, since you can't complete a habit ahead of time).
class DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final isCurrentWeek = !today.isBefore(startOfWeek) &&
        !today.isAfter(startOfWeek.add(const Duration(days: 6)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              tooltip: 'Previous week',
              onPressed: () =>
                  onDateSelected(selectedDate.subtract(const Duration(days: 7))),
            ),
            if (!isCurrentWeek)
              TextButton(
                onPressed: () => onDateSelected(today),
                child: const Text('Jump to Today',
                    style: TextStyle(color: AppColors.amber)),
              )
            else
              const SizedBox(height: 36),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              tooltip: 'Next week',
              onPressed: isCurrentWeek
                  ? null
                  : () => onDateSelected(selectedDate.add(const Duration(days: 7))),
            ),
          ],
        ),
        SizedBox(
          height: 66,
          child: Row(
            children: List.generate(7, (index) {
              final day = days[index];
              final isFuture = day.isAfter(today);
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              return Expanded(
                child: GestureDetector(
                  onTap: isFuture ? null : () => onDateSelected(day),
                  child: Opacity(
                    opacity: isFuture ? 0.35 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.amberGradient : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.amber, width: 1.5)
                            : Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? AppColors.amberDark
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.amberDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
