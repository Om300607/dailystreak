# DailyStreak 🔥

A dark-themed habit tracking app built with Flutter, letting users create, track, and analyze daily habits with streaks, a browsable calendar, and monthly/yearly stats.

## Features
- **Home screen**: animated, glowing circular progress ring, a week
  navigator (← Jump to Today →) so you can browse and toggle any
  previous day (future days are locked), and the habit list.
- **Add / Edit / Delete habits**: tap + to add a habit (name, emoji
  icon, color); tap the ⋮ menu on any habit card to edit or delete it
  (delete asks for confirmation first). Swipe-to-delete also works.
- **Calendar & Stats screen** (calendar icon, top right of Home): a
  "best active streak" banner up top, then switch between **Day**,
  **Month**, and **Year**:
  - *Day*: a full month calendar (amber-tinted by how many habits
    were completed each day) — tap any day to see its checklist.
  - *Month*: completion rate for the viewed month plus a per-habit
    progress bar.
  - *Year*: overall year completion rate and a month-by-month
    breakdown (tap a month to jump into its Month view).
- Per-habit Detail screen with its own monthly calendar and streak.
- Real streaks and stats are computed live from actual per-day
  completion history (not a fixed counter), so everything stays
  accurate as you toggle habits on any day.
- Clean, separated code structure (models / screens / widgets / theme).

## How to run
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. From this project folder, run:
   ```
   flutter pub get
   flutter run
   ```
3. To build an APK: `flutter build apk`

## Project structure
```
lib/
  theme/app_colors.dart            -> Midnight color palette (dark + amber)
  models/habit.dart                -> Habit model: per-day completion,
                                       streaks, and range stats
  screens/home_screen.dart         -> Home (progress ring, week nav, list)
  screens/add_habit_screen.dart    -> Add/Edit form (same screen, two modes)
  screens/habit_detail_screen.dart -> Per-habit monthly calendar + streak
  screens/calendar_stats_screen.dart -> Calendar & Stats (Day/Month/Year)
  widgets/habit_card.dart          -> Reusable habit row with edit/delete menu
  widgets/progress_ring.dart       -> Custom-painted circular progress
  widgets/date_strip.dart          -> Week navigator strip
```

## Notes
This is intentionally frontend-only: all habit data lives in memory
(owned by `HomeScreen`) and resets when the app restarts, as allowed
by the assignment brief. To persist data across restarts, add the
`shared_preferences` package and save/load the habit list as JSON.

---

## For the submission form
Use/adapt this for the "brief summary / features / tech stack" fields:

**Summary:** DailyStreak is a habit-tracking mobile app that lets
users create, edit, and delete daily habits, check them off for any
day, and explore their history through a calendar with Day, Month,
and Year stats views.

**Major features:** Animated circular daily-progress ring, week
navigator for browsing/editing past days, add/edit/delete habits with
emoji + color customization, a Calendar & Stats screen with Day/Month/
Year views (calendar heatmap, completion rate, per-habit progress,
best streak), per-habit monthly calendar with streak counter, dark
"Midnight" theme with an amber accent.

**Tech stack:** Flutter (Dart), Material 3, in-memory state
management (StatefulWidget/setState) — no backend, frontend-only per
assignment requirements.

**Why this stack:** Flutter gives a single codebase for cross-platform
mobile UI with strong built-in animation and custom-painting support
(used for the progress ring and calendar heatmap), which suited the
"clean UI/UX" and "creativity" grading criteria without needing native
platform code.
