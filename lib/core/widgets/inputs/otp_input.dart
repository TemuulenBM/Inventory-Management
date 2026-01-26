import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// OTP input - single TextField with visual digit boxes
/// Copy-paste боломжтой, auto-submit дэмжинэ
class OtpInput extends StatefulWidget {
  final Function(String) onComplete;
  final int length;
  final String? errorText;

  const OtpInput({
    super.key,
    required this.onComplete,
    this.length = 6,
    this.errorText,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Listen for changes
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});

    // Auto-submit when complete
    if (_controller.text.length == widget.length) {
      _focusNode.unfocus();
      widget.onComplete(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hidden TextField for input
        Stack(
          children: [
            // Visual digit boxes
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final totalSpacing = spacing * widget.length;
                final availableWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 320.0;
                final boxWidth = ((availableWidth - totalSpacing) / widget.length)
                    .clamp(40.0, 52.0);
                final boxHeight = boxWidth * 1.15;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildDigitBox(index, boxWidth, boxHeight),
                    ),
                  ),
                );
              },
            ),

            // Invisible TextField overlay for input
            Positioned.fill(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                style: const TextStyle(
                  color: Colors.transparent,
                  height: 0.01,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                showCursor: false,
              ),
            ),
          ],
        ),

        // Error text
        if (widget.errorText != null) ...[
          AppSpacing.verticalSM,
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDigitBox(int index, double width, double height) {
    final text = _controller.text;
    final hasDigit = index < text.length;
    final digit = hasDigit ? text[index] : '';
    final isFocused = _focusNode.hasFocus && index == text.length;
    final hasError = widget.errorText != null;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: hasDigit ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceLight,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: hasError
                ? AppColors.danger
                : isFocused
                    ? AppColors.primary
                    : hasDigit
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.gray300,
            width: isFocused || hasDigit ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: hasDigit
              ? Text(
                  digit,
                  style: TextStyle(
                    fontSize: width * 0.45,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                )
              : isFocused
                  ? Container(
                      width: 2,
                      height: height * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}
