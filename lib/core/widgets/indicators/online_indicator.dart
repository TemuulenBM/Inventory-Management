import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';

/// Online/Offline indicator with animated pulsing dot
class OnlineIndicator extends StatelessWidget {
  final bool isOnline;
  final bool showLabel;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedDot(isOnline: isOnline),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOnline ? AppColors.statusActive : AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final bool isOnline;

  const _AnimatedDot({required this.isOnline});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOnline ? AppColors.statusActive : AppColors.danger;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.3 * (1 - _controller.value)),
              ),
            ),
            // Inner dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}
