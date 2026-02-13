import 'package:intl/intl.dart';

class StreakService {
  int streak = 0;
  String? lastPlayedDate;

  void updateStreak() {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    if (lastPlayedDate == null) {
      streak = 1;
    } else {
      final last = DateTime.parse(lastPlayedDate!);
      final diff = DateTime.now().difference(last).inDays;

      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    lastPlayedDate = today;
  }
}
