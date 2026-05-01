// lib/data/models/peer_models.dart
//
// Models for the anonymous Peer Support Forum.
// No real usernames ever stored or shown — anonymity enforced by design.

// ── PeerPost ──────────────────────────────────────────────────────────────────

class PeerPost {
  final String id;
  final String userId;        // internal only — never shown
  final String anonHandle;   // e.g. "Brave Elephant" — shown instead of name
  final String anonAvatar;   // emoji avatar e.g. "🦁"
  final String content;
  final String language;     // 'en' | 'sw'
  final String category;
  final List<String> tags;
  final int hugCount;         // "hug" = upvote equivalent
  final int replyCount;
  final bool isApproved;
  final bool isFlagged;
  final bool hasCrisis;
  final DateTime createdAt;
  bool hasHugged;             // local UI state

  PeerPost({
    required this.id,
    required this.userId,
    required this.anonHandle,
    required this.anonAvatar,
    required this.content,
    required this.language,
    required this.category,
    this.tags = const [],
    this.hugCount = 0,
    this.replyCount = 0,
    this.isApproved = false,
    this.isFlagged = false,
    this.hasCrisis = false,
    required this.createdAt,
    this.hasHugged = false,
  });

  factory PeerPost.fromJson(Map<String, dynamic> j) => PeerPost(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        anonHandle: j['anon_handle'] as String? ?? 'Anonymous',
        anonAvatar: j['anon_avatar'] as String? ?? '🙂',
        content: j['content'] as String,
        language: j['language'] as String? ?? 'en',
        category: j['category'] as String? ?? 'general',
        tags: j['tags'] != null ? List<String>.from(j['tags'] as List) : [],
        hugCount: j['hug_count'] as int? ?? 0,
        replyCount: j['reply_count'] as int? ?? 0,
        isApproved: j['is_approved'] as bool? ?? false,
        isFlagged: j['is_flagged'] as bool? ?? false,
        hasCrisis: j['has_crisis'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
        hasHugged: j['has_hugged'] as bool? ?? false,
      );

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'anon_handle': anonHandle,
        'anon_avatar': anonAvatar,
        'content': content,
        'language': language,
        'category': category,
        'tags': tags,
        'is_approved': isApproved,
        'is_flagged': isFlagged,
        'has_crisis': hasCrisis,
        'hug_count': 0,
        'reply_count': 0,
      };

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }

  String get timeAgoSw {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'Sasa hivi';
    if (d.inMinutes < 60) return 'dakika ${d.inMinutes} zilizopita';
    if (d.inHours < 24) return 'saa ${d.inHours} zilizopita';
    if (d.inDays < 7) return 'siku ${d.inDays} zilizopita';
    return 'wiki ${(d.inDays / 7).floor()} zilizopita';
  }
}

// ── PeerReply ─────────────────────────────────────────────────────────────────

class PeerReply {
  final String id;
  final String postId;
  final String userId;
  final String anonHandle;
  final String anonAvatar;
  final String content;
  final String language;
  final int hugCount;
  final bool isApproved;
  final DateTime createdAt;
  bool hasHugged;

  PeerReply({
    required this.id,
    required this.postId,
    required this.userId,
    required this.anonHandle,
    required this.anonAvatar,
    required this.content,
    required this.language,
    this.hugCount = 0,
    this.isApproved = true,
    required this.createdAt,
    this.hasHugged = false,
  });

  factory PeerReply.fromJson(Map<String, dynamic> j) => PeerReply(
        id: j['id'] as String,
        postId: j['post_id'] as String,
        userId: j['user_id'] as String,
        anonHandle: j['anon_handle'] as String? ?? 'Anonymous',
        anonAvatar: j['anon_avatar'] as String? ?? '🙂',
        content: j['content'] as String,
        language: j['language'] as String? ?? 'en',
        hugCount: j['hug_count'] as int? ?? 0,
        isApproved: j['is_approved'] as bool? ?? true,
        createdAt: DateTime.parse(j['created_at'] as String),
        hasHugged: j['has_hugged'] as bool? ?? false,
      );
}

// ── AnonymousIdentity ─────────────────────────────────────────────────────────
// Each user gets a consistent random handle + emoji avatar so threads feel
// coherent without revealing real identities.

class AnonymousIdentity {
  final String handle; // e.g. "Brave Lion"
  final String avatar; // emoji e.g. "🦁"

  const AnonymousIdentity({required this.handle, required this.avatar});
}

const _adjectives = [
  'Brave', 'Calm', 'Gentle', 'Hopeful', 'Kind', 'Strong',
  'Quiet', 'Wise', 'Bright', 'Warm', 'Bold', 'Soft',
  'Steady', 'Curious', 'Peaceful', 'Resilient',
];
const _animals = [
  'Lion', 'Elephant', 'Crane', 'Dolphin', 'Owl', 'Butterfly',
  'Cheetah', 'Giraffe', 'Flamingo', 'Turtle', 'Hummingbird', 'Falcon',
  'Zebra', 'Gazelle', 'Sunbird', 'Pangolin',
];
const _avatars = [
  '🦁', '🐘', '🦅', '🐬', '🦉', '🦋',
  '🐆', '🦒', '🦩', '🐢', '🌺', '🌿',
  '🦓', '🌙', '☀️', '🌊',
];

/// Generate a deterministic anonymous identity from a userId string
AnonymousIdentity generateAnonIdentity(String userId) {
  final code = userId.codeUnits.fold(0, (a, b) => a + b);
  final adjIdx = code % _adjectives.length;
  final animalIdx = (code ~/ _adjectives.length) % _animals.length;
  final avatarIdx = (adjIdx + animalIdx) % _avatars.length;
  return AnonymousIdentity(
    handle: '${_adjectives[adjIdx]} ${_animals[animalIdx]}',
    avatar: _avatars[avatarIdx],
  );
}

// ── Categories ────────────────────────────────────────────────────────────────

class PeerCategory {
  final String id;
  final String labelEn;
  final String labelSw;
  final String emoji;
  const PeerCategory({
    required this.id,
    required this.labelEn,
    required this.labelSw,
    required this.emoji,
  });
  String label(String lang) => lang == 'sw' ? labelSw : labelEn;
}

const kPeerCategories = <PeerCategory>[
  PeerCategory(id: 'general',       labelEn: 'General',          labelSw: 'Jumla',                emoji: '💬'),
  PeerCategory(id: 'anxiety',       labelEn: 'Anxiety',          labelSw: 'Wasiwasi',             emoji: '😰'),
  PeerCategory(id: 'depression',    labelEn: 'Depression',       labelSw: 'Huzuni Kali',          emoji: '🌧️'),
  PeerCategory(id: 'school',        labelEn: 'School & Exams',   labelSw: 'Shule & Mitihani',     emoji: '📚'),
  PeerCategory(id: 'family',        labelEn: 'Family',           labelSw: 'Familia',              emoji: '🏠'),
  PeerCategory(id: 'relationships', labelEn: 'Relationships',    labelSw: 'Mahusiano',            emoji: '💔'),
  PeerCategory(id: 'motivation',    labelEn: 'Motivation',       labelSw: 'Motisha',              emoji: '🔥'),
  PeerCategory(id: 'celebration',   labelEn: 'Wins & Celebrations', labelSw: 'Mafanikio',        emoji: '🎉'),
  PeerCategory(id: 'coping',        labelEn: 'Coping Tips',      labelSw: 'Mbinu za Kukabiliana', emoji: '🌱'),
];
