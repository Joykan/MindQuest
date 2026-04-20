/// Use Cases for User Domain
///
/// Encapsulates business logic for user-related operations.
library;

import '../../data/repositories/user_repository.dart';
import '../../core/services/logger_service.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final UserRepository userRepository;
  final LoggerService logger;

  GetUserProfileUseCase({
    required this.userRepository,
    required this.logger,
  });

  Future<Map<String, dynamic>?> call(String userId) async {
    logger.info('GetUserProfileUseCase: Fetching profile for $userId');

    try {
      final profile = await userRepository.getUserProfile(userId);
      logger.info('Profile retrieved successfully');
      return profile;
    } catch (e, st) {
      logger.error('Error in GetUserProfileUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for updating user preferences
class UpdateUserPreferencesUseCase {
  final UserRepository userRepository;
  final LoggerService logger;

  UpdateUserPreferencesUseCase({
    required this.userRepository,
    required this.logger,
  });

  Future<void> call({
    required String userId,
    String? language,
    String? theme,
  }) async {
    logger.info('UpdateUserPreferencesUseCase: Updating prefs for $userId');

    try {
      // Validate inputs
      if (language != null && !['en', 'sw'].contains(language)) {
        throw ArgumentError('Invalid language: $language');
      }

      if (theme != null && !['light', 'dark', 'system'].contains(theme)) {
        throw ArgumentError('Invalid theme: $theme');
      }

      await userRepository.updateUserPreferences(
        userId,
        language: language,
        theme: theme,
      );

      logger.info('User preferences updated successfully');
    } catch (e, st) {
      logger.error('Error in UpdateUserPreferencesUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for getting user streaks
class GetUserStreaksUseCase {
  final UserRepository userRepository;
  final LoggerService logger;

  GetUserStreaksUseCase({
    required this.userRepository,
    required this.logger,
  });

  Future<Map<String, int>> call(String userId) async {
    logger.info('GetUserStreaksUseCase: Fetching streaks for $userId');

    try {
      final streaks = await userRepository.getUserStreaks(userId);
      logger.info('Streaks retrieved: $streaks');
      return streaks;
    } catch (e, st) {
      logger.error('Error in GetUserStreaksUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for getting user badges
class GetUserBadgesUseCase {
  final UserRepository userRepository;
  final LoggerService logger;

  GetUserBadgesUseCase({
    required this.userRepository,
    required this.logger,
  });

  Future<List<Map<String, dynamic>>> call(String userId) async {
    logger.info('GetUserBadgesUseCase: Fetching badges for $userId');

    try {
      final badges = await userRepository.getUserBadges(userId);
      logger.info('Retrieved ${badges.length} badges');
      return badges;
    } catch (e, st) {
      logger.error('Error in GetUserBadgesUseCase', e, st);
      rethrow;
    }
  }
}

/// Use case for deleting user account
class DeleteUserAccountUseCase {
  final UserRepository userRepository;
  final LoggerService logger;

  DeleteUserAccountUseCase({
    required this.userRepository,
    required this.logger,
  });

  Future<void> call(String userId) async {
    logger.warning(
      'DeleteUserAccountUseCase: Deleting account for $userId '
      '(this action is permanent)',
    );

    try {
      await userRepository.deleteUserAccount(userId);
      logger.warning('User account deleted: $userId');
    } catch (e, st) {
      logger.error('Error in DeleteUserAccountUseCase', e, st);
      rethrow;
    }
  }
}
