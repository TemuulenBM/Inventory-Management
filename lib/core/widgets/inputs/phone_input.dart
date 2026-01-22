import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/layout/glass_panel.dart';

/// Phone input with +976 prefix (Mongolian phone number)
/// Дизайн: Glass card with prefix section
class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final bool autofocus;

  const PhoneInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Prefix section (+976)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100.withOpacity(0.5),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: const Text(
                  '+976',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
              ),
              AppSpacing.horizontalMD,

              // Phone number input
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8), // Mongolian phone: 8 digits
                  ],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: '99887766',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: onChanged,
                  onEditingComplete: onEditingComplete,
                ),
              ),
            ],
          ),
        ),

        // Error text
        if (errorText != null) ...[
          AppSpacing.verticalXS,
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact phone input (without glass effect)
class PhoneInputCompact extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const PhoneInputCompact({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: InputDecoration(
        prefixText: '+976 ',
        prefixStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textMainLight,
        ),
        hintText: '99887766',
        errorText: errorText,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
