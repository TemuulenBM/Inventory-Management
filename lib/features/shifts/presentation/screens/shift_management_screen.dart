import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/widgets/cards/shift_card.dart';
import 'package:retail_control_platform/features/shifts/presentation/providers/shift_provider.dart';
import 'package:retail_control_platform/features/shifts/presentation/widgets/active_shift_card.dart';
import 'package:retail_control_platform/features/shifts/presentation/widgets/open_shift_dialog.dart';
import 'package:retail_control_platform/features/shifts/presentation/widgets/close_shift_dialog.dart';

/// Ээлжийн удирдлагын дэлгэц
/// Active shift card, ээлж нээх/хаах, ээлжийн түүх
class ShiftManagementScreen extends ConsumerWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(storeIdProvider);

    if (storeId == null) {
      return const Scaffold(
        body: Center(child: Text('Дэлгүүрт холбогдоогүй байна')),
      );
    }

    final currentShiftAsync = ref.watch(currentShiftProvider(storeId));
    final historyAsync = ref.watch(shiftHistoryProvider(storeId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Ээлж',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentShiftProvider(storeId));
          ref.invalidate(shiftHistoryProvider(storeId));
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Active shift section =====
              currentShiftAsync.when(
                data: (shift) {
                  if (shift != null) {
                    // Идэвхтэй ээлж байна
                    return ActiveShiftCard(
                      shift: shift,
                      onCloseShift: () =>
                          _handleCloseShift(context, ref, storeId, shift.id),
                    );
                  }
                  // Ээлж нээгдээгүй
                  return _buildNoShiftCard(context, ref);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                ),
                error: (error, _) => _buildErrorCard(
                  'Ээлжийн мэдээлэл ачаалахад алдаа гарлаа',
                  () => ref.invalidate(currentShiftProvider(storeId)),
                ),
              ),

              AppSpacing.verticalXL,

              // ===== Shift history section =====
              const Text(
                'Ээлжийн түүх',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMainLight,
                ),
              ),
              AppSpacing.verticalMD,

              historyAsync.when(
                data: (shifts) {
                  if (shifts.isEmpty) {
                    return _buildEmptyHistory();
                  }
                  return Column(
                    children: shifts.map((shift) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ShiftCard(
                          sellerName: shift.sellerName,
                          startTime: shift.startTime,
                          endTime: shift.endTime,
                          totalSales: shift.totalSales,
                          transactionCount: shift.transactionCount,
                          isActive: shift.isActive,
                          openBalance: shift.openBalance,
                          closeBalance: shift.closeBalance,
                          discrepancy: shift.discrepancy,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, _) => _buildErrorCard(
                  'Түүх ачаалахад алдаа гарлаа',
                  () => ref.invalidate(shiftHistoryProvider(storeId)),
                ),
              ),

              AppSpacing.verticalXXL,
            ],
          ),
        ),
      ),
    );
  }

  /// Ээлж нээгдээгүй үеийн card
  Widget _buildNoShiftCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_outlined,
              size: 32,
              color: AppColors.secondary,
            ),
          ),
          AppSpacing.verticalMD,
          const Text(
            'Ээлж нээгдээгүй байна',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
          AppSpacing.verticalSM,
          const Text(
            'Борлуулалт бүртгэхийн тулд ээлж нээнэ үү',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalLG,
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _handleOpenShift(context, ref),
              icon: const Icon(Icons.play_circle_outline, size: 22),
              label: const Text(
                'Ээлж нээх',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMD,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Хоосон түүх
  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: AppColors.gray300),
          AppSpacing.verticalSM,
          const Text(
            'Ээлжийн түүх хоосон байна',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Алдааны card
  Widget _buildErrorCard(String message, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
          AppSpacing.verticalSM,
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMainLight,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSM,
          TextButton(
            onPressed: onRetry,
            child: const Text('Дахин оролдох'),
          ),
        ],
      ),
    );
  }

  /// Ээлж нээх
  Future<void> _handleOpenShift(BuildContext context, WidgetRef ref) async {
    final confirmed = await OpenShiftDialog.show(context);
    if (confirmed != true) return;

    final success =
        await ref.read(shiftActionsProvider.notifier).openShift();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ээлж амжилттай нээгдлээ'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ээлж нээхэд алдаа гарлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Ээлж хаах — мөнгөн тулгалтын дүнг хүлээн авч backend руу дамжуулна
  Future<void> _handleCloseShift(
    BuildContext context,
    WidgetRef ref,
    String storeId,
    String shiftId,
  ) async {
    final shift =
        await ref.read(currentShiftProvider(storeId).future);
    if (shift == null || !context.mounted) return;

    // CloseShiftDialog одоо int? (closeBalance) буцаана, null = цуцалсан
    final closeBalance = await CloseShiftDialog.show(context, shift);
    if (closeBalance == null) return;

    final success = await ref
        .read(shiftActionsProvider.notifier)
        .closeShift(shiftId: shiftId, closeBalance: closeBalance);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ээлж амжилттай хаагдлаа'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ээлж хаахад алдаа гарлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
