import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Success state widget for confirmations
class SuccessState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onContinue;
  final String? continueLabel;

  const SuccessState({
    super.key,
    required this.title,
    required this.message,
    this.onContinue,
    this.continueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CamColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: CamColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: CamTextStyles.h2.copyWith(color: CamColors.success),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: CamTextStyles.body,
              textAlign: TextAlign.center,
            ),
            
            if (onContinue != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onContinue,
                child: Text(continueLabel ?? 'Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}