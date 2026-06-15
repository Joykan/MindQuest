// lib/presentation/providers/providers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';

// ── Services ────────────────────────────────────────────────
final supabaseServiceProvider =
    Provider<SupabaseService>((_) => SupabaseService());

final geminiServiceProvider = Provider<GeminiService>((_) => GeminiService());

// ── Auth ────────────────────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseServiceProvider).authStateChanges,
);

// ── Language ────────────────────────────────────────────────
final languageProvider = StateProvider<String>((ref) {
  final profile = ref.watch(profileProvider).valueOrNull;
  return profile?.language ?? 'en';
});

// ── Theme ────────────────────────────────────────────────────
final themeProvider = StateProvider<String>((ref) => 'system');

// ── Profile ─────────────────────────────────────────────────
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return null;
  return ref.watch(supabaseServiceProvider).getProfile(uid);
});

// ── Stats ───────────────────────────────────────────────────
final userStatsProvider = FutureProvider<UserStats?>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return null;
  return ref.watch(supabaseServiceProvider).getUserStats(uid);
});

// ── Mood ────────────────────────────────────────────────────
final moodHistoryProvider = FutureProvider<List<MoodLog>>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return [];
  return ref.watch(supabaseServiceProvider).getMoodHistory(userId: uid);
});

final todayCheckinProvider = FutureProvider<DailyCheckin?>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return null;
  return ref.watch(supabaseServiceProvider).getTodayCheckin(uid);
});

final moodAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return {};
  return ref.watch(supabaseServiceProvider).getMoodAnalytics(uid);
});

// ── Gamification ────────────────────────────────────────────
final allBadgesProvider = FutureProvider<List<AppBadge>>(
  (ref) => ref.watch(supabaseServiceProvider).getAllBadges(),
);

final userBadgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return [];
  return ref.watch(supabaseServiceProvider).getUserBadges(uid);
});

/// Quests provider with fallback seed data so quests always show
final userQuestsProvider = FutureProvider<List<Quest>>((ref) async {
  final uid = ref.watch(supabaseServiceProvider).currentUserId;
  if (uid == null) return _seedQuests();
  try {
    final quests = await ref.watch(supabaseServiceProvider).getUserQuests(uid);
    if (quests.isEmpty) return _seedQuests();
    return quests;
  } catch (_) {
    return _seedQuests();
  }
});

List<Quest> _seedQuests() => [
      Quest(
        id: 'q_first_log',
        title: 'First Mood Log',
        titleSw: 'Rekodi ya Kwanza',
        description: 'Log your mood for the first time to earn XP.',
        descriptionSw: 'Andika hisia zako kwa mara ya kwanza kupata XP.',
        xpReward: 50,
        questType: 'mood',
        status: 'in_progress',
        progress: 0,
      ),
      Quest(
        id: 'q_7day_streak',
        title: '7-Day Streak',
        titleSw: 'Msururu wa Siku 7',
        description: 'Log your mood 7 days in a row.',
        descriptionSw: 'Andika hisia zako siku 7 mfululizo.',
        xpReward: 200,
        questType: 'streak',
        status: 'in_progress',
        progress: 0,
      ),
      Quest(
        id: 'q_first_chat',
        title: 'First Chat Session',
        titleSw: 'Mazungumzo ya Kwanza',
        description: 'Have your first conversation with MindQuest AI.',
        descriptionSw: 'Zungumza na MindQuest AI kwa mara ya kwanza.',
        xpReward: 30,
        questType: 'chat',
        status: 'in_progress',
        progress: 0,
      ),
      Quest(
        id: 'q_checkin_3',
        title: 'Morning Warrior',
        titleSw: 'Shujaa wa Asubuhi',
        description: 'Complete 3 morning check-ins.',
        descriptionSw: 'Kamilisha check-in ya asubuhi mara 3.',
        xpReward: 100,
        questType: 'checkin',
        status: 'in_progress',
        progress: 0,
      ),
      Quest(
        id: 'q_read_resource',
        title: 'Knowledge Seeker',
        titleSw: 'Mwenye Kiu ya Maarifa',
        description: 'Read an article in Wellness Resources.',
        descriptionSw: 'Soma makala katika Rasilimali za Afya.',
        xpReward: 40,
        questType: 'resources',
        status: 'in_progress',
        progress: 0,
      ),
    ];

