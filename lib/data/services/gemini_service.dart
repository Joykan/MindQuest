// lib/data/services/gemini_service.dart
// Powered by Groq API + Kenyan MH few-shot NLP

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import 'nlp_dataset.dart';

class GeminiService {
  static final GeminiService _i = GeminiService._();

  factory GeminiService() => _i;

  GeminiService._();

  // On Flutter Web, /api/chat points to the Vercel API on the same domain.
  // On Android/iOS, an absolute URL is required.
  static String get _base {
    if (kIsWeb) {
      return '/api/chat';
    }

    return 'https://mindquest-ai-lovat.vercel.app/api/chat';
  }

  static const _model = 'openai/gpt-oss-20b';

  /// Build the MindQuest system prompt with dynamically injected
  /// Kenyan mental-health few-shot examples.
  static String _system(String lang, String userMessage) {
    final fewShot = KenyanMHDataset.buildFewShotBlock(
      message: userMessage,
      language: lang,
      k: 2,
    );

    if (lang == 'sw') {
      return '''Wewe ni MindQuest — msaidizi wa afya ya akili kwa vijana wa Kenya.

KANUNI MUHIMU SANA — LAZIMA UFUATE:
1. Jibu KWA KISWAHILI TU. Kamwe usitumie Kiingereza hata neno moja.
2. Tumia Kiswahili cha kawaida cha Kenya — si tafsiri ya Kiingereza.
3. Ukikosea lugha, utakuwa umeshindwa kazi yako.

MTINDO WA MAZUNGUMZO:
- Kuwa na huruma na upole
- Tumia maneno ya kawaida ya vijana wa Kenya
- Majibu mafupi — sentensi 2-4 tu
- Usitoe dawa wala utambuzi wa magonjwa

DHARURA — ukiona maneno ya kujidhuru au kujiua:
Sema mara moja: "Befrienders Kenya: 0800 723 253 | Simu ya Dharura: 1190"

KUMBUKA: Kiswahili PEKEE.

$fewShot''';
    }

    return '''You are MindQuest — an empathetic AI mental wellness companion for Kenyan youth.

CRITICAL RULES:
1. Respond in ENGLISH ONLY. Zero Kiswahili words.
2. Natural, warm English only.

STYLE:
- Warm, encouraging, non-judgmental
- Deeply aware of Kenyan context: KCSE pressure, matatu culture, family honour,
  financial hardship, unemployment, cultural stigma around mental health
- Keep responses concise: 2-4 sentences
- Never diagnose or replace professional help
- Use CBT techniques naturally (grounding, thought challenging, behavioural activation)

ON CRISIS: Immediately provide:
"Befrienders Kenya: 0800 723 253 | Kenya Crisis Helpline: 1190"

$fewShot''';
  }

  /// Send a chat message to the MindQuest backend.
  Future<String> sendMessage({
    required String message,
    required List<Map<String, String>> history,
    required String language,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content': _system(language, message),
      },
      ...history.map(
        (h) => {
          'role': h['role'] == 'assistant' ? 'assistant' : 'user',
          'content': h['content'] ?? '',
        },
      ),
      {
        'role': 'user',
        'content': message,
      },
    ];

    try {
      debugPrint('MindQuest API URL: $_base');
      debugPrint('Sending message: $message');

      final res = await http
          .post(
            Uri.parse(_base),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_tokens': 300,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('MindQuest API status: ${res.statusCode}');
      debugPrint('MindQuest API response: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final choices = data['choices'];

        if (choices is List && choices.isNotEmpty) {
          final content = choices[0]['message']?['content'];

          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          }
        }

        throw Exception('Invalid AI response format.');
      }

      if (res.statusCode == 400) {
        throw Exception(
          'Invalid request sent to the MindQuest server: ${res.body}',
        );
      }

      if (res.statusCode == 401) {
        throw Exception('Invalid Groq API key.');
      }

      if (res.statusCode == 429) {
        throw Exception('Rate limit reached. Please wait a moment.');
      }

      if (res.statusCode >= 500) {
        throw Exception(
          'MindQuest server error ${res.statusCode}: ${res.body}',
        );
      }

      throw Exception(
        'MindQuest API error ${res.statusCode}: ${res.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('MindQuest chat error: $e');
      debugPrint('MindQuest stack trace: $stackTrace');

      rethrow;
    }
  }

