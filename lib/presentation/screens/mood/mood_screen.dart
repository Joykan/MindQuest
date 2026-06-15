// lib/presentation/screens/mood/mood_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_snackbar.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});
  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int? _mood;
  int _energy = 3;
  final _note = TextEditingController();
  final List<String> _tags = [];
  bool _loading = false;
  String? _moodAnalysis;

  static const _tagOptions = [
    'Stress',
    'Anxiety',
    'School',
    'Family',
    'Work',
    'Relationships',
    'Health',
    'Sleep',
  ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_mood == null) return;
    setState(() => _loading = true);
    try {
      final uid = ref.read(supabaseServiceProvider).currentUserId!;
      final lang = ref.read(languageProvider);

      // Save mood
      await ref
          .read(supabaseServiceProvider)
          .logMood(
            userId: uid,
            moodValue: _mood!,
            moodLabel: AppConstants.moodLabels[_mood]!,
            note: _note.text.isEmpty ? null : _note.text,
            energyLevel: _energy,
            tags: _tags.isEmpty ? null : List.from(_tags),
          );

      // Award XP
      await ref
          .read(supabaseServiceProvider)
          .awardXp(userId: uid, xpAmount: AppConstants.xpPerMoodLog);

      ref.invalidate(moodHistoryProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(userQuestsProvider);

      // Get AI analysis
      try {
        final analysis = await ref
            .read(geminiServiceProvider)
            .analyzeMood(
              moodValue: _mood!,
              note: _note.text,
              energyLevel: _energy,
              tags: _tags,
              language: lang,
            );
        setState(() => _moodAnalysis = analysis);
      } catch (_) {
        // Silently fail on analysis
      }

      if (mounted) {
        if (_moodAnalysis != null) {
          _showAnalysisDialog(context, lang);
        } else {
          MQSnackbar.success(
            context,
            lang == 'sw'
                ? '+${AppConstants.xpPerMoodLog} XP! Hisia zimehifadhiwa! 🌟'
                : '+${AppConstants.xpPerMoodLog} XP! Mood logged! 🌟',
          );
          Future.delayed(const Duration(seconds: 1), () => context.pop());
        }
      }
    } catch (_) {
      if (mounted) MQSnackbar.error(context, 'Failed to save mood. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAnalysisDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧠', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                lang == 'sw' ? 'Uchambuzi wa Hisia' : 'Mood Insights',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _moodAnalysis ?? '',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF8AAA9A),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (mounted) {
                      MQSnackbar.success(
                        context,
                        lang == 'sw'
                            ? '+${AppConstants.xpPerMoodLog} XP! Hisia zimehifadhiwa! 🌟'
                            : '+${AppConstants.xpPerMoodLog} XP! Mood logged! 🌟',
                      );
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) context.pop();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCard,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    lang == 'sw' ? 'Asante! ✓' : 'Got it! ✓',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          lang == 'sw' ? 'Rekodi Hisia Zako' : 'Log Your Mood',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mood Picker ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final v = i + 1;
                final sel = _mood == v;
                final col = AppColors.moodColors[v]!;
                return GestureDetector(
                      onTap: () => setState(() => _mood = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: sel ? 68 : 56,
                        height: sel ? 86 : 72,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.darkCard
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: sel
                              ? Border.all(color: col, width: 2)
                              : Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConstants.moodEmojis[v]!,
                              style: TextStyle(fontSize: sel ? 34 : 26),
                            ),
                            if (sel)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lang == 'sw'
                                      ? AppConstants.moodLabelsSw[v]!
                                      : AppConstants.moodLabels[v]!,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9,
                                    color: col,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: i * 60))
                    .scale()
                    .fadeIn();
              }),
            ),
            const SizedBox(height: 28),

            // ── Energy Level ─────────────────────────────────
            Text(
              lang == 'sw' ? 'Nguvu Zako' : 'Energy Level',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryLight,
                inactiveTrackColor: AppColors.darkCard,
                thumbColor: AppColors.primaryLight,
                overlayColor: AppColors.primaryLight.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _energy.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _energy = v.round()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == 'sw' ? 'Chini' : 'Low',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF8AAA9A),
                  ),
                ),
                Text(
                  lang == 'sw' ? 'Juu' : 'High',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF8AAA9A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Tags ──────────────────────────────────────────
            Text(
              lang == 'sw'
                  ? 'Lebo (Chagua zinazofaa)'
                  : 'Tags (Select all that apply)',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagOptions.map((tag) {
                final sel = _tags.contains(tag);
                return GestureDetector(
                  onTap: () =>
                      setState(() => sel ? _tags.remove(tag) : _tags.add(tag)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: sel
                          ? null
                          : Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : const Color(0xFF8AAA9A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Notes ─────────────────────────────────────────
            Text(
              lang == 'sw' ? 'Maelezo (si lazima)' : 'Notes (optional)',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: lang == 'sw'
                    ? 'Andika kidogo zaidi...'
                    : 'Write a little more about how you feel...',
                hintStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  color: Color(0xFF5A7A68),
                  fontSize: 14,
                ),
                counterStyle: const TextStyle(color: Color(0xFF5A7A68)),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // ── Save Mood button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _mood != null && !_loading ? _save : null,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  lang == 'sw'
                      ? 'Hifadhi Hisia (+${AppConstants.xpPerMoodLog} XP)'
                      : 'Save Mood (+${AppConstants.xpPerMoodLog} XP)',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.darkCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── View History button ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.moodHistory),
                icon: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF8AAA9A),
                  size: 20,
                ),
                label: Text(
                  lang == 'sw' ? 'Angalia Historia' : 'View History',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8AAA9A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3A5A48), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
