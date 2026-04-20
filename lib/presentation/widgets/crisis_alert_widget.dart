// lib/presentation/widgets/crisis_alert_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Enhanced crisis alert widget with direct hotline access.
/// Shows a prominent alert when crisis keywords are detected.
class CrisisAlertWidget extends StatelessWidget {
  final String lang;
  final VoidCallback? onDismiss;
  final bool compact;

  const CrisisAlertWidget({
    super.key,
    required this.lang,
    this.onDismiss,
    this.compact = false,
  });

  Future<void> _callHotline(String? number) async {
    if (number == null) return;
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    const befrienders = '0800 723 253';
    const kenyaCrisis = '1190';

    if (compact) {
      // Compact version for chat input area
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.crisis.withOpacity(0.15),
              AppColors.accent.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.crisis.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang == 'sw' ? 'Tunakujali' : 'We Care About You',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.crisis,
                    ),
                  ),
                  Text(
                    lang == 'sw'
                        ? 'Msaada uko karibu'
                        : 'Help is available now',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: AppColors.crisis.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.crisis),
              icon: const Icon(Icons.phone_rounded, size: 14),
              label: Text(lang == 'sw' ? 'Msaada' : 'Help',
                  style: const TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crisis,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      );
    }

    // Full version for prominent display
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.crisis.withOpacity(0.15),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.crisis.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.crisis.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('❤️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'sw'
                            ? 'Huogopi—Tunakujali'
                            : 'Don\'t Worry—We Care',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.crisis,
                        ),
                      ),
                      Text(
                        lang == 'sw'
                            ? 'Msaada wa dharura unapatikana sasa hivi'
                            : 'Crisis support available right now',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang == 'sw'
                    ? 'Ushindi au matatizo yanayoonekana kubwa ni muhimu. Jambazi kwa mtaalamu mwenyewe au simu nambari ya dharura.'
                    : 'If you\'re having thoughts of self-harm or suicide, please reach out to a professional or call the crisis line immediately.',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Quick action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callHotline(befrienders),
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text('Befrienders Kenya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crisis,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callHotline(kenyaCrisis),
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text('Kenya Crisis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crisis.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Learn more button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.crisis),
                icon: const Icon(Icons.local_hospital_rounded, size: 16),
                label: Text(lang == 'sw'
                    ? 'Tafuta Jambazi Zaidi'
                    : 'Learn More & Resources'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.crisis,
                  side: BorderSide(color: AppColors.crisis.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: -0.2, duration: 300.ms).fadeIn(duration: 300.ms);
  }
}

/// Inline crisis alert for chat messages.
class CrisisMessageAlert extends StatelessWidget {
  final String lang;
  final List<String> triggeredKeywords;

  const CrisisMessageAlert({
    super.key,
    required this.lang,
    required this.triggeredKeywords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.crisis.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.crisis.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: AppColors.crisis, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lang == 'sw'
                  ? 'Tumegundua kwamba unaweza kuhitaji msaada'
                  : 'We noticed you might need support',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.crisis,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.crisis),
            child: Text(
              lang == 'sw' ? 'Ujumbe' : 'Get Help',
              style: const TextStyle(
                color: AppColors.crisis,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
