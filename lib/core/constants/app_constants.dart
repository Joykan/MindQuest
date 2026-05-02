// lib/core/constants/app_constants.dart
import 'secrets.dart';

class AppConstants {
  // ── App Info ────────────────────────────────────────
  static const String appName = 'MindQuest';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Your Mental Wellness Journey';
  static const String appTaglineSw = 'Safari Yako ya Afya ya Akili';

  // ── Supabase & API Keys ─────────────────────────────
  // Keys are stored in secrets.dart (gitignored). See secrets.dart.example.
  static const String supabaseUrl = Secrets.supabaseUrl;
  static const String supabaseAnonKey = Secrets.supabaseAnonKey;

  static const String geminiApiKey = Secrets.geminiApiKey;
  static const String geminiModel = 'gemini-1.5-flash';

  // ── Gamification ───────────────────────────────────
  static const int xpPerMoodLog = 20;
  static const int xpPerChatMessage = 5;
  static const int xpPerCheckin = 30;
  static const int xpPerQuestComplete = 100;
  static const int xpPerLevel = 500;

  static const Map<String, int> tierThresholds = {
    'Newcomer': 0,
    'Explorer': 500,
    'Warrior': 1500,
    'Mind Master': 3000,
    'Legend': 5000,
  };

  // ── Crisis Detection ────────────────────────────────
  static const List<String> crisisKeywordsEn = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'hurt myself',
    'self harm',
    'no reason to live',
    'not worth living',
    'hopeless',
    "can't go on",
  ];

  static const List<String> crisisKeywordsSw = [
    'kujiua',
    'kujidhuru',
    'sina sababu ya kuishi',
    'sitaki kuishi',
    'maisha hayafai',
    'nakata tamaa',
  ];

  // ── Mood Settings ───────────────────────────────────
  static const Map<int, String> moodLabels = {
    1: 'terrible',
    2: 'bad',
    3: 'okay',
    4: 'good',
    5: 'amazing',
  };

  static const Map<int, String> moodLabelsSw = {
    1: 'vibaya sana',
    2: 'vibaya',
    3: 'sawa',
    4: 'vizuri',
    5: 'bora kabisa',
  };

  static const Map<int, String> moodEmojis = {
    1: '😢',
    2: '😕',
    3: '😐',
    4: '🙂',
    5: '😄',
  };

  static const int maxMessageLength = 1000;
  static const int maxChatHistory = 20;
}

// ── App Routes ─────────────────────────────────────────────
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';

  // Home routes (used with ShellRoute)
  static const String home = '/home/home';
  static const String chat = '/home/chat';
  static const String mood = '/home/mood';
  static const String moodHistory = '/home/mood-history';
  static const String quests = '/home/quests';
  static const String badges = '/home/badges';
  static const String resources = '/home/resources';
  static const String crisis = '/home/crisis';
  static const String profile = '/home/profile';
  static const String dailyCheckin = '/home/checkin';
  static const String settings = '/home/settings';
}
