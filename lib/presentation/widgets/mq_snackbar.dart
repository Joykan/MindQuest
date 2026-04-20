// lib/presentation/widgets/mq_snackbar.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MQSnackbar {
  static void _show(BuildContext ctx, String msg, Color color, String icon) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  static void success(BuildContext ctx, String msg) =>
      _show(ctx, msg, AppColors.success, '✅');
  static void error(BuildContext ctx, String msg) =>
      _show(ctx, msg, AppColors.error, '❌');
  static void info(BuildContext ctx, String msg) =>
      _show(ctx, msg, AppColors.info, 'ℹ️');
}
