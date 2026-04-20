// lib/data/models/models.dart

// ── UserProfile ─────────────────────────────────────────────
class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String language;
  final String? ageGroup;
  final String? county;
  final String? bio;
  final bool isAnonymous;
  final bool onboardingComplete;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.language = 'en',
    this.ageGroup,
    this.county,
    this.bio,
    this.isAnonymous = false,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id'],
    username: j['username'],
    displayName: j['display_name'],
    avatarUrl: j['avatar_url'],
    language: j['language'] ?? 'en',
    ageGroup: j['age_group'],
    county: j['county'],
    bio: j['bio'],
    isAnonymous: j['is_anonymous'] ?? false,
    onboardingComplete: j['onboarding_complete'] ?? false,
    createdAt: DateTime.parse(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'username': username,
    'display_name': displayName, 'avatar_url': avatarUrl,
    'language': language, 'age_group': ageGroup,
    'county': county, 'bio': bio,
    'is_anonymous': isAnonymous,
    'onboarding_complete': onboardingComplete,
  };

  UserProfile copyWith({
    String? displayName, String? avatarUrl, String? language,
    String? county, String? bio, bool? onboardingComplete,
  }) => UserProfile(
    id: id, username: username,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    language: language ?? this.language,
    ageGroup: ageGroup,
    county: county ?? this.county,
    bio: bio ?? this.bio,
    isAnonymous: isAnonymous,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    createdAt: createdAt,
  );
}

// ── UserStats ───────────────────────────────────────────────
class UserStats {
  final String id;
  final String userId;
  final int xp;
  final int level;
  final String tier;
  final int streakDays;
  final int longestStreak;
  final int totalSessions;
  final int totalMoodsLogged;
  final DateTime? lastActiveDate;

  const UserStats({
    required this.id, required this.userId,
    this.xp = 0, this.level = 1, this.tier = 'Newcomer',
    this.streakDays = 0, this.longestStreak = 0,
    this.totalSessions = 0, this.totalMoodsLogged = 0,
    this.lastActiveDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> j) => UserStats(
    id: j['id'], userId: j['user_id'],
    xp: j['xp'] ?? 0, level: j['level'] ?? 1,
    tier: j['tier'] ?? 'Newcomer',
    streakDays: j['streak_days'] ?? 0,
    longestStreak: j['longest_streak'] ?? 0,
    totalSessions: j['total_sessions'] ?? 0,
    totalMoodsLogged: j['total_moods_logged'] ?? 0,
    lastActiveDate: j['last_active_date'] != null
        ? DateTime.parse(j['last_active_date']) : null,
  );

  double get levelProgress => (xp % 500) / 500.0;
  int get xpToNextLevel => ((level) * 500) - xp;
}

// ── MoodLog ─────────────────────────────────────────────────
class MoodLog {
  final String id;
  final String userId;
  final int moodValue;
  final String moodLabel;
  final String? note;
  final int? energyLevel;
  final List<String>? tags;
  final DateTime loggedAt;

  const MoodLog({
    required this.id, required this.userId,
    required this.moodValue, required this.moodLabel,
    this.note, this.energyLevel, this.tags,
    required this.loggedAt,
  });

  String get emoji {
    const e = {1:'😢',2:'😕',3:'😐',4:'🙂',5:'😄'};
    return e[moodValue] ?? '😐';
  }

  factory MoodLog.fromJson(Map<String, dynamic> j) => MoodLog(
    id: j['id'], userId: j['user_id'],
    moodValue: j['mood_value'], moodLabel: j['mood_label'],
    note: j['note'], energyLevel: j['energy_level'],
    tags: j['tags'] != null ? List<String>.from(j['tags']) : null,
    loggedAt: DateTime.parse(j['logged_at']),
  );
}

// ── Badge ───────────────────────────────────────────────────
class AppBadge {
  final String id;
  final String name;
  final String? nameSw;
  final String? description;
  final String? descriptionSw;
  final int xpReward;
  final String category;
  DateTime? earnedAt;

  AppBadge({
    required this.id, required this.name,
    this.nameSw, this.description, this.descriptionSw,
    this.xpReward = 50, required this.category,
    this.earnedAt,
  });

  factory AppBadge.fromJson(Map<String, dynamic> j) => AppBadge(
    id: j['id'], name: j['name'], nameSw: j['name_sw'],
    description: j['description'], descriptionSw: j['description_sw'],
    xpReward: j['xp_reward'] ?? 50, category: j['category'],
    earnedAt: j['earned_at'] != null ? DateTime.parse(j['earned_at']) : null,
  );
}

// ── Quest ───────────────────────────────────────────────────
class Quest {
  final String id;
  final String title;
  final String? titleSw;
  final String? description;
  final String? descriptionSw;
  final int xpReward;
  final String questType;
  String status;
  int progress;
  DateTime? completedAt;

