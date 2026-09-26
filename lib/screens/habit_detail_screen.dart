import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';

/// Shows a monthly calendar with completed days marked, plus the real
/// streak computed from the habit's actual completion history.
class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(first.year, first.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = _daysInMonth(now);
    final streak = habit.streakEndingAt(DateTime(now.year, now.month, now.day));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(habit.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: habit.color.withOpacity(0.22),
                      child: Text(habit.icon, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Streak', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '🔥 $streak Days',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('This Month',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final done = habit.isCompletedOn(day);
                    final isToday = day.day == now.day && day.month == now.month;
                    return Container(
                      decoration: BoxDecoration(
                        color: done ? habit.color.withOpacity(0.85) : AppColors.surface,
                        shape: BoxShape.circle,
                        border: isToday ? Border.all(color: AppColors.amber, width: 1.5) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: done ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