  /// Detect potentially high-risk/crisis messages locally.
  CrisisDetectionResult detectCrisis(String message) {
    final lower = message.toLowerCase();

    final found = [
      ...AppConstants.crisisKeywordsEn,
      ...AppConstants.crisisKeywordsSw,
    ].where((k) => lower.contains(k)).toList();

    return CrisisDetectionResult(
      isCrisis: found.isNotEmpty,
      triggeredKeywords: found,
    );
  }

  /// Perform a lightweight local sentiment calculation.
  double quickSentiment(String message) {
    const pos = [
      'happy',
      'good',
      'great',
      'amazing',
      'joy',
      'love',
      'excited',
      'grateful',
      'better',
      'wonderful',
      'furaha',
      'vizuri',
      'safi',
      'poa',
    ];

    const neg = [
      'sad',
      'terrible',
      'awful',
      'hate',
      'depressed',
      'anxious',
      'scared',
      'hopeless',
      'angry',
      'huzuni',
      'vibaya',
      'mbaya',
      'chuki',
    ];

    final lower = message.toLowerCase();

    int score = 0;

    for (final word in pos) {
      if (lower.contains(word)) {
        score++;
      }
    }

    for (final word in neg) {
      if (lower.contains(word)) {
        score--;
      }
    }

    return score.clamp(-3, 3) / 3.0;
  }

  /// Generate an AI insight for a mood log.
  Future<String> analyzeMood({
    required int moodValue,
    required String note,
    required int energyLevel,
    required List<String> tags,
    required String language,
  }) async {
    final moodLabels = [
      'Vibaya Sana',
      'Vibaya',
      'Sawa',
      'Vizuri',
      'Bora Kabisa',
    ];

    final moodLabelsEn = [
      'Terrible',
      'Bad',
      'Okay',
      'Good',
      'Amazing',
    ];

    final emotionEmojis = [
      '😢',
      '😕',
      '😐',
      '😊',
      '😄',
    ];

    // Protect against invalid mood values.
    final safeMoodValue = moodValue.clamp(1, 5);

    final prompt = language == 'sw'
        ? '''Hali ya hisia: ${moodLabels[safeMoodValue - 1]} ${emotionEmojis[safeMoodValue - 1]}
Nguvu: $energyLevel/5 | Maelezo: "$note" | Mada: ${tags.join(', ')}

Toa ushauri mfupi wa huruma (sentensi 1-2). Kiswahili tu.'''
        : '''Mood: ${moodLabelsEn[safeMoodValue - 1]} ${emotionEmojis[safeMoodValue - 1]}
Energy: $energyLevel/5 | Notes: "$note" | Tags: ${tags.join(', ')}

Provide a brief empathetic insight (1-2 sentences). English only.''';

    try {
      final res = await http
          .post(
            Uri.parse(_base),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content': language == 'sw'
                      ? 'Mshauri wa afya ya akili. Kiswahili pekee.'
                      : 'Mental wellness coach for Kenyan youth. English only.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'max_tokens': 150,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Mood API status: ${res.statusCode}');
      debugPrint('Mood API response: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final choices = data['choices'];

        if (choices is List && choices.isNotEmpty) {
          final content = choices[0]['message']?['content'];

          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }

      // Fallback if the AI request fails.
      return language == 'sw'
          ? 'Asante kwa kuandika hisia zako! Endelea hivyo.'
          : 'Thanks for logging your mood! Keep it up.';
    } catch (e, stackTrace) {
      debugPrint('Mood analysis error: $e');
      debugPrint('Mood analysis stack trace: $stackTrace');

      return language == 'sw'
          ? 'Asante kwa kuandika hisia zako! Endelea hivyo.'
          : 'Thanks for logging your mood! Keep it up.';
    }
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
