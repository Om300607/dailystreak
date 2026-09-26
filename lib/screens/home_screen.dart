import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../widgets/progress_ring.dart';
import '../widgets/date_strip.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'calendar_stats_screen.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Builds a fake completion history for the last [days] days (not
/// including today) so the app has believable streaks and calendar
/// history to show off immediately, per the assignment's demo-data note.
Set<String> _demoHistory(int days) {
  final today = DateTime.now();
  return {
    for (int i = 1; i <= days; i++) Habit.keyFor(today.subtract(Duration(days: i)))
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Habit> _habits = [
    Habit(
      id: '1',
      name: 'Drink 2L Water',
      icon: '💧',
      color: Colors.blue,
      completedDates: _demoHistory(5),
    ),
    Habit(
      id: '2',
      name: 'Read 10 pages',
      icon: '📚',
      color: Colors.orange,
      completedDates: _demoHistory(3),
    ),
    Habit(
      id: '3',
      name: 'Exercise',
      icon: '🏃',
      color: Colors.green,
      completedDates: _demoHistory(7),
    ),
  ];

  DateTime _selectedDate = _dateOnly(DateTime.now());

  int get _completedCount =>
      _habits.where((h) => h.isCompletedOn(_selectedDate)).length;
  bool get _isFuture => _selectedDate.isAfter(_dateOnly(DateTime.now()));

  void _toggleHabit(Habit habit) {
    if (_isFuture) return;
    setState(() {
      habit.setCompleted(_selectedDate, !habit.isCompletedOn(_selectedDate));
    });
    if (_habits.isNotEmpty && _completedCount == _habits.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 All habits done for this day!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  void _deleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete habit?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('"${habit.name}" and its history will be removed.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _habits.removeWhere((h) => h.id == habit.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _addHabit() async {
    final newHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
    if (newHabit != null) {
      setState(() => _habits.add(newHabit));
    }
  }

  Future<void> _editHabit(Habit habit) async {
    await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (context) => AddHabitScreen(existingHabit: habit)),
    );
    setState(() {}); // habit was mutated in place; just refresh the UI
  }

  void _openDetail(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HabitDetailScreen(habit: habit)),
    );
  }

  Future<void> _openCalendarStats() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarStatsScreen(habits: _habits)),
    );
    setState(() {}); // in case a day was viewed after edits elsewhere
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _dateLabel() {
    final today = _dateOnly(DateTime.now());
    final diff = today.difference(_selectedDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const Text(
                          'DailyStreak',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Text(
                            _dateLabel(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _openCalendarStats,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: const Icon(Icons.calendar_month, size: 18, color: AppColors.amber),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ProgressRing(completed: _completedCount, total: _habits.length),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DateStrip(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = _dateOnly(d)),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _habits.isEmpty
                    ? const Center(
                        child: Text('No habits yet. Tap + to add one.',
                            style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 90),
                        itemCount: _habits.length,
                        itemBuilder: (context, index) {
                          final habit = _habits[index];
                          return Dismissible(
                            key: ValueKey(habit.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              _deleteHabit(habit);
                              return false; // deletion goes through the confirm dialog instead
                            },
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: HabitCard(
                              habit: habit,
                              completed: habit.isCompletedOn(_selectedDate),
                              streak: habit.streakEndingAt(_dateOnly(DateTime.now())),
                              locked: _isFuture,
                              onToggle: () => _toggleHabit(habit),
                              onTap: () => _openDetail(habit),
                              onEdit: () => _editHabit(habit),
                              onDelete: () => _deleteHabit(habit),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.amberGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addHabit,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppColors.amberDark),
        ),
      ),
    );
  }
}
