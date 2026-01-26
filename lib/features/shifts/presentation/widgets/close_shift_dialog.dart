import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';

/// Ээлж хаах dialog
/// Ээлжийн хураангуй (хугацаа, борлуулалт, гүйлгээ) харуулж баталгаажуулна
class CloseShiftDialog extends StatelessWidget {
  final ShiftModel shift;

  const CloseShiftDialog({super.key, required this.shift});

  /// Dialog харуулж, баталгаажсан бол true буцаана
  static Future<bool?> show(BuildContext context, ShiftModel shift) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CloseShiftDialog(shift: shift),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(shift.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stop_circle_outlined,
                size: 32,
                color: AppColors.danger,
              ),
            ),
            AppSpacing.verticalLG,

            // Гарчиг
            const Text(
              'Ээлж хаах',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalMD,

            // Хураангуй мэдээлэл
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantLight,
                borderRadius: AppRadius.radiusMD,
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Ажилтан', shift.sellerName),
                  AppSpacing.verticalSM,
                  _buildSummaryRow('Хугацаа', '${hours}ц ${minutes}мин'),
                  AppSpacing.verticalSM,
                  _buildSummaryRow(
                    'Борлуулалт',
                    '₮${shift.totalSales.toStringAsFixed(0)}',
                  ),
                  AppSpacing.verticalSM,
                  _buildSummaryRow(
                    'Гүйлгээ',
                    '${shift.transactionCount} удаа',
                  ),
                ],
              ),
            ),
            AppSpacing.verticalMD,

            const Text(
              'Ээлжийг хаасны дараа шинэ борлуулалт бүртгэгдэхгүй.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalXL,

            // Товчнууд
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMainLight,
                      side: const BorderSide(color: AppColors.gray300),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Цуцлах'),
                  ),
                ),
                AppSpacing.horizontalMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Хаах'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}
