import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';

enum _ViewMode { day, month, year }

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// A calendar you can browse day-by-day, plus rolled-up stats for the
/// current month or year. All figures are derived live from each habit's
/// completedDates, so it always reflects reality with no stored duplicates.
class CalendarStatsScreen extends StatefulWidget {
  final List<Habit> habits;

  const CalendarStatsScreen({super.key, required this.habits});

  @override
  State<CalendarStatsScreen> createState() => _CalendarStatsScreenState();
}

class _CalendarStatsScreenState extends State<CalendarStatsScreen> {
  _ViewMode _mode = _ViewMode.day;
  late DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late DateTime _focusedMonth = DateTime(_today.year, _today.month);
  late DateTime _selectedDay = _today;
  late int _focusedYear = _today.year;

  bool get _isCurrentOrFutureMonth =>
      _focusedMonth.year == _today.year && _focusedMonth.month == _today.month;
  bool get _isCurrentYear => _focusedYear == _today.year;

  void _shiftMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  void _shiftYear(int delta) {
    setState(() => _focusedYear += delta);
  }

  Habit? get _bestHabit {
    if (widget.habits.isEmpty) return null;
    Habit best = widget.habits.first;
    int bestStreak = best.streakEndingAt(_today);
    for (final h in widget.habits.skip(1)) {
      final s = h.streakEndingAt(_today);
      if (s > bestStreak) {
        best = h;
        bestStreak = s;
      }
    }
    return bestStreak > 0 ? best : null;
  }

