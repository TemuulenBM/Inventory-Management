import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';

/// Идэвхтэй ээлжийн hero card
/// Teal border, seller нэр, live timer, борлуулалтын мэдээлэл
class ActiveShiftCard extends StatefulWidget {
  final ShiftModel shift;
  final VoidCallback onCloseShift;

  const ActiveShiftCard({
    super.key,
    required this.shift,
    required this.onCloseShift,
  });

  @override
  State<ActiveShiftCard> createState() => _ActiveShiftCardState();
}

class _ActiveShiftCardState extends State<ActiveShiftCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Секунд тутамд duration шинэчлэх
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(widget.shift.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Идэвхтэй ээлж" badge + seller нэр
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: Text(
                      widget.shift.sellerName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSM,
                  Text(
                    widget.shift.sellerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              // Идэвхтэй badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Идэвхтэй',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalLG,

          // Хугацаа
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: AppColors.secondary),
              AppSpacing.horizontalSM,
              Text(
                '${hours}ц ${minutes}мин',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSM,

          // Эхэлсэн цаг
          Text(
            'Эхэлсэн: ${_formatTime(widget.shift.startTime)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalMD,

          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  icon: Icons.payments_outlined,
                  label: 'Борлуулалт',
                  value: '₮${widget.shift.totalSales.toStringAsFixed(0)}',
                  valueColor: AppColors.primary,
                ),
              ),
              AppSpacing.horizontalMD,
              Expanded(
                child: _buildStat(
                  icon: Icons.receipt_outlined,
                  label: 'Гүйлгээ',
                  value: '${widget.shift.transactionCount}',
                ),
              ),
            ],
          ),
          AppSpacing.verticalLG,

          // Ээлж хаах товч
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: widget.onCloseShift,
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: const Text(
                'Ээлж хаах',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMD,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: AppRadius.radiusSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
