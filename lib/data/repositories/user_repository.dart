/// User Repository
///
/// Handles user profile and authentication data operations.
library;

import 'base_repository.dart';
import '../services/supabase_service.dart';
import '../../core/services/logger_service.dart';

class UserRepositoryException extends RepositoryException {
  UserRepositoryException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class UserRepository extends BaseRepository {
  final SupabaseService supabaseService;
  final LoggerService logger;

  UserRepository({
    required this.supabaseService,
    required this.logger,
  });

  @override
  Future<void> initialize() async {
    logger.info('Initializing UserRepository');
  }

  @override
  Future<void> dispose() async {
    logger.info('Disposed UserRepository');
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

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      logger.info('Fetching user profile: $userId');

      // Mock profile - replace with actual Supabase query
      return {
        'id': userId,
        'username': 'user_$userId',
        'display_name': 'User',
        'email': 'user@example.com',
        'language': 'en',
        'theme': 'system',
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e, st) {
      logger.error('Error fetching user profile', e, st);
      throw UserRepositoryException(
        message: 'Failed to fetch user profile',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      logger.info('Updating user profile: $userId');
      // Mock update
      logger.debug('Profile updates: $updates');
    } catch (e, st) {
      logger.error('Error updating user profile', e, st);
      throw UserRepositoryException(
        message: 'Failed to update user profile',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(
    String userId, {
    String? language,
    String? theme,
  }) async {
    try {
      logger.info('Updating user preferences for: $userId');

      final updates = <String, dynamic>{};
      if (language != null) updates['language'] = language;
      if (theme != null) updates['theme'] = theme;

      // Mock update
      logger.debug('Preference updates: $updates');
    } catch (e, st) {
      logger.error('Error updating user preferences', e, st);
      throw UserRepositoryException(
        message: 'Failed to update user preferences',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get user streaks
  Future<Map<String, int>> getUserStreaks(String userId) async {
    try {
      logger.info('Fetching user streaks: $userId');

      return {
        'currentStreak': 12,
        'longestStreak': 25,
        'totalDaysActive': 45,
      };
    } catch (e, st) {
      logger.error('Error fetching user streaks', e, st);
      throw UserRepositoryException(
        message: 'Failed to fetch user streaks',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get user badges
  Future<List<Map<String, dynamic>>> getUserBadges(String userId) async {
    try {
      logger.info('Fetching user badges: $userId');

      return [
        {
          'id': 'badge_1',
          'name': 'First Steps',
          'description': 'Completed first mood log',
          'icon': '🌟',
          'unlockedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'badge_2',
          'name': 'Week Warrior',
          'description': 'Logged mood for 7 consecutive days',
          'icon': '⚔️',
          'unlockedAt': DateTime.now().toIso8601String(),
        },
      ];
    } catch (e, st) {
      logger.error('Error fetching user badges', e, st);
      throw UserRepositoryException(
        message: 'Failed to fetch user badges',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      logger.warning('Deleting user account: $userId');
      // Mock deletion - in real implementation, this would cascade delete all user data
      logger.info('User account deleted: $userId');
    } catch (e, st) {
      logger.error('Error deleting user account', e, st);
      throw UserRepositoryException(
        message: 'Failed to delete user account',
        originalError: e,
        stackTrace: st,
      );
    }
  }
}
