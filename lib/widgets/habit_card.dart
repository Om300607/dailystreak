import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';

/// One row in the habit list, driven by whichever day is currently
/// selected on the home screen (not always "today"). [completed] and
/// [streak] are passed in already computed for that day, and [locked]
/// disables the checkbox for future dates. The trailing menu gives an
/// explicit, discoverable way to edit or delete a habit (in addition to
/// swipe-to-delete on the row).
class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool completed;
  final int streak;
  final bool locked;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.completed,
    required this.streak,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: completed
              ? habit.color.withOpacity(0.16)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed ? habit.color.withOpacity(0.4) : AppColors.border,
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: habit.color.withOpacity(0.22),
              child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                      color: completed
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🔥 $streak day streak',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (locked)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted),
              )
            else
              GestureDetector(
                onTap: onToggle,
                child: AnimatedScale(
                  scale: completed ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? habit.color : Colors.transparent,
                      border: Border.all(
                        color: completed ? habit.color : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Edit habit'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Delete habit', style: TextStyle(color: Colors.redAccent)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
