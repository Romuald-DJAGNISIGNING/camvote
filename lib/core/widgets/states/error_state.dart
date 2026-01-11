import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Error state widget when something goes wrong
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: CamColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: CamTextStyles.h2.copyWith(color: CamColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: CamTextStyles.body,
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CamColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}