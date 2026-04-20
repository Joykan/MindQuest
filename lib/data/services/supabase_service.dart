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

  // ── Quests ───────────────────────────────────────────────
  Future<List<Quest>> getUserQuests(String userId) async {
    final d = await _db
        .from('user_quests')
        .select('*, quests(*)')
        .eq('user_id', userId);
    return (d as List)
        .map((e) => Quest.fromJson({
              ...e['quests'],
              'status': e['status'],
              'progress': e['progress'],
              'completed_at': e['completed_at'],
            }))
        .toList();
  }

  // ── Resources ────────────────────────────────────────────
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

  // ── Crisis Contacts ──────────────────────────────────────
  Future<List<CrisisContact>> getCrisisContacts() async {
    final d = await _db
        .from('crisis_contacts')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (d as List).map((e) => CrisisContact.fromJson(e)).toList();
  }

  // ── Analytics ────────────────────────────────────────────
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
