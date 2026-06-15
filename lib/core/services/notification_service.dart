// lib/core/services/notification_service.dart
// ignore_for_file: deprecated_member_use

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handles local push notifications for mood reminders, streak nudges,
/// and general engagement prompts. Works on Android, iOS, and web.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Must be called once at app startup (e.g. in main.dart).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+ and iOS
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        }
      } catch (_) {
        // Platform detection might throw on web
      }
    }

    debugPrint('✅ NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Deep-linking could be handled here via GoRouter
  }

  // ── Notification channels ─────────────────────────────────

  static const _moodChannel = AndroidNotificationDetails(
    'mindquest_mood_reminders',
    'Mood Reminders',
    channelDescription: 'Reminds you to log your mood throughout the day',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _streakChannel = AndroidNotificationDetails(
    'mindquest_streak',
    'Streak Reminders',
    channelDescription: 'Keeps your streak alive with daily nudges',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _engagementChannel = AndroidNotificationDetails(
    'mindquest_engagement',
    'MindQuest Updates',
    channelDescription: 'Tips, badges, and wellness nudges',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
  );

  // ── Schedule daily mood reminder ──────────────────────────

  /// Schedule a daily mood check-in reminder at the specified hour.
  /// Default is 9 AM.
  Future<void> scheduleDailyMoodReminder({
    int hour = 9,
    int minute = 0,
    String lang = 'en',
  }) async {
    if (kIsWeb) return; // Local notifications not supported on web

    final title = lang == 'sw'
        ? '🌟 Habari! Unajisikiaje?'
        : '🌟 Hey! How are you feeling?';
    final body = lang == 'sw'
        ? 'Chukua dakika moja kurekodi hisia zako na kupata XP! 🎯'
        : 'Take a minute to log your mood and earn XP! 🎯';

    await _notifications.zonedSchedule(
      100, // Unique ID for daily mood reminder
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: _moodChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'mood_reminder',
    );

    debugPrint('📅 Mood reminder scheduled for $hour:$minute daily');
  }

  /// Schedule an evening reflection reminder at the specified hour.
  /// Default is 8 PM.
  Future<void> scheduleEveningReflection({
    int hour = 20,
    int minute = 0,
    String lang = 'en',
  }) async {
    if (kIsWeb) return;

    final title = lang == 'sw'
        ? '🌙 Muda wa Kutafakari'
        : '🌙 Time to Reflect';
    final body = lang == 'sw'
        ? 'Jinsi gani siku yako imekuwa? Zungumza na MindQuest AI 💬'
        : 'How was your day? Chat with MindQuest AI 💬';

    await _notifications.zonedSchedule(
      101, // Unique ID for evening reflection
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: _moodChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening_reflection',
    );

    debugPrint('📅 Evening reflection scheduled for $hour:$minute daily');
  }

  // ── Streak reminder ────────────────────────────────────────

  /// Schedule a streak reminder at 7 PM if user hasn't logged today.
  Future<void> scheduleStreakReminder({
    int hour = 19,
    int minute = 0,
    String lang = 'en',
  }) async {
    if (kIsWeb) return;

    final title = lang == 'sw'
        ? '🔥 Usipoteze Msururu Wako!'
        : '🔥 Don\'t Break Your Streak!';
    final body = lang == 'sw'
        ? 'Bado hujarekodia hisia zako leo. Fanya check-in na upate XP! ⚡'
        : 'You haven\'t logged your mood today. Check in and earn XP! ⚡';

    await _notifications.zonedSchedule(
      102,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: _streakChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'streak_reminder',
    );

    debugPrint('📅 Streak reminder scheduled for $hour:$minute daily');
  }

  // ── Instant notifications ─────────────────────────────────

  /// Show an instant notification (e.g. badge earned, level up).
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: _engagementChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Show a level-up notification.
  Future<void> showLevelUpNotification({
    required int newLevel,
    required String newTier,
    String lang = 'en',
  }) async {
    final title = lang == 'sw'
        ? '🎉 Ngazi Mpya! Level $newLevel'
        : '🎉 Level Up! Level $newLevel';
    final body = lang == 'sw'
        ? 'Umefika ngazi ya $newTier! Endelea kuendelea! 🌟'
        : 'You\'re now a $newTier! Keep going! 🌟';

    await showInstantNotification(title: title, body: body, payload: 'level_up');
  }

  /// Show a badge earned notification.
  Future<void> showBadgeEarnedNotification({
    required String badgeName,
    String lang = 'en',
  }) async {
    final title = lang == 'sw'
        ? '🏅 Tuzo Mpya: $badgeName'
        : '🏅 New Badge: $badgeName';
    final body = lang == 'sw'
        ? 'Hongera! Umepata tuzo mpya! Angalia ukurasa wako 🌟'
        : 'Congratulations! Check out your new badge! 🌟';

    await showInstantNotification(
        title: title, body: body, payload: 'badge_earned');
  }

  // ── Schedule all default reminders ─────────────────────────

  /// Schedule all default reminder notifications.
  Future<void> scheduleAllReminders({String lang = 'en'}) async {
    await scheduleDailyMoodReminder(lang: lang);
    await scheduleEveningReflection(lang: lang);
    await scheduleStreakReminder(lang: lang);
  }

  // ── Cancel notifications ──────────────────────────────────

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }

  /// Cancel a specific notification by ID.
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // ── Helpers ───────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