  Quest({
    required this.id, required this.title,
    this.titleSw, this.description, this.descriptionSw,
    this.xpReward = 100, required this.questType,
    this.status = 'in_progress', this.progress = 0,
    this.completedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> j) => Quest(
    id: j['id'], title: j['title'], titleSw: j['title_sw'],
    description: j['description'], descriptionSw: j['description_sw'],
    xpReward: j['xp_reward'] ?? 100, questType: j['quest_type'],
    status: j['status'] ?? 'in_progress',
    progress: j['progress'] ?? 0,
    completedAt: j['completed_at'] != null
        ? DateTime.parse(j['completed_at']) : null,
  );
}

// ── ChatMessage ─────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String sessionId;
  final String userId;
  final String role;
  final String content;
  final bool isCrisisFlagged;
  final double? sentimentScore;
  final DateTime createdAt;

  const ChatMessage({
    required this.id, required this.sessionId,
    required this.userId, required this.role,
    required this.content,
    this.isCrisisFlagged = false,
    this.sentimentScore,
    required this.createdAt,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'], sessionId: j['session_id'],
    userId: j['user_id'], role: j['role'], content: j['content'],
    isCrisisFlagged: j['is_crisis_flagged'] ?? false,
    sentimentScore: j['sentiment_score']?.toDouble(),
    createdAt: DateTime.parse(j['created_at']),
  );
}

// ── Resource ────────────────────────────────────────────────
class Resource {
  final String id;
  final String title;
  final String? titleSw;
  final String? content;
  final String? contentSw;
  final String category;
  final List<String>? tags;
  final bool isFeatured;
  bool isBookmarked;

  Resource({
    required this.id, required this.title,
    this.titleSw, this.content, this.contentSw,
    required this.category, this.tags,
    this.isFeatured = false, this.isBookmarked = false,
  });

  factory Resource.fromJson(Map<String, dynamic> j) => Resource(
    id: j['id'], title: j['title'], titleSw: j['title_sw'],
    content: j['content'], contentSw: j['content_sw'],
    category: j['category'],
    tags: j['tags'] != null ? List<String>.from(j['tags']) : null,
    isFeatured: j['is_featured'] ?? false,
  );
}

// ── CrisisContact ───────────────────────────────────────────
class CrisisContact {
  final String id;
  final String name;
  final String? nameSw;
  final String? phone;
  final String? description;
  final String? descriptionSw;
  final String availableHours;

  const CrisisContact({
    required this.id, required this.name,
    this.nameSw, this.phone,
    this.description, this.descriptionSw,
    this.availableHours = '24/7',
  });

  factory CrisisContact.fromJson(Map<String, dynamic> j) => CrisisContact(
    id: j['id'], name: j['name'], nameSw: j['name_sw'],
    phone: j['phone'], description: j['description'],
    descriptionSw: j['description_sw'],
    availableHours: j['available_hours'] ?? '24/7',
  );
}

// ── DailyCheckin ────────────────────────────────────────────
class DailyCheckin {
  final String id;
  final String userId;
  final DateTime checkinDate;
  final bool completed;
  final int xpAwarded;
  final String? gratitudeNote;
  final String? goalForDay;

  const DailyCheckin({
    required this.id, required this.userId,
    required this.checkinDate,
    this.completed = false, this.xpAwarded = 0,
    this.gratitudeNote, this.goalForDay,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> j) => DailyCheckin(
    id: j['id'], userId: j['user_id'],
    checkinDate: DateTime.parse(j['checkin_date']),
    completed: j['completed'] ?? false,
    xpAwarded: j['xp_awarded'] ?? 0,
    gratitudeNote: j['gratitude_note'],
    goalForDay: j['goal_for_day'],
  );
}

// ── XpResult ────────────────────────────────────────────────
class XpResult {
  final int newXp;
  final int newLevel;
  final String newTier;
  final bool leveledUp;
  final bool badgeAwarded;

  const XpResult({
    required this.newXp, required this.newLevel,
    required this.newTier,
    this.leveledUp = false, this.badgeAwarded = false,
  });

  factory XpResult.fromJson(Map<String, dynamic> j) => XpResult(
    newXp: j['new_xp'], newLevel: j['new_level'],
    newTier: j['new_tier'],
    leveledUp: j['leveled_up'] ?? false,
    badgeAwarded: j['badge_awarded'] ?? false,
  );
}
