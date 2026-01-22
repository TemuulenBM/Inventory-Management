import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/modals/bottom_action_sheet.dart';

/// Numeric keypad modal for quantity input
/// Дизайн: Numeric keypad with quick buttons (x2, x5, x10)
class KeypadModal extends StatefulWidget {
  final String title;
  final int initialValue;
  final int maxValue;
  final ValueChanged<int> onConfirm;

  const KeypadModal({
    super.key,
    this.title = 'Тоо оруулах',
    this.initialValue = 1,
    this.maxValue = 999,
    required this.onConfirm,
  });

  static Future<int?> show({
    required BuildContext context,
    String title = 'Тоо оруулах',
    int initialValue = 1,
    int maxValue = 999,
  }) async {
    int? result;
    await BottomActionSheet.show(
      context: context,
      height: 400,
      child: KeypadModal(
        title: title,
        initialValue: initialValue,
        maxValue: maxValue,
        onConfirm: (value) {
          result = value;
          Navigator.of(context).pop();
        },
      ),
    );
    return result;
  }

  @override
  State<KeypadModal> createState() => _KeypadModalState();
}

class _KeypadModalState extends State<KeypadModal> {
  late String _display;

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue.toString();
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_display == '0') {
        _display = number;
      } else if (_display.length < 3) {
        _display += number;
      }

      // Check max value
      final value = int.tryParse(_display) ?? 0;
      if (value > widget.maxValue) {
        _display = widget.maxValue.toString();
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onMultiply(int multiplier) {
    setState(() {
      final current = int.tryParse(_display) ?? 0;
      final newValue = current * multiplier;
      _display = newValue > widget.maxValue
          ? widget.maxValue.toString()
          : newValue.toString();
    });
  }

  void _onConfirm() {
    final value = int.tryParse(_display) ?? 0;
    widget.onConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.verticalLG,

        // Display
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Text(
            _display,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AppSpacing.verticalMD,

        // Quick buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickButton(
              label: 'x2',
              onPressed: () => _onMultiply(2),
            ),
            _QuickButton(
              label: 'x5',
              onPressed: () => _onMultiply(5),
            ),
            _QuickButton(
              label: 'x10',
              onPressed: () => _onMultiply(10),
            ),
          ],
        ),
        AppSpacing.verticalMD,

        // Keypad
        _buildKeypad(),
        AppSpacing.verticalMD,

        // Confirm button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
            ),
            child: const Text(
              'Баталгаажуулах',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        AppSpacing.verticalSM,
        _buildKeypadRow(['4', '5', '6']),
        AppSpacing.verticalSM,
        _buildKeypadRow(['7', '8', '9']),
        AppSpacing.verticalSM,
        _buildKeypadRow(['', '0', 'backspace']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 56);
        }
        if (key == 'backspace') {
          return _KeypadButton(
            icon: Icons.backspace_outlined,
            onPressed: _onBackspace,
          );
        }
        return _KeypadButton(
          label: key,
          onPressed: () => _onNumberPressed(key),
        );
      }).toList(),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.textMainLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 24)
            : Text(
                label!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
