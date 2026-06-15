// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseService _i = SupabaseService._();
  factory SupabaseService() => _i;
  SupabaseService._();

  SupabaseClient get _db => Supabase.instance.client;

  // ── Auth ─────────────────────────────────────────────────
  User? get currentUser => _db.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  Stream<AuthState> get authStateChanges => _db.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String language,
  }) async {
    final res = await _db.auth.signUp(email: email, password: password);
    if (res.user != null) {
      await _db.from('profiles').insert({
        'id': res.user!.id,
        'username': username,
        'language': language,
      });
      await _db.from('user_stats').insert({'user_id': res.user!.id});
    }
    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _db.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signInAnonymously({
    required String username,
    required String language,
  }) async {
    try {
      final res = await _db.auth.signInAnonymously();
      if (res.user != null) {
        try {
          await _db.from('profiles').insert({
            'id': res.user!.id,
            'username': username,
            'language': language,
            'is_anonymous': true,
          });
        } catch (e) {
          // If username already exists, try with a more unique variant
          final uniqueUsername = '${username}_${res.user!.id.substring(0, 8)}';
          await _db.from('profiles').insert({
            'id': res.user!.id,
            'username': uniqueUsername,
            'language': language,
            'is_anonymous': true,
          });
        }
        try {
          await _db.from('user_stats').insert({'user_id': res.user!.id});
        } catch (_) {
          // Stats might fail, but continue anyway
        }
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() => _db.auth.signOut();

  // ── Profile ──────────────────────────────────────────────
  Future<UserProfile?> getProfile(String userId) async {
    final d =
        await _db.from('profiles').select().eq('id', userId).maybeSingle();
    return d != null ? UserProfile.fromJson(d) : null;
  }

  Future<void> updateProfile(UserProfile p) =>
      _db.from('profiles').update(p.toJson()).eq('id', p.id);

  // ── Stats ────────────────────────────────────────────────
  Future<UserStats?> getUserStats(String userId) async {
    final d = await _db
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return d != null ? UserStats.fromJson(d) : null;
  }

  // ACID: atomic XP award + level-up via DB function
  Future<XpResult> awardXp({
    required String userId,
    required int xpAmount,
    String? badgeId,
  }) async {
    final r = await _db.rpc('award_xp_and_check_levelup', params: {
      'p_user_id': userId,
      'p_xp_amount': xpAmount,
      if (badgeId != null) 'p_badge_id': badgeId,
    });
    return XpResult.fromJson(r);
  }

  // ── Mood ─────────────────────────────────────────────────
  Future<List<MoodLog>> getMoodHistory({
    required String userId,
    int limit = 30,
  }) async {
    final d = await _db
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .order('logged_at', ascending: false)
        .limit(limit);
    return (d as List).map((e) => MoodLog.fromJson(e)).toList();
  }

  Future<MoodLog> logMood({
    required String userId,
    required int moodValue,
    required String moodLabel,
    String? note,
    int? energyLevel,
    List<String>? tags,
  }) async {
    final d = await _db
        .from('mood_logs')
        .insert({
          'user_id': userId,
          'mood_value': moodValue,
          'mood_label': moodLabel,
          if (note != null) 'note': note,
          if (energyLevel != null) 'energy_level': energyLevel,
          if (tags != null) 'tags': tags,
        })
        .select()
        .single();
    return MoodLog.fromJson(d);
  }

  // ── Daily Check-in (ACID via DB function) ────────────────
  Future<Map<String, dynamic>> completeDailyCheckin({
    required String userId,
    required int moodValue,
    required String moodLabel,
    String? note,
    String? gratitudeNote,
    String? goalForDay,
  }) async {
    final r = await _db.rpc('complete_daily_checkin', params: {
      'p_user_id': userId,
      'p_mood_value': moodValue,
      'p_mood_label': moodLabel,
      if (note != null) 'p_note': note,
      if (gratitudeNote != null) 'p_gratitude': gratitudeNote,
      if (goalForDay != null) 'p_goal': goalForDay,
    });
    return Map<String, dynamic>.from(r);
  }

  Future<DailyCheckin?> getTodayCheckin(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final d = await _db
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .eq('checkin_date', today)
        .maybeSingle();
    return d != null ? DailyCheckin.fromJson(d) : null;
  }

  // ── Chat ─────────────────────────────────────────────────
  Future<String> createChatSession({
    required String userId,
    String language = 'en',
  }) async {
    final d = await _db
        .from('chat_sessions')
        .insert({
          'user_id': userId,
          'language': language,
        })
        .select('id')
        .single();
    return d['id'];
  }

  Future<void> saveMessage({
    required String sessionId,
    required String userId,
    required String role,
    required String content,
    bool isCrisisFlagged = false,
    double? sentimentScore,
  }) async {
    await _db.from('chat_messages').insert({
      'session_id': sessionId,
      'user_id': userId,
      'role': role,
      'content': content,
      'is_crisis_flagged': isCrisisFlagged,
      if (sentimentScore != null) 'sentiment_score': sentimentScore,
    });
  }

  Future<void> flagSessionAsCrisis(String sessionId) =>
      _db.from('chat_sessions').update({'is_crisis': true}).eq('id', sessionId);

  Future<void> logCrisisEvent({
    required String userId,
    String? sessionId,
    required List<String> triggerKeywords,
  }) async {
    await _db.from('crisis_events').insert({
      'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      'trigger_keywords': triggerKeywords,
      'action_taken': 'crisis_resources_shown',
    });
  }

  // ── Badges ───────────────────────────────────────────────
  Future<List<AppBadge>> getAllBadges() async {
    final d = await _db.from('badges').select();
    return (d as List).map((e) => AppBadge.fromJson(e)).toList();
  }

  Future<List<AppBadge>> getUserBadges(String userId) async {
    final d = await _db
        .from('user_badges')
        .select('badge_id, earned_at, badges(*)')
        .eq('user_id', userId)
        .order('earned_at', ascending: false);
    return (d as List).map((e) {
      final b = AppBadge.fromJson(e['badges']);
      b.earnedAt = DateTime.parse(e['earned_at']);
      return b;
    }).toList();
  }

  // ── Quest Progress ───────────────────────────────────────

  /// Upserts progress for a quest. Auto-completes the quest when progress >= 100.
  Future<void> updateQuestProgress({
    required String userId,
    required String questId,
    required int progress,
  }) async {
    // questId format: 'q_first_chat', 'q_first_log', 'q_7day_streak'
    final questTypeMap = {
      'q_first_chat': 'weekly',     // Chat Champion
      'q_first_log': 'daily',       // Morning Mindfulness
      'q_7day_streak': 'milestone', // Gratitude Journey
    };

    final questType = questTypeMap[questId];
    if (questType == null) return;

    // Get matching quests
    final quests = await _db
        .from('quests')
        .select('id')
        .eq('quest_type', questType)
        .eq('is_active', true);

    if ((quests as List).isEmpty) return;

    final clamped = progress.clamp(0, 100);
    final status = clamped >= 100 ? 'completed' : 'in_progress';

    for (final quest in quests) {
      await _db.from('user_quests').upsert({
        'user_id': userId,
        'quest_id': quest['id'],
        'progress': clamped,
        'status': status,
        if (status == 'completed')
          'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,quest_id');
    }
  }

  /// Count total mood logs for this user.
  Future<int> getMoodLogsCount(String userId) async {
    final d = await _db
        .from('mood_logs')
        .select('id')
        .eq('user_id', userId);
    return (d as List).length;
  }

  /// Count total chat sessions for this user.
  Future<int> getChatSessionCount(String userId) async {
    final d = await _db
        .from('chat_sessions')
        .select('id')
        .eq('user_id', userId);
    return (d as List).length;
  }

  /// Stream of user quests for real-time updates.
  Stream<List<Quest>> streamUserQuests(String userId) {
    return _db
        .from('user_quests')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((rows) async {
          if (rows.isEmpty) return <Quest>[];
          final questIds = rows.map((r) => r['quest_id'] as String).toList();
          final defs = await _db
              .from('quests')
              .select()
              .inFilter('id', questIds);
          final defMap = {for (final d in defs as List) d['id']: d};
          return rows.map((r) {
            final def = defMap[r['quest_id']];
            if (def == null) return null;
            return Quest.fromJson({
              ...def,
              'status': r['status'],
              'progress': r['progress'],
              'completed_at': r['completed_at'],
            });
          }).whereType<Quest>().toList();
        });
  }

  // ── User Quests (fetch with definitions) ────────────
  Future<List<Quest>> getUserQuests(String userId) async {
    // Get user's quest progress
    final userQuests = await _db
        .from('user_quests')
        .select('quest_id, status, progress, completed_at')
        .eq('user_id', userId);

    // Get all active quest definitions
    final allQuests = await _db
        .from('quests')
        .select()
        .eq('is_active', true);

    final progressMap = <String, Map<String, dynamic>>{};
    for (final uq in userQuests as List) {
      progressMap[uq['quest_id']] = uq;
    }

    return (allQuests as List).map((def) {
      final progress = progressMap[def['id']];
      return Quest.fromJson({
        ...def,
        if (progress != null) ...{
          'status': progress['status'],
          'progress': progress['progress'],
          'completed_at': progress['completed_at'],
        },
      });
    }).toList();
  }

  // ── Resources ────────────────────────────────────────
  Future<List<Resource>> getResources({String? category}) async {
    var q = _db.from('resources').select();
    if (category != null) q = q.eq('category', category);
    final d = await q.order('is_featured', ascending: false);
    return (d as List).map((e) => Resource.fromJson(e)).toList();
  }

  Future<void> bookmarkResource(String userId, String resourceId) =>
      _db.from('user_resource_interactions').upsert({
        'user_id': userId,
        'resource_id': resourceId,
        'interaction_type': 'bookmarked',
      });

  // ── Crisis Contacts ──────────────────────────────────
  Future<List<CrisisContact>> getCrisisContacts() async {
    final d = await _db
        .from('crisis_contacts')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (d as List).map((e) => CrisisContact.fromJson(e)).toList();
  }

  // ── Analytics ────────────────────────────────────────
  Future<Map<String, dynamic>> getMoodAnalytics(String userId) async {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final d = await _db
        .from('mood_logs')
        .select('mood_value, logged_at')
        .eq('user_id', userId)
        .gte('logged_at', since.toIso8601String())
        .order('logged_at');
    if ((d as List).isEmpty) {
      return {'average': 0.0, 'trend': [], 'distribution': {}, 'total': 0};
    }
    final moods = d.map<int>((e) => e['mood_value'] as int).toList();
    final avg = moods.reduce((a, b) => a + b) / moods.length;
    final dist = <int, int>{};
    for (final m in moods) {
      dist[m] = (dist[m] ?? 0) + 1;
    }
    return {
      'average': avg,
      'total': moods.length,
      'trend': d
          .map((e) => {'value': e['mood_value'], 'date': e['logged_at']})
          .toList(),
      'distribution': dist,
    };
  }
}