  @override
  Widget build(BuildContext context) {
    final best = _bestHabit;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Calendar & Stats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (best != null) _bestStreakBanner(best),
              const SizedBox(height: 16),
              _modeSwitcher(),
              const SizedBox(height: 18),
              if (_mode == _ViewMode.day) _dayView(),
              if (_mode == _ViewMode.month) _monthView(),
              if (_mode == _ViewMode.year) _yearView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bestStreakBanner(Habit habit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.amberGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(habit.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Best active streak: 🔥 ${habit.streakEndingAt(_today)} days — ${habit.name}',
              style: const TextStyle(
                  color: AppColors.amberDark, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitcher() {
    Widget seg(String label, _ViewMode mode) {
      final isSelected = _mode == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.amberGradient : null,
              color: isSelected ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? AppColors.amberDark : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        seg('Day', _ViewMode.day),
        seg('Month', _ViewMode.month),
        seg('Year', _ViewMode.year),
      ],
    );
  }

  // ---------------- DAY VIEW ----------------

  Widget _dayView() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final totalDays = _daysInMonth(_focusedMonth.year, _focusedMonth.month);
    final leadingBlanks = firstOfMonth.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onPressed: () => _shiftMonth(-1),
            ),
            Text(
              '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onPressed: _isCurrentOrFutureMonth ? null : () => _shiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + totalDays,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = DateTime(_focusedMonth.year, _focusedMonth.month, index - leadingBlanks + 1);
            final isFuture = day.isAfter(_today);
            final isSelected = day.year == _selectedDay.year &&
                day.month == _selectedDay.month &&
                day.day == _selectedDay.day;
            final completedCount =
                widget.habits.where((h) => h.isCompletedOn(day)).length;
            final total = widget.habits.length;
            final fraction = total == 0 ? 0.0 : completedCount / total;

            return GestureDetector(
              onTap: isFuture ? null : () => setState(() => _selectedDay = day),
              child: Opacity(
                opacity: isFuture ? 0.3 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fraction > 0
                        ? AppColors.amber.withOpacity(0.25 + 0.55 * fraction)
                        : AppColors.surface,
                    border: isSelected ? Border.all(color: AppColors.amber, width: 1.6) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: fraction > 0.5 ? AppColors.amberDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _daySummaryCard(),
      ],
    );
  }

  Widget _daySummaryCard() {
    final isFuture = _selectedDay.isAfter(_today);
    final isToday = _selectedDay == _today;
    final label = isToday
        ? 'Today'
        : '${_selectedDay.day} ${_monthNames[_selectedDay.month - 1]} ${_selectedDay.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (isFuture)
            const Text("This day hasn't happened yet.",
                style: TextStyle(color: AppColors.textMuted, fontSize: 13))
          else if (widget.habits.isEmpty)
            const Text('No habits to show.', style: TextStyle(color: AppColors.textMuted, fontSize: 13))
          else
            ...widget.habits.map((h) {
              final done = h.isCompletedOn(_selectedDay);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(h.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(h.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    ),
                    Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: done ? h.color : AppColors.textMuted,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ---------------- MONTH VIEW ----------------

  Widget _monthView() {
    final daysElapsed = _isCurrentOrFutureMonth
        ? _today.day
        : _daysInMonth(_focusedMonth.year, _focusedMonth.month);
    final monthStart = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final monthEnd = DateTime(_focusedMonth.year, _focusedMonth.month, daysElapsed);
    final totalPossible = widget.habits.length * daysElapsed;
    final totalCompleted = widget.habits.fold<int>(
        0, (sum, h) => sum + h.completedCountBetween(monthStart, monthEnd));
    final rate = totalPossible == 0 ? 0.0 : totalCompleted / totalPossible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onPressed: () => _shiftMonth(-1),
            ),
            Text(
              '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onPressed: _isCurrentOrFutureMonth ? null : () => _shiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard('Completion rate', '${(rate * 100).round()}%', '$totalCompleted of $totalPossible check-ins'),
        const SizedBox(height: 16),
        const Text('By habit', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ...widget.habits.map((h) {
          final count = h.completedCountBetween(monthStart, monthEnd);
          final frac = daysElapsed == 0 ? 0.0 : count / daysElapsed;
          return _habitProgressRow(h, count, daysElapsed, frac);
        }),
      ],
    );
  }

  // ---------------- YEAR VIEW ----------------

  Widget _yearView() {
    final lastMonthIndex = _isCurrentYear ? _today.month : 12;
    int totalCompleted = 0;
    int totalPossible = 0;

    final rows = <Widget>[];
    for (int m = 1; m <= 12; m++) {
      final isFutureMonth = m > lastMonthIndex;
      final daysElapsed = isFutureMonth
          ? 0
          : (m == lastMonthIndex && _isCurrentYear ? _today.day : _daysInMonth(_focusedYear, m));
      final monthStart = DateTime(_focusedYear, m, 1);
      final monthEnd = DateTime(_focusedYear, m, daysElapsed == 0 ? 1 : daysElapsed);
      final possible = widget.habits.length * daysElapsed;
      final completed = daysElapsed == 0
          ? 0
          : widget.habits.fold<int>(0, (sum, h) => sum + h.completedCountBetween(monthStart, monthEnd));
      totalPossible += possible;
      totalCompleted += completed;
      final frac = possible == 0 ? 0.0 : completed / possible;

      rows.add(GestureDetector(
        onTap: isFutureMonth
            ? null
            : () => setState(() {
                  _focusedMonth = DateTime(_focusedYear, m);
                  _mode = _ViewMode.month;
                }),
        child: Opacity(
          opacity: isFutureMonth ? 0.35 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 38, child: Text(_monthShort[m - 1],
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: frac,
                      minHeight: 10,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 38,
                  child: Text('${(frac * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    final overallRate = totalPossible == 0 ? 0.0 : totalCompleted / totalPossible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onPressed: () => _shiftYear(-1),
            ),
            Text('$_focusedYear',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onPressed: _isCurrentYear ? null : () => _shiftYear(1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard('Year completion rate', '${(overallRate * 100).round()}%',
            '$totalCompleted check-ins so far'),
        const SizedBox(height: 16),
        const Text('By month (tap to drill in)',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }

  // ---------------- SHARED PIECES ----------------

  Widget _statCard(String label, String value, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.amber, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _habitProgressRow(Habit h, int count, int daysElapsed, double frac) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(h.icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(h.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 10,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation(h.color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count/$daysElapsed', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
