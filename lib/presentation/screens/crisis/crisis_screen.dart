// lib/presentation/screens/crisis/crisis_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class CrisisScreen extends ConsumerWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final contacts = ref.watch(crisisContactsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          titleTextStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(lang == 'sw' ? 'Msaada wa Dharura' : 'Crisis Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.crisis.withOpacity(0.08),
                  AppColors.accent.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.crisis.withOpacity(0.25)),
            ),
            child: Column(children: [
              const Text('❤️', style: TextStyle(fontSize: 56))
                  .animate()
                  .scale(curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                lang == 'sw'
                    ? 'Uko Salama. Tunakujali.'
                    : 'You Are Safe. We Care.',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.crisis),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                lang == 'sw'
                    ? 'Ukihisi msongo mkubwa, tafadhali wasiliana na mtaalamu. '
                        'Huhitaji kupitia hili peke yako. Msaada uko karibu.'
                    : 'If you\'re in distress, please reach out to a professional. '
                        'You don\'t have to go through this alone. Help is close.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ]),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 28),

          // Helplines
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              lang == 'sw'
                  ? '📞 Nambari za Dharura — Kenya'
                  : '📞 Kenya Crisis Helplines',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),

          contacts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (list) => Column(
              children: list.asMap().entries.map((e) {
                final c = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 8)
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.crisis.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                          child: Text('📞', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          lang == 'sw' && c.nameSw != null ? c.nameSw! : c.name,
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        if (c.description != null)
                          Text(
                            lang == 'sw' && c.descriptionSw != null
                                ? c.descriptionSw!
                                : c.description!,
                            style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 2,
                          ),
                        Row(children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(c.availableHours,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ],
                    )),
                    if (c.phone != null)
                      ElevatedButton(
                        onPressed: () => _call(c.phone!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crisis,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: Size.zero,
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.phone_rounded,
                              color: Colors.white, size: 18),
                          Text(c.phone!,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ]),
                      ),
                  ]),
                )
                    .animate(delay: Duration(milliseconds: e.key * 80))
                    .fadeIn()
                    .slideX(begin: -0.05);
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          // Breathing exercise
          _BreathingCard(lang: lang),
          const SizedBox(height: 20),
          // Grounding technique
          _GroundingCard(lang: lang),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _BreathingCard extends StatefulWidget {
  final String lang;
  const _BreathingCard({required this.lang});
  @override
  State<_BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<_BreathingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _active = false;
  String _phase = '';

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 16));
    _anim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _active = !_active);
    if (_active) {
      _ctrl.repeat(reverse: true);
      _runPhases();
    } else {
      _ctrl.stop();
      setState(() => _phase = '');
    }
  }

  Future<void> _runPhases() async {
    final phases = widget.lang == 'sw'
        ? ['Pumua ndani...', 'Shikilia...', 'Toa pumzi...', 'Subiri...']
        : ['Breathe in...', 'Hold...', 'Breathe out...', 'Hold...'];
    while (_active && mounted) {
      for (final p in phases) {
        if (!_active || !mounted) break;
        setState(() => _phase = p);
        await Future.delayed(const Duration(seconds: 4));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        ),
        child: Column(children: [
          Row(children: [
            const Text('🌬️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(
              widget.lang == 'sw' ? 'Mazoezi ya Kupumua' : 'Box Breathing',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ]),
          const SizedBox(height: 16),
          if (_active) ...[
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Container(
                width: 80 * _anim.value,
                height: 80 * _anim.value,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(_phase,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        textAlign: TextAlign.center)),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _toggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _active
                  ? (widget.lang == 'sw' ? 'Simamisha' : 'Stop')
                  : (widget.lang == 'sw' ? 'Anza Kupumua' : 'Start Breathing'),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ]),
      );
}

class _GroundingCard extends StatelessWidget {
  final String lang;
  const _GroundingCard({required this.lang});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🌿', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(
              lang == 'sw' ? 'Mbinu ya 5-4-3-2-1' : '5-4-3-2-1 Grounding',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ]),
          const SizedBox(height: 12),
          ...([
            lang == 'sw' ? '👀 Vitu 5 unavyoviona' : '👀 5 things you can SEE',
            lang == 'sw'
                ? '✋ Vitu 4 unavyoweza kugusa'
                : '✋ 4 things you can TOUCH',
            lang == 'sw' ? '👂 Sauti 3 unazosikia' : '👂 3 things you can HEAR',
            lang == 'sw'
                ? '👃 Harufu 2 unazosogomea'
                : '👃 2 things you can SMELL',
            lang == 'sw' ? '👅 Ladha 1 unayoionja' : '👅 1 thing you can TASTE',
          ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(s,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                ]),
              ))),
        ]),
      );
}
