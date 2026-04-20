/// Mood Repository
///
/// Handles all mood-related data operations with caching
/// and offline support.
library;

import 'base_repository.dart';
import '../services/supabase_service.dart';
import '../../core/services/logger_service.dart';

class MoodLog {
  final String id;
  final String userId;
  final DateTime date;
  final int moodValue;
  final String moodLabel;
  final int energyLevel;
  final String? note;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodValue,
    required this.moodLabel,
    required this.energyLevel,
    this.note,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      moodValue: json['mood_value'] as int,
      moodLabel: json['mood_label'] as String,
      energyLevel: json['energy_level'] as int,
      note: json['note'] as String?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'mood_value': moodValue,
        'mood_label': moodLabel,
        'energy_level': energyLevel,
        'note': note,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class MoodRepository extends BaseRepository {
  final SupabaseService supabaseService;
  final LoggerService logger;

  // Cache
  final Map<String, MoodLog> _cache = {};

  MoodRepository({
    required this.supabaseService,
    required this.logger,
  });

  @override
  Future<void> initialize() async {
    logger.info('Initializing MoodRepository');
  }

  @override
  Future<void> dispose() async {
    _cache.clear();
    logger.info('Disposed MoodRepository');
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Mock availability check
      return true;
    } catch (e) {
      logger.error('Error checking availability', e);
      return false;
    }
  }

  /// Get all mood logs for a user
  Future<List<MoodLog>> getMoodLogsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = 'moods_$userId';

      // Return cached data if available and not forced refresh
      if (!forceRefresh && _cache.containsKey(cacheKey)) {
        logger.debug('Returning cached mood logs for $userId');
        return _cache[cacheKey]! as List<MoodLog>;
      }

      logger.info('Fetching mood logs for user: $userId');

      // Mock data - replace with actual Supabase query
      final mockLogs = _generateMockMoodLogs(userId);

      _cache[cacheKey] = mockLogs as dynamic;

      return mockLogs;
    } catch (e, st) {
      logger.error('Error fetching mood logs', e, st);
      throw RepositoryException(
        message: 'Failed to fetch mood logs',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get mood log by ID
  Future<MoodLog?> getMoodLogById(String id) async {
    try {
      // Check cache first
      if (_cache.containsKey('mood_$id')) {
        return _cache['mood_$id'] as MoodLog;
      }

      logger.info('Fetching mood log: $id');

      // Mock fetch
      final mockLog = MoodLog(
        id: id,
        userId: 'user_123',
        date: DateTime.now(),
        moodValue: 4,
        moodLabel: 'Happy',
        energyLevel: 3,
        note: 'Great day today!',
        tags: ['Work', 'Relationships'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _cache['mood_$id'] = mockLog;
      return mockLog;
    } catch (e, st) {
      logger.error('Error fetching mood log', e, st);
      return null;
    }
  }

  /// Save mood log
  Future<MoodLog> saveMoodLog({
    required String userId,
    required int moodValue,
    required String moodLabel,
    required int energyLevel,
    String? note,
    List<String>? tags,
  }) async {
    try {
      logger.info('Saving mood log for user: $userId');

      final newMood = MoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: DateTime.now(),
        moodValue: moodValue,
        moodLabel: moodLabel,
        energyLevel: energyLevel,
        note: note,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Clear related cache
      _cache.remove('moods_$userId');

      logger.info('Mood log saved successfully: ${newMood.id}');
      return newMood;
    } catch (e, st) {
      logger.error('Error saving mood log', e, st);
      throw RepositoryException(
        message: 'Failed to save mood log',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete mood log
  Future<void> deleteMoodLog(String moodId) async {
    try {
      logger.info('Deleting mood log: $moodId');
      // Mock delete
      _cache.remove('mood_$moodId');
    } catch (e, st) {
      logger.error('Error deleting mood log', e, st);
      throw RepositoryException(
        message: 'Failed to delete mood log',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get mood statistics
  Future<Map<String, dynamic>> getMoodStatistics(String userId) async {
    try {
      logger.info('Fetching mood statistics for user: $userId');

      return {
        'totalMoodsLogged': 45,
        'averageMood': 3.4,
        'bestDay': 5,
        'worstDay': 1,
        'currentStreak': 12,
      };
    } catch (e, st) {
      logger.error('Error fetching mood statistics', e, st);
      throw RepositoryException(
        message: 'Failed to fetch mood statistics',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    logger.info('MoodRepository cache cleared');
  }

  // ─────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────

  List<MoodLog> _generateMockMoodLogs(String userId) {
    final logs = <MoodLog>[];
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      logs.add(
        MoodLog(
          id: 'mood_$i',
          userId: userId,
          date: date,
          moodValue: 2 + (i.hashCode % 4),
          moodLabel: [
            'Sad',
            'Bad',
            'Okay',
            'Happy',
            'Great'
          ][(2 + (i.hashCode % 4))],
          energyLevel: 2 + (i.hashCode % 4),
          note: 'Sample mood entry',
          tags: ['Work', 'School'].where((t) => date.weekday <= 5).toList(),
          createdAt: date,
          updatedAt: date,
        ),
      );
    }
    return logs;
  }
}
