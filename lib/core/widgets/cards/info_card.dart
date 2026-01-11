import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Generic information card for displaying notices, alerts, or info
class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = CamColors.info,
  });

  // Presets for different card types
  factory InfoCard.success({
    required String title,
    required String message,
  }) {
    return InfoCard(
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      color: CamColors.success,
    );
  }

  factory InfoCard.warning({
    required String title,
    required String message,
  }) {
    return InfoCard(
      title: title,
      message: message,
      icon: Icons.warning_amber_outlined,
      color: CamColors.warning,
    );
  }

  factory InfoCard.error({
    required String title,
    required String message,
  }) {
    return InfoCard(
      title: title,
      message: message,
      icon: Icons.error_outline,
      color: CamColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CamTextStyles.h3.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: CamTextStyles.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}