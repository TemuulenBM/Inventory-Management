import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';

/// Sync status badge with pulse animation
/// Дизайн: Green "Synced" or Red "Offline" with pulsing dot
class SyncStatusBadge extends StatelessWidget {
  final bool isSynced;
  final DateTime? lastSyncTime;
  final bool compact;

  const SyncStatusBadge({
    super.key,
    required this.isSynced,
    this.lastSyncTime,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSynced
            ? AppColors.statusActive.withValues(alpha: 0.1)
            : AppColors.warningOrange.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusFull,
        border: Border.all(
          color: isSynced ? AppColors.statusActive : AppColors.warningOrange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          _PulsingDot(
            color: isSynced ? AppColors.statusActive : AppColors.warningOrange,
            size: compact ? 6 : 8,
          ),
          const SizedBox(width: 6),

          // Status text
          Text(
            isSynced ? 'Synced' : 'Offline',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: isSynced ? AppColors.statusActive : AppColors.warningOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot indicator
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({
    required this.color,
    this.size = 8,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}

/// Sync info widget (with last sync time)
class SyncInfo extends StatelessWidget {
  final bool isSynced;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  const SyncInfo({
    super.key,
    required this.isSynced,
    this.lastSyncTime,
    this.isSyncing = false,
  });

  String get _syncText {
    if (isSyncing) {
      return 'Синхрончилж байна...';
    }
    if (lastSyncTime == null) {
      return 'Хэзээ ч синхрончлогдоогүй';
    }
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Саяхан синхрончилсон';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}м өмнө';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}ц өмнө';
    } else {
      return '${difference.inDays} хоногийн өмнө';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSyncing)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: isSynced ? AppColors.statusActive : AppColors.warningOrange,
          ),
        const SizedBox(width: 6),
        Text(
          _syncText,
          style: TextStyle(
            fontSize: 12,
            color: isSynced ? AppColors.textSecondaryLight : AppColors.warningOrange,
          ),
        ),
      ],
    );
  }
}
