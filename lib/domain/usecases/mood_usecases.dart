/// Use Cases for Mood Domain
///
/// Encapsulates business logic for mood-related operations.
/// Use cases are independent of UI and can be tested independently.
library;

import '../../data/repositories/mood_repository.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/analytics_service.dart';

/// Use case for logging a mood
class LogMoodUseCase {
  final MoodRepository moodRepository;
  final LoggerService logger;

  LogMoodUseCase({
    required this.moodRepository,
    required this.logger,
  });

  Future<MoodLog> call({
    required String userId,
    required int moodValue,
    required String moodLabel,
    required int energyLevel,
    String? note,
    List<String>? tags,
  }) async {
    logger.info('LogMoodUseCase: Logging mood for user $userId');

    try {
      // Validate inputs
      if (moodValue < 1 || moodValue > 5) {
        throw ArgumentError('Mood value must be between 1 and 5');
      }

      if (energyLevel < 1 || energyLevel > 5) {
        throw ArgumentError('Energy level must be between 1 and 5');
      }

      // Save mood log
      final moodLog = await moodRepository.saveMoodLog(
        userId: userId,
        moodValue: moodValue,
        moodLabel: moodLabel,
        energyLevel: energyLevel,
        note: note,
        tags: tags,
      );

      logger.info('Mood logged successfully: ${moodLog.id}');
      return moodLog;
    } catch (e, st) {
      logger.error('Error in LogMoodUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for retrieving mood history
class GetMoodHistoryUseCase {
  final MoodRepository moodRepository;
  final LoggerService logger;

  GetMoodHistoryUseCase({
    required this.moodRepository,
    required this.logger,
  });

  Future<List<MoodLog>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    logger.info('GetMoodHistoryUseCase: Fetching history for $userId');

    try {
      final logs = await moodRepository.getMoodLogsForUser(
        userId,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );

      logger.info('Retrieved ${logs.length} mood logs');
      return logs;
    } catch (e, st) {
      logger.error('Error in GetMoodHistoryUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for analyzing mood trends
class AnalyzeMoodTrendsUseCase {
  final AnalyticsService analyticsService;
  final LoggerService logger;

  AnalyzeMoodTrendsUseCase({
    required this.analyticsService,
    required this.logger,
  });

  Future<MoodTrend> call({
    required String userId,
    required String period, // 'week', 'month', 'all'
  }) async {
    logger
        .info('AnalyzeMoodTrendsUseCase: Analyzing trends for period: $period');

    try {
      final trend = await analyticsService.analyzeMoodTrend(
        period: period,
        userId: userId,
      );

      logger.info(
        'Trend analysis complete. Average mood: ${trend.averageMood.toStringAsFixed(2)}',
      );
      return trend;
    } catch (e, st) {
      logger.error('Error in AnalyzeMoodTrendsUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for getting mood statistics
class GetMoodStatsUseCase {
  final MoodRepository moodRepository;
  final LoggerService logger;

  GetMoodStatsUseCase({
    required this.moodRepository,
    required this.logger,
  });

  Future<Map<String, dynamic>> call(String userId) async {
    logger.info('GetMoodStatsUseCase: Getting stats for $userId');

    try {
      final stats = await moodRepository.getMoodStatistics(userId);
      logger.info('Stats retrieved: $stats');
      return stats;
    } catch (e, st) {
      logger.error('Error in GetMoodStatsUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for detecting mood patterns
class DetectMoodPatternsUseCase {
  final AnalyticsService analyticsService;
  final LoggerService logger;

  DetectMoodPatternsUseCase({
    required this.analyticsService,
    required this.logger,
  });

  Future<List<MoodPattern>> call(String userId) async {
    logger.info('DetectMoodPatternsUseCase: Detecting patterns for $userId');

    try {
      final patterns =
          await analyticsService.detectMoodPatterns(userId: userId);
      logger.info('Detected ${patterns.length} mood patterns');
      return patterns;
    } catch (e, st) {
      logger.error('Error in DetectMoodPatternsUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for predicting future mood
class PredictMoodUseCase {
  final AnalyticsService analyticsService;
  final LoggerService logger;

  PredictMoodUseCase({
    required this.analyticsService,
    required this.logger,
  });

  Future<Map<String, double>> call({
    required String userId,
    int daysAhead = 7,
  }) async {
    logger.info(
      'PredictMoodUseCase: Predicting mood for next $daysAhead days',
    );

    try {
      final predictions = await analyticsService.predictMoodTrend(
        userId: userId,
        daysAhead: daysAhead,
      );
      logger.info('Mood prediction complete');
      return predictions;
    } catch (e, st) {
      logger.error('Error in PredictMoodUseCase', e, st);
      rethrow;
    }
  }
}
