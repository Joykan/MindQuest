/// lib/core/di/service_locator.dart
library;

import 'package:flutter/foundation.dart'; // ← Add this import for debugPrint
import 'package:get_it/get_it.dart';

import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/supabase_service.dart';
import '../services/analytics_service.dart';
import '../services/logger_service.dart';
import '../services/sync_service.dart';

final sl = GetIt.instance;

/// Initialize all dependencies with proper ordering and lazy loading
Future<void> setupServiceLocator() async {
  // 1. Core independent services
  sl.registerLazySingleton<LoggerService>(() => LoggerService());
  sl.registerLazySingleton<SupabaseService>(() => SupabaseService());
  sl.registerLazySingleton<GeminiService>(() => GeminiService());

  // 2. Repositories
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepository(
      supabaseService: sl<SupabaseService>(),
      logger: sl<LoggerService>(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(
      supabaseService: sl<SupabaseService>(),
      logger: sl<LoggerService>(),
    ),
  );

  // 3. Services that depend on repositories
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(
      moodRepository: sl<MoodRepository>(),
      logger: sl<LoggerService>(),
    ),
  );

  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      supabaseService: sl<SupabaseService>(),
      logger: sl<LoggerService>(),
    ),
  );

  debugPrint('✅ Service Locator initialized successfully (LazySingleton)');
}
