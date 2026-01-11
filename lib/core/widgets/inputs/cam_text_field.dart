import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/cam_colors.dart';
import '../../theme/cam_text_styles.dart';

/// Custom text input field for CamVote with validation and styling
class CamTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int maxLines;
  final void Function(String)? onChanged;

  const CamTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CamTextStyles.label,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
          style: CamTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CamTextStyles.body.copyWith(color: CamColors.grey),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }
}