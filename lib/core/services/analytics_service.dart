/// Advanced Analytics Service
///
/// Provides mood analytics, trend analysis, pattern detection,
/// and predictive insights for user dashboard.
library;

import 'package:intl/intl.dart';
import '../services/logger_service.dart';

class MoodStatistic {
  final DateTime date;
  final int moodValue;
  final int energyLevel;
  final String? note;
  final List<String>? tags;

  MoodStatistic({
    required this.date,
    required this.moodValue,
    required this.energyLevel,
    this.note,
    this.tags,
  });
}

class MoodTrend {
  final String period; // 'week', 'month', 'all'
  final double averageMood;
  final double averageEnergy;
  final int totalMoodsLogged;
  final int bestDay;
  final int worstDay;
  final List<DailyMoodAggregate> dailyData;
  final String trend; // 'improving', 'declining', 'stable'
  final String? insight;

  MoodTrend({
    required this.period,
    required this.averageMood,
    required this.averageEnergy,
    required this.totalMoodsLogged,
    required this.bestDay,
    required this.worstDay,
    required this.dailyData,
    required this.trend,
    this.insight,
  });
}

class DailyMoodAggregate {
  final DateTime date;
  final double averageMood;
  final double averageEnergy;
  final int entryCount;
  final String dominantMood; // emoji

  DailyMoodAggregate({
    required this.date,
    required this.averageMood,
    required this.averageEnergy,
    required this.entryCount,
    required this.dominantMood,
  });
}

class MoodPattern {
  final String name;
  final String description;
  final List<String> relatedTags;
  final double frequency; // 0-1
  final String recommendation;

  MoodPattern({
    required this.name,
    required this.description,
    required this.relatedTags,
    required this.frequency,
    required this.recommendation,
  });
}

class AnalyticsService {
  final dynamic moodRepository; // MoodRepository
  final LoggerService logger;

  AnalyticsService({
    required this.moodRepository,
    required this.logger,
  });

  /// Analyze mood trends over a time period
  Future<MoodTrend> analyzeMoodTrend({
    required String period, // 'week', 'month', 'all'
    required String userId,
  }) async {
    try {
      logger.info('Analyzing mood trends for period: $period');

      final now = DateTime.now();
      late DateTime startDate;

      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = DateTime(2020); // All time
      }

      // Mock data for demonstration - replace with actual repository call
      final mockMoods = _generateMockMoodData(startDate, now);

      final averageMood = mockMoods.isEmpty
          ? 3.0
          : (mockMoods.map((e) => e.moodValue).reduce((a, b) => a + b) /
                  mockMoods.length)
              .toDouble();

      final averageEnergy = mockMoods.isEmpty
          ? 3.0
          : (mockMoods.map((e) => e.energyLevel).reduce((a, b) => a + b) /
                  mockMoods.length)
              .toDouble();

      final bestDay =
          mockMoods.map((e) => e.moodValue).fold(0, (p, e) => p > e ? p : e);
      final worstDay =
          mockMoods.map((e) => e.moodValue).fold(5, (p, e) => p < e ? p : e);

      // Group by day
      final dailyData = _aggregateDailyMoods(mockMoods);

      // Determine trend
      final trend = _calculateTrend(dailyData);

      // Generate insight
      final insight = _generateInsight(averageMood, trend, mockMoods);

      return MoodTrend(
        period: period,
        averageMood: averageMood,
        averageEnergy: averageEnergy,
        totalMoodsLogged: mockMoods.length,
        bestDay: bestDay,
        worstDay: worstDay,
        dailyData: dailyData,
        trend: trend,
        insight: insight,
      );
    } catch (e, st) {
      logger.error('Error analyzing mood trends', e, st);
      rethrow;
    }
  }

  /// Detect mood patterns and triggers
  Future<List<MoodPattern>> detectMoodPatterns({
    required String userId,
  }) async {
    try {
      logger.info('Detecting mood patterns for user: $userId');

      // Mock pattern detection
      return [
        MoodPattern(
          name: 'Monday Blues',
          description: 'Lower mood typically on Mondays',
          relatedTags: ['Work', 'Stress', 'School'],
          frequency: 0.65,
          recommendation:
              'Try engaging in a fun activity on Monday mornings to boost your mood.',
        ),
        MoodPattern(
          name: 'Weekend Relief',
          description: 'Mood significantly improves on weekends',
          relatedTags: ['Relationships', 'Health', 'Sleep'],
          frequency: 0.78,
          recommendation:
              'Maintain weekend activities during the week to sustain positive mood.',
        ),
        MoodPattern(
          name: 'Sleep Correlation',
          description: 'Poor sleep correlates with lower mood',
          relatedTags: ['Sleep', 'Health', 'Stress'],
          frequency: 0.82,
          recommendation:
              'Focus on improving sleep quality. Try a consistent sleep schedule.',
        ),
      ];
    } catch (e, st) {
      logger.error('Error detecting mood patterns', e, st);
      rethrow;
    }
  }

  /// Predict future mood based on patterns
  Future<Map<String, double>> predictMoodTrend({
    required String userId,
    int daysAhead = 7,
  }) async {
    try {
      logger.info('Predicting mood for next $daysAhead days');

      // Mock prediction
      final predictions = <String, double>{};
      for (int i = 1; i <= daysAhead; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final formatter = DateFormat('yyyy-MM-dd');
        predictions[formatter.format(date)] = 2.5 + (i * 0.2) % 2;
      }
      return predictions;
    } catch (e, st) {
      logger.error('Error predicting mood trend', e, st);
      rethrow;
    }
  }

  /// Get mood statistics for a user
  Future<Map<String, dynamic>> getUserMoodStats({
    required String userId,
  }) async {
    try {
      return {
        'totalMoodsLogged': 45,
        'currentStreak': 12,
        'longestStreak': 25,
        'averageMood': 3.2,
        'averageEnergy': 3.5,
        'mostCommonMood': '😊',
        'moodDistribution': {
          '1': 2,
          '2': 5,
          '3': 15,
          '4': 18,
          '5': 5,
        },
      };
    } catch (e, st) {
      logger.error('Error getting user mood stats', e, st);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────

  List<MoodStatistic> _generateMockMoodData(DateTime start, DateTime end) {
    final moods = <MoodStatistic>[];
    for (var i = 0; i < end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      final mood = (2 + (i.hashCode % 3)).clamp(1, 5);
      moods.add(
        MoodStatistic(
          date: date,
          moodValue: mood,
          energyLevel: (3 + (i.hashCode % 2)).clamp(1, 5),
          note: 'Sample mood entry',
          tags: ['Work', 'School'].where((t) => date.weekday <= 5).toList(),
        ),
      );
    }
    return moods;
  }

  List<DailyMoodAggregate> _aggregateDailyMoods(
    List<MoodStatistic> moods,
  ) {
    final groupedByDay = <DateTime, List<MoodStatistic>>{};

    for (final mood in moods) {
      final dayKey = DateTime(mood.date.year, mood.date.month, mood.date.day);
      groupedByDay.putIfAbsent(dayKey, () => []).add(mood);
    }

    return groupedByDay.entries
        .map((entry) {
          final dailyMoods = entry.value;
          final avgMood =
              dailyMoods.map((m) => m.moodValue).reduce((a, b) => a + b) /
                  dailyMoods.length;
          final avgEnergy =
              dailyMoods.map((m) => m.energyLevel).reduce((a, b) => a + b) /
                  dailyMoods.length;

          return DailyMoodAggregate(
            date: entry.key,
            averageMood: avgMood,
            averageEnergy: avgEnergy,
            entryCount: dailyMoods.length,
            dominantMood: _getMoodEmoji(avgMood.toInt()),
          );
        })
        .toList()
        .reversed
        .toList();
  }

  String _calculateTrend(List<DailyMoodAggregate> dailyData) {
    if (dailyData.length < 3) return 'stable';

    final recent = dailyData.take(3).map((d) => d.averageMood).toList();
    final earlier =
        dailyData.skip(3).take(3).map((d) => d.averageMood).toList();

    if (earlier.isEmpty) return 'stable';

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;

    if (recentAvg > earlierAvg + 0.5) return 'improving';
    if (recentAvg < earlierAvg - 0.5) return 'declining';
    return 'stable';
  }

  String? _generateInsight(
    double averageMood,
    String trend,
    List<MoodStatistic> moods,
  ) {
    if (averageMood >= 4) {
      return 'You\'re in great spirits! Keep up the positive momentum.';
    } else if (averageMood >= 3) {
      return 'Your mood is balanced. Looking into patterns might help optimization.';
    } else if (trend == 'declining') {
      return 'We notice a downward trend. Consider reaching out for support.';
    } else if (trend == 'improving') {
      return 'Great! Your mood is trending upward. Keep doing what helps!';
    }
    return null;
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }
}
