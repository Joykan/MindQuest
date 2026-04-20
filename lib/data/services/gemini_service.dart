// lib/data/services/gemini_service.dart
// Powered by Groq API (free tier)
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class GeminiService {
  static final GeminiService _i = GeminiService._();
  factory GeminiService() => _i;
  GeminiService._();

  static const _base = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  static String _system(String lang) => lang == 'sw'
      ? '''Wewe ni MindQuest — msaidizi wa afya ya akili kwa vijana wa Kenya.

KANUNI MUHIMU SANA — LAZIMA UFUATE:
1. Jibu KWA KISWAHILI TU. Kamwe usitumie Kiingereza hata neno moja.
2. Tumia Kiswahili cha kawaida cha Kenya — si tafsiri ya Kiingereza.
3. Ukikosea lugha, utakuwa umeshindwa kazi yako.

MFANO WA JIBU BAYA (usifanye hivi):
"I understand unajisikia vibaya. That must be hard kwako."

MFANO WA JIBU ZURI (fanya hivi):
"Naelewa unakopitia wakati mgumu. Uko peke yako? Niambie zaidi."

MTINDO WA MAZUNGUMZO:
- Kuwa na huruma na upole
- Tumia maneno ya kawaida ya vijana wa Kenya
- Usiwe rasmi kupita kiasi
- Majibu mafupi — sentensi 2-4 tu
- Usitoe dawa wala utambuzi wa magonjwa

DHARURA — ukiona maneno ya kujidhuru au kujiua:
Sema mara moja:
"Befrienders Kenya: 0800 723 253
Simu ya Dharura: 1190
Tafadhali piga simu sasa hivi."

KUMBUKA: Kiswahili PEKEE. Hata msamiati wa Kiingereza uruhusiwe.'''
      : '''You are MindQuest — an empathetic AI mental wellness companion for Kenyan youth.

CRITICAL RULE — YOU MUST FOLLOW THIS:
1. Respond in ENGLISH ONLY. Do NOT use any Kiswahili or Swahili words.
2. Do NOT mix languages. If you write "unajisikia" or any Swahili word, you have failed.
3. Natural, warm English only.

BAD RESPONSE EXAMPLE (never do this):
"I understand how unajisikia. It can be hard kushughulika with stress."

GOOD RESPONSE EXAMPLE (do this):
"I understand you're going through a tough time. You don't have to face this alone — tell me more."

STYLE:
- Warm, encouraging, non-judgmental
- Culturally aware of Kenyan context
- Keep responses concise: 2-4 sentences
- Never diagnose or replace professional help
- Use CBT-based techniques naturally

ON CRISIS (suicidal ideation, self-harm, hopelessness):
Immediately provide:
"Befrienders Kenya: 0800 723 253
Kenya Crisis Helpline: 1190
Please reach out to them right now."

REMEMBER: English ONLY. Zero Kiswahili words allowed.''';

  Future<String> sendMessage({
    required String message,
    required List<Map<String, String>> history,
    required String language,
  }) async {
    final messages = [
      {'role': 'system', 'content': _system(language)},
      ...history.map((h) => {
            'role': h['role'] == 'assistant' ? 'assistant' : 'user',
            'content': h['content'] ?? '',
          }),
      {'role': 'user', 'content': message},
    ];

    final res = await http.post(
      Uri.parse(_base),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.geminiApiKey}',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 300,
        'temperature': 0.7,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'] as String;
    }
    if (res.statusCode == 401) throw Exception('Invalid Groq API key.');
    if (res.statusCode == 429) throw Exception('Rate limit. Wait a moment.');
    throw Exception('Groq error ${res.statusCode}: ${res.body}');
  }

  CrisisDetectionResult detectCrisis(String message) {
    final lower = message.toLowerCase();
    final found = [
      ...AppConstants.crisisKeywordsEn,
      ...AppConstants.crisisKeywordsSw,
    ].where((k) => lower.contains(k)).toList();
    return CrisisDetectionResult(
        isCrisis: found.isNotEmpty, triggeredKeywords: found);
  }

  double quickSentiment(String message) {
    const pos = [
      'happy', 'good', 'great', 'amazing', 'joy', 'love', 'excited',
      'grateful', 'better', 'wonderful', 'furaha', 'vizuri', 'safi', 'poa'
    ];
    const neg = [
      'sad', 'terrible', 'awful', 'hate', 'depressed', 'anxious', 'scared',
      'hopeless', 'angry', 'huzuni', 'vibaya', 'mbaya', 'chuki'
    ];
    final lower = message.toLowerCase();
    int score = 0;
    for (final w in pos) {
      if (lower.contains(w)) score++;
    }
    for (final w in neg) {
      if (lower.contains(w)) score--;
    }
    return score.clamp(-3, 3) / 3.0;
  }

  Future<String> analyzeMood({
    required int moodValue,
    required String note,
    required int energyLevel,
    required List<String> tags,
    required String language,
  }) async {
    final moodLabels = ['Vibaya Sana', 'Vibaya', 'Sawa', 'Vizuri', 'Bora Kabisa'];
    final moodLabelsEn = ['Terrible', 'Bad', 'Okay', 'Good', 'Amazing'];
    final emotionEmojis = ['😢', '😕', '😐', '😊', '😄'];

    final prompt = language == 'sw'
        ? '''Hali ya hisia: ${moodLabels[moodValue - 1]} ${emotionEmojis[moodValue - 1]}
Nguvu: ${energyLevel}/5
Maelezo: "$note"
Mada: ${tags.join(', ')}

Toa ushauri mfupi wa huruma (sentensi 1-2) kuhusu hali hii. Tumia Kiswahili cha kawaida cha Kenya. Usitumie Kiingereza hata kidogo.'''
        : '''Mood: ${moodLabelsEn[moodValue - 1]} ${emotionEmojis[moodValue - 1]}
Energy: $energyLevel/5
Notes: "$note"
Tags: ${tags.join(', ')}

Provide a brief, empathetic insight (1-2 sentences) about this emotional state. Be supportive and encouraging. English only.''';

    final messages = [
      {
        'role': 'system',
        'content': language == 'sw'
            ? 'Wewe ni mshauri wa afya ya akili. Toa maoni mafupi ya huruma. Kiswahili pekee — hakuna Kiingereza.'
            : 'You are a mental wellness coach. Provide brief, supportive insights. English only.',
      },
      {'role': 'user', 'content': prompt},
    ];

    final res = await http.post(
      Uri.parse(_base),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.geminiApiKey}',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'] as String;
    }
    return language == 'sw'
        ? 'Asante kwa kuandika hisia zako! Endelea hivyo.'
        : 'Thanks for logging your mood! Keep it up.';
  }
}

class CrisisDetectionResult {
  final bool isCrisis;
  final List<String> triggeredKeywords;
  const CrisisDetectionResult({
    required this.isCrisis,
    required this.triggeredKeywords,
  });
}