// ── Resources ───────────────────────────────────────────────
final resourcesProvider = FutureProvider<List<Resource>>((ref) async {
  try {
    final result = await ref.watch(supabaseServiceProvider).getResources();
    if (result.isEmpty) return _seedResources();
    return result;
  } catch (_) {
    return _seedResources();
  }
});

List<Resource> _seedResources() => [
      // ── Articles ──────────────────────────────────────────
      Resource(
        id: 'r_anxiety_101',
        title: 'Understanding Anxiety',
        titleSw: 'Kuelewa Wasiwasi',
        content:
            'Anxiety is a normal response to stress. It becomes a problem when it interferes with daily life. '
            'Common signs include racing heart, restlessness, and overthinking. '
            'Techniques like deep breathing, grounding exercises, and talking to someone can help. '
            'Remember: you are not alone, and help is always available.',
        contentSw:
            'Wasiwasi ni hali ya kawaida wakati wa msongo wa mawazo. Inakuwa tatizo '
            'inapozuia maisha ya kila siku. Dalili ni pamoja na moyo kupiga haraka, '
            'kutokutulia, na kufikiria kupita kiasi. Mbinu kama kupumua kwa kina, '
            'mazoezi ya kutuliza, na kuzungumza na mtu zinaweza kusaidia. '
            'Kumbuka: Huko peke yako, na msaada uko karibu.',
        category: 'article',
        tags: ['Anxiety', 'Mental Health', 'Stress'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_depression_ke',
        title: 'Depression: What You Need to Know',
        titleSw: 'Huzuni Kali: Mambo Muhimu',
        content:
            'Depression is more than just feeling sad. It\'s a medical condition that affects how you think, '
            'feel, and act. Symptoms include persistent sadness, loss of interest, sleep changes, and fatigue. '
            'In Kenya, many people suffer in silence due to stigma. Reaching out to a professional or trusted '
            'person is a sign of strength, not weakness.',
        contentSw:
            'Huzuni kali si huzuni tu ya kawaida. Ni hali ya kiafya inayoathiri jinsi unavyofikiria, '
            'kuhisi, na kutenda. Dalili ni pamoja na huzuni inayoendelea, kupoteza ladha ya mambo, '
            'mabadiliko ya usingizi, na uchovu. Nchini Kenya, watu wengi wanateseka kimya kwa sababu ya '
            'aibu. Kutafuta msaada ni ishara ya nguvu, si udhaifu.',
        category: 'article',
        tags: ['Depression', 'Mental Health', 'Kenya'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_stress_students',
        title: 'Managing Exam Stress',
        titleSw: 'Kudhibiti Msongo wa Mitihani',
        content:
            'Exam stress is common among Kenyan students. Effective strategies include: '
            'breaking study sessions into chunks, taking regular breaks, staying hydrated, '
            'sleeping 7-8 hours, and avoiding cramming the night before. '
            'Talk to a friend or counsellor if stress becomes overwhelming.',
        contentSw:
            'Msongo wa mitihani ni wa kawaida kwa wanafunzi wa Kenya. Mbinu nzuri ni pamoja na: '
            'kugawanya masomo katika vipande vidogo, kupumzika mara kwa mara, '
            'kunywa maji ya kutosha, kulala masaa 7-8, na kuepuka kusoma usiku wa manane. '
            'Zungumza na rafiki au mshauri ukihisi mzigo ni mzito.',
        category: 'article',
        tags: ['Stress', 'Students', 'School'],
        isFeatured: false,
      ),
      Resource(
        id: 'r_self_care',
        title: 'Self-Care Basics',
        titleSw: 'Misingi ya Kujitunza',
        content:
            'Self-care is not selfish — it\'s essential. Simple daily practices include: '
            'getting enough sleep, eating balanced meals, moving your body for at least 30 minutes, '
            'limiting social media, journaling your thoughts, and spending time with people who lift you up. '
            'Small consistent habits have a big impact on your mental health.',
        contentSw:
            'Kujitunza si ubinafsi — ni muhimu. Mazoea ya kila siku ni pamoja na: '
            'kulala vizuri, kula mlo kamili, kutembea angalau dakika 30, '
            'kupunguza mitandao ya kijamii, kuandika mawazo yako, na kukaa na watu wanaokupa nguvu. '
            'Mazoea madogo yanayofanywa mara kwa mara yana athari kubwa kwa afya yako ya akili.',
        category: 'article',
        tags: ['Self-Care', 'Wellness', 'Daily Habits'],
        isFeatured: false,
      ),
      // ── Exercises ─────────────────────────────────────────
      Resource(
        id: 'r_box_breathing',
        title: 'Box Breathing for Anxiety',
        titleSw: 'Pumzi ya Sanduku kwa Wasiwasi',
        content:
            'Box breathing is a powerful technique used by athletes and military personnel. '
            'How to do it:\n'
            '1. Breathe IN for 4 counts\n'
            '2. HOLD for 4 counts\n'
            '3. Breathe OUT for 4 counts\n'
            '4. HOLD for 4 counts\n'
            'Repeat 4–6 times. This activates your parasympathetic nervous system and calms anxiety quickly.',
        contentSw:
            'Kupumua kwa sanduku ni mbinu yenye nguvu inayotumiwa na wanariadha na askari. '
            'Jinsi ya kufanya:\n'
            '1. Pumua NDANI kwa hadi 4\n'
            '2. SHIKILIA kwa hadi 4\n'
            '3. Pumua NJE kwa hadi 4\n'
            '4. SHIKILIA kwa hadi 4\n'
            'Rudia mara 4-6. Hii inatuliza mfumo wa neva na kupunguza wasiwasi haraka.',
        category: 'exercise',
        tags: ['Breathing', 'Anxiety', 'Mindfulness'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_grounding',
        title: '5-4-3-2-1 Grounding Technique',
        titleSw: 'Mbinu ya 5-4-3-2-1 ya Kutuliza',
        content:
            'When anxiety spikes, this technique brings you back to the present moment.\n'
            'Notice:\n'
            '• 5 things you can SEE\n'
            '• 4 things you can TOUCH\n'
            '• 3 things you can HEAR\n'
            '• 2 things you can SMELL\n'
            '• 1 thing you can TASTE\n'
            'This interrupts the anxiety spiral and anchors you in the here and now.',
        contentSw:
            'Wasiwasi ukipanda, mbinu hii inakurudisha katika wakati wa sasa.\n'
            'Angalia:\n'
            '• Vitu 5 unavyoviona\n'
            '• Vitu 4 unavyoweza kugusa\n'
            '• Sauti 3 unazosikia\n'
            '• Harufu 2 unazosogomea\n'
            '• Ladha 1 unayoionja\n'
            'Hii inazuia mzunguko wa wasiwasi na kukufunga katika wakati huu.',
        category: 'exercise',
        tags: ['Grounding', 'Anxiety', 'Mindfulness'],
        isFeatured: false,
      ),
      Resource(
        id: 'r_journaling',
        title: 'Journaling for Mental Health',
        titleSw: 'Kuandika Diary kwa Afya ya Akili',
        content:
            'Writing your thoughts is a proven way to process emotions. Try these prompts:\n'
            '• What am I feeling right now and why?\n'
            '• What am I grateful for today?\n'
            '• What is one thing I can control today?\n'
            '• What would I tell a friend going through this?\n'
            'Even 5 minutes of journaling daily can significantly improve your mental wellbeing.',
        contentSw:
            'Kuandika mawazo yako ni njia iliyothibitishwa ya kushughulikia hisia. Jaribu maswali haya:\n'
            '• Ninajisikiaje sasa hivi na kwa nini?\n'
            '• Ninashukuru nini leo?\n'
            '• Ni kitu kimoja gani ninachoweza kudhibiti leo?\n'
            '• Ningeniambia nini rafiki anayepitia hali hii?\n'
            'Hata dakika 5 za kuandika kila siku zinaweza kuboresha afya yako ya akili sana.',
        category: 'exercise',
        tags: ['Journaling', 'Self-Care', 'Emotions'],
        isFeatured: false,
      ),
      // ── Videos ─────────────────────────────────────────────
      Resource(
        id: 'r_vid_anxiety',
        title: 'How Anxiety Works (Video)',
        titleSw: 'Jinsi Wasiwasi Unavyofanya Kazi (Video)',
        content:
            'This short animated video explains the science behind anxiety — why your heart races, '
            'why you overthink, and what happens in your brain during anxious moments. '
            'Understanding the "why" makes anxiety less scary and more manageable.\n\n'
            '📺 Search: "How anxiety works TED-Ed" on YouTube.',
        contentSw:
            'Video hii fupi ya mwongozo inaeleza sayansi nyuma ya wasiwasi — '
            'kwa nini moyo wako unapiga haraka, kwa nini unafikiria kupita kiasi, '
            'na kinachotokea katika ubongo wako wakati wa wasiwasi. '
            'Kuelewa "kwa nini" kunafanya wasiwasi usitishe na udhibitiwe zaidi.\n\n'
            '📺 Tafuta: "How anxiety works TED-Ed" kwenye YouTube.',
        category: 'video',
        tags: ['Anxiety', 'Education', 'Brain'],
        isFeatured: false,
      ),
      Resource(
        id: 'r_vid_meditation',
        title: '5-Minute Guided Meditation (Video)',
        titleSw: 'Kutafakari kwa Dakika 5 (Video)',
        content:
            'A short guided meditation perfect for beginners or when you only have a few minutes. '
            'No experience needed. Just find a quiet spot, sit comfortably, and follow along.\n\n'
            '📺 Search: "5 minute meditation for beginners" on YouTube.',
        contentSw:
            'Kutafakari kwa mwongozo mfupi — kamili kwa wanaoanza au unapowa na dakika chache tu. '
            'Hakuna uzoefu unaohitajika. Tafuta mahali tulivu, kaa vizuri, na fuata.\n\n'
            '📺 Tafuta: "5 minute meditation for beginners" kwenye YouTube.',
        category: 'video',
        tags: ['Meditation', 'Mindfulness', 'Beginners'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_vid_sleep',
        title: 'Better Sleep Tips (Video)',
        titleSw: 'Vidokezo vya Kulala Vizuri (Video)',
        content:
            'Sleep is directly linked to mental health. This video covers: sleep hygiene, '
            'why screens before bed hurt sleep, the ideal sleep environment, and how to wind down. '
            'Aim for 7–9 hours per night.\n\n'
            '📺 Search: "How to sleep better science" on YouTube.',
        contentSw:
            'Usingizi unahusiana moja kwa moja na afya ya akili. Video hii inashughulikia: '
            'usafi wa usingizi, kwa nini simu kabla ya kulala inaumiza usingizi, '
            'mazingira bora ya kulala, na jinsi ya kupumzika. '
            'Lenga masaa 7-9 kila usiku.\n\n'
            '📺 Tafuta: "How to sleep better science" kwenye YouTube.',
        category: 'video',
        tags: ['Sleep', 'Health', 'Wellness'],
        isFeatured: false,
      ),
      // ── Helplines ──────────────────────────────────────────
      Resource(
        id: 'r_befrienders',
        title: 'Befrienders Kenya',
        titleSw: 'Befrienders Kenya',
        content:
            'Befrienders Kenya provides emotional support to people who are distressed, '
            'lonely, or feeling suicidal.\n\n'
            '📞 Toll-free: 0800 723 253\n'
            '🕐 Available: 24 hours, 7 days a week\n'
            '📍 Based in Nairobi\n'
            '🌐 befrienderskenya.org\n\n'
            'All calls are strictly confidential. You can also reach them by email or walk-in.',
        contentSw:
            'Befrienders Kenya hutoa msaada wa kihisia kwa watu wanaohisi msongo wa mawazo, '
            'upweke, au mawazo ya kujiua.\n\n'
            '📞 Bure: 0800 723 253\n'
            '🕐 Inapatikana: Masaa 24, siku 7 kwa wiki\n'
            '📍 Nairobi\n'
            '🌐 befrienderskenya.org\n\n'
            'Simu zote zinabaki siri. Unaweza pia kuwafikia kwa barua pepe au kutembelea.',
        category: 'helpline',
        tags: ['Crisis', 'Suicide Prevention', 'Kenya', '24/7'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_kenya_red_cross',
        title: 'Kenya Red Cross Psychosocial Support',
        titleSw: 'Msaada wa Kisaikolojia wa Msalaba Mwekundu',
        content:
            'Kenya Red Cross Society offers psychosocial support services across Kenya.\n\n'
            '📞 Hotline: 1199\n'
            '🕐 Available: During working hours\n'
            '🌐 redcross.or.ke\n\n'
            'They provide counselling, trauma support, and referral services.',
        contentSw:
            'Jumuiya ya Msalaba Mwekundu ya Kenya hutoa huduma za msaada wa kisaikolojia nchini kote.\n\n'
            '📞 Simu ya dharura: 1199\n'
            '🕐 Inapatikana: Wakati wa kazi\n'
            '🌐 redcross.or.ke\n\n'
            'Hutoa ushauri, msaada wa kiwewe, na huduma za kuelekeza.',
        category: 'helpline',
        tags: ['Crisis', 'Counselling', 'Kenya'],
        isFeatured: false,
      ),
      Resource(
        id: 'r_nhs_crisis',
        title: 'Kenya Crisis Line',
        titleSw: 'Mstari wa Dharura wa Kenya',
        content:
            'The Kenya National Crisis Helpline for mental health emergencies.\n\n'
            '📞 Call: 1190\n'
            '🕐 Available: 24 hours\n\n'
            'For immediate mental health crises and emergencies. '
            'This line connects you to trained mental health professionals.',
        contentSw:
            'Mstari wa kitaifa wa dharura wa Kenya kwa hali za dharura za afya ya akili.\n\n'
            '📞 Piga simu: 1190\n'
            '🕐 Inapatikana: Masaa 24\n\n'
            'Kwa hali za dharura za afya ya akili. '
            'Mstari huu unakuunganisha na wataalamu waliofunzwa wa afya ya akili.',
        category: 'helpline',
        tags: ['Crisis', 'Emergency', 'Kenya', '24/7'],
        isFeatured: true,
      ),
      Resource(
        id: 'r_mathare',
        title: 'Mathare Hospital Mental Health Services',
        titleSw: 'Huduma za Afya ya Akili — Hospitali ya Mathare',
        content:
            'Mathari National Teaching and Referral Hospital is Kenya\'s main mental health facility.\n\n'
            '📍 Thika Road, Nairobi\n'
            '📞 020 2724411\n'
            '🕐 Mon–Fri: 8am – 5pm\n\n'
            'Offers inpatient, outpatient, counselling, and psychiatric services. '
            'Public hospital — services available with NHIF.',
        contentSw:
            'Hospitali ya Kitaifa ya Mafunzo na Rufaa ya Mathari ni kituo kikuu cha afya ya akili Kenya.\n\n'
            '📍 Barabara ya Thika, Nairobi\n'
            '📞 020 2724411\n'
            '🕐 Jumatatu-Ijumaa: 8am – 5pm\n\n'
            'Hutoa huduma za kulazwa, nje, ushauri, na za kisaikolojia. '
            'Hospitali ya umma — huduma zinapatikana na NHIF.',
        category: 'helpline',
        tags: ['Hospital', 'Nairobi', 'Psychiatric', 'NHIF'],
        isFeatured: false,
      ),
      // ── Tips ───────────────────────────────────────────────
      Resource(
        id: 'r_tip_social_media',
        title: 'Social Media & Mental Health',
        titleSw: 'Mitandao ya Kijamii na Afya ya Akili',
        content:
            'Excessive social media use is linked to anxiety, depression, and low self-esteem. '
            'Healthy habits:\n'
            '• Set a daily limit (1–2 hours max)\n'
            '• No phones during meals or 1 hour before bed\n'
            '• Unfollow accounts that make you feel bad\n'
            '• Replace scroll time with a hobby or walk',
        contentSw:
            'Matumizi mengi ya mitandao ya kijamii yanahusishwa na wasiwasi, huzuni, na kujidharau. '
            'Mazoea mazuri:\n'
            '• Weka kikomo cha kila siku (masaa 1-2 tu)\n'
            '• Hakuna simu wakati wa chakula au saa 1 kabla ya kulala\n'
            '• Acha kufuata akaunti zinazokufanya uhisi vibaya\n'
            '• Badilisha muda wa kusogeza kwa hobby au kutembea',
        category: 'tip',
        tags: ['Social Media', 'Digital Wellness', 'Habits'],
        isFeatured: false,
      ),
      Resource(
        id: 'r_tip_talk',
        title: 'It\'s OK to Talk About It',
        titleSw: 'Ni Sawa Kuzungumza',
        content:
            'In Kenya, mental health is still stigmatised. Many people suffer in silence. '
            'But talking about how you feel is one of the most powerful things you can do. '
            'You don\'t have to be "crazy" to need support. '
            'Start small — talk to a trusted friend, family member, or use MindQuest AI.',
        contentSw:
            'Nchini Kenya, afya ya akili bado ina aibu. Watu wengi wanateseka kimya. '
            'Lakini kuzungumza jinsi unavyohisi ni moja ya mambo yenye nguvu zaidi unayoweza kufanya. '
            'Huhitaji kuwa "mwendawazimu" ili kupata msaada. '
            'Anza kidogo kidogo — zungumza na rafiki unayemwamini, mwanafamilia, au tumia MindQuest AI.',
        category: 'tip',
        tags: ['Stigma', 'Awareness', 'Kenya', 'Support'],
        isFeatured: true,
      ),
    ];

// ── Crisis ──────────────────────────────────────────────────
final crisisContactsProvider = FutureProvider<List<CrisisContact>>((ref) async {
  try {
    final list = await ref.watch(supabaseServiceProvider).getCrisisContacts();
    if (list.isEmpty) return _seedCrisisContacts();
    return list;
  } catch (_) {
    return _seedCrisisContacts();
  }
});

List<CrisisContact> _seedCrisisContacts() => [
      const CrisisContact(
        id: 'c1',
        name: 'Befrienders Kenya',
        nameSw: 'Befrienders Kenya',
        phone: '0800 723 253',
        description: 'Emotional support & suicide prevention — free, confidential',
        descriptionSw: 'Msaada wa kihisia na kuzuia kujiua — bure, siri',
        availableHours: '24/7',
      ),
      const CrisisContact(
        id: 'c2',
        name: 'Kenya Crisis Line',
        nameSw: 'Mstari wa Dharura wa Kenya',
        phone: '1190',
        description: 'National mental health emergency helpline',
        descriptionSw: 'Mstari wa dharura wa afya ya akili wa taifa',
        availableHours: '24/7',
      ),
      const CrisisContact(
        id: 'c3',
        name: 'Kenya Red Cross',
        nameSw: 'Msalaba Mwekundu wa Kenya',
        phone: '1199',
        description: 'Psychosocial support & counselling',
        descriptionSw: 'Msaada wa kisaikolojia na ushauri',
        availableHours: 'Mon–Fri 8am–5pm',
      ),
    ];

// ── Chat State ──────────────────────────────────────────────
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isCrisisDetected;
  final String? sessionId;
  final int sessionCount;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isCrisisDetected = false,
    this.sessionId,
    this.sessionCount = 0,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isCrisisDetected,
    String? sessionId,
    int? sessionCount,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isCrisisDetected: isCrisisDetected ?? this.isCrisisDetected,
        sessionId: sessionId ?? this.sessionId,
        sessionCount: sessionCount ?? this.sessionCount,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SupabaseService _supabase;
  final GeminiService _gemini;
  final String _userId;
  final String _language;
  final Ref _ref;

  ChatNotifier({
    required SupabaseService supabase,
    required GeminiService gemini,
    required String userId,
    required String language,
    required Ref ref,
  })  : _supabase = supabase,
        _gemini = gemini,
        _userId = userId,
        _language = language,
        _ref = ref,
        super(const ChatState());

  Future<void> startSession() async {
    try {
      final sid = await _supabase.createChatSession(
          userId: _userId, language: _language);
      state = state.copyWith(sessionId: sid);

      // Award XP for starting a session and update stats
      unawaited(_supabase.awardXp(userId: _userId, xpAmount: 5));

      // Update chat quest progress (First Chat Session)
      unawaited(_updateChatQuestProgress());

      final greeting = _language == 'sw'
          ? 'Habari! Mimi ni MindQuest 🌟 Unajisikiaje leo?'
          : 'Hey there! I\'m MindQuest 🌟 How are you feeling today?';
      _addMessage(
        id: 'welcome',
        role: 'assistant',
        content: greeting,
        sessionId: sid,
      );
    } catch (_) {
      // Offline fallback — generate a local session ID
      final localSid = 'local_${DateTime.now().millisecondsSinceEpoch}';
      state = state.copyWith(sessionId: localSid);
      final greeting = _language == 'sw'
          ? 'Habari! Mimi ni MindQuest 🌟 Unajisikiaje leo?'
          : 'Hey there! I\'m MindQuest 🌟 How are you feeling today?';
      _addMessage(
        id: 'welcome',
        role: 'assistant',
        content: greeting,
        sessionId: localSid,
      );
    }
  }

  /// Update quest progress for chat-related quests
  Future<void> _updateChatQuestProgress() async {
    if (_userId.isEmpty) return;
    try {
      final sessionCount = await _supabase.getChatSessionCount(_userId);
      // First Chat Session quest — complete after 1 session
      final firstChatProgress = sessionCount >= 1 ? 100 : 0;
      await _supabase.updateQuestProgress(
        userId: _userId,
        questId: 'q_first_chat',
        progress: firstChatProgress,
      );
      // Check and award any earned badges
      await _supabase.checkAndAwardBadges(_userId);
      // Invalidate providers so UI refreshes
      _ref.invalidate(userStatsProvider);
      _ref.invalidate(userQuestsProvider);
      _ref.invalidate(userBadgesProvider);
    } catch (_) {
      // Best effort — don't block chat for quest failures
    }
  }

  void _addMessage({
    required String id,
    required String role,
    required String content,
    required String sessionId,
    bool isCrisis = false,
    double? sentiment,
  }) {
    final msg = ChatMessage(
      id: id,
      sessionId: sessionId,
      userId: _userId,
      role: role,
      content: content,
      isCrisisFlagged: isCrisis,
      sentimentScore: sentiment,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  Future<void> sendMessage(String content) async {
    if (state.sessionId == null) await startSession();
    final sid = state.sessionId!;

    final crisis = _gemini.detectCrisis(content);
    final sentiment = _gemini.quickSentiment(content);

    _addMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      sessionId: sid,
      isCrisis: crisis.isCrisis,
      sentiment: sentiment,
    );

    state = state.copyWith(
      isLoading: true,
      isCrisisDetected: crisis.isCrisis || state.isCrisisDetected,
    );

    // Persist to DB (non-blocking)
    if (!sid.startsWith('local_')) {
      unawaited(_supabase.saveMessage(
        sessionId: sid,
        userId: _userId,
        role: 'user',
        content: content,
        isCrisisFlagged: crisis.isCrisis,
        sentimentScore: sentiment,
      ));
    }

    if (crisis.isCrisis && !sid.startsWith('local_')) {
      unawaited(_supabase.flagSessionAsCrisis(sid));
      unawaited(_supabase.logCrisisEvent(
        userId: _userId,
        sessionId: sid,
        triggerKeywords: crisis.triggeredKeywords,
      ));
    }

    try {
      final history = state.messages
          .where((m) => m.id != 'welcome')
          .take(AppConstants.maxChatHistory)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final reply = await _gemini.sendMessage(
          message: content, history: history, language: _language);

      _addMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        role: 'assistant',
        content: reply,
        sessionId: sid,
      );

      if (!sid.startsWith('local_')) {
        unawaited(_supabase.saveMessage(
          sessionId: sid,
          userId: _userId,
          role: 'assistant',
          content: reply,
        ));
        unawaited(_supabase.awardXp(
            userId: _userId, xpAmount: AppConstants.xpPerChatMessage));
        // Refresh stats after XP award
        _ref.invalidate(userStatsProvider);
      }
    } catch (_) {
      _addMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        role: 'assistant',
        content: _language == 'sw'
            ? 'Samahani, kuna tatizo kidogo. Jaribu tena. 🙏'
            : 'Sorry, something went wrong. Please try again. 🙏',
        sessionId: sid,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ignore: camel_case_types
void unawaited(Future<void> future) => future.catchError((_) {});

final chatProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  final userId = supabase.currentUserId ?? '';
  final language = ref.watch(languageProvider);
  return ChatNotifier(
    supabase: supabase,
    gemini: gemini,
    userId: userId,
    language: language,
    ref: ref,
  );
});
