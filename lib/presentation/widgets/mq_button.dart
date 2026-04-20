// lib/presentation/widgets/mq_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MQButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final Color? color;
  final bool outlined;

  const MQButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final child = isLoading
        ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
        : Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

    return SizedBox(
      width: width, height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c, width: 2), foregroundColor: c),
              child: child)
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(backgroundColor: c),
              child: child),
    );
  }
}
