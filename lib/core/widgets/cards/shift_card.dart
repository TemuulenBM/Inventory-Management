import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Shift card for shift history/management
/// Дизайн: Seller name, date, time range, sales total
class ShiftCard extends StatelessWidget {
  final String sellerName;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalSales;
  final int transactionCount;
  final VoidCallback? onTap;
  final bool isActive;

  const ShiftCard({
    super.key,
    required this.sellerName,
    required this.startTime,
    this.endTime,
    required this.totalSales,
    required this.transactionCount,
    this.onTap,
    this.isActive = false,
  });

  String get _timeRange {
    final startStr = _formatTime(startTime);
    if (endTime != null) {
      final endStr = _formatTime(endTime!);
      return '$startStr - $endStr';
    }
    return '$startStr - Үргэлжилж байна';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get _duration {
    final end = endTime ?? DateTime.now();
    final duration = end.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}ц ${minutes}м';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.cardPadding,
      color: isActive ? AppColors.successBackground : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Seller name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          sellerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSM,
                      Text(
                        sellerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.statusActive,
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: const Text(
                        'Идэвхтэй',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalMD,

              // Time range and duration
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  AppSpacing.horizontalXS,
                  Text(
                    _timeRange,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  Text(
                    '($_duration)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSM,

              // Stats row
              Row(
                children: [
                  // Total sales
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.payments_outlined,
                      label: 'Борлуулалт',
                      value: '₮${totalSales.toStringAsFixed(0)}',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  // Transaction count
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.receipt_outlined,
                      label: 'Гүйлгээ',
                      value: transactionCount.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.textSecondaryLight,
            ),
            AppSpacing.horizontalXS,
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        AppSpacing.verticalXS,
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}
