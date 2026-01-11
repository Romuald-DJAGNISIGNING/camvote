import 'package:flutter/material.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Custom button widget for CamVote
/// Supports loading state, different colors, and full-width layout
class CamButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const CamButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = CamColors.green,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  /// Factory constructor for secondary button (outlined style)
  factory CamButton.secondary({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CamButton(
      label: label,
      onPressed: onPressed,
      color: CamColors.white,
      isLoading: isLoading,
      icon: icon,
    );
  }

  /// Factory constructor for danger/error button
  factory CamButton.danger({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CamButton(
      label: label,
      onPressed: onPressed,
      color: CamColors.error,
      isLoading: isLoading,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(CamColors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: CamTextStyles.button),
                ],
              )
            : Text(label, style: CamTextStyles.button);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == CamColors.white ? CamColors.green : CamColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: color == CamColors.white
                ? const BorderSide(color: CamColors.green, width: 1.5)
                : BorderSide.none,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}