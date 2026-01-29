import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/sync/sync_provider.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/features/sync/presentation/providers/pending_operations_provider.dart';
import 'package:retail_control_platform/features/sync/presentation/widgets/sync_status_card.dart';
import 'package:retail_control_platform/features/sync/presentation/widgets/manual_sync_button.dart';
import 'package:retail_control_platform/features/sync/presentation/widgets/pending_operations_list.dart';
import 'package:retail_control_platform/features/sync/presentation/widgets/failed_operation_card.dart';

/// Синк дэлгэц
///
/// Sync status, pending operations, failed operations харуулах
/// Settings > Синк tile-ээс хандах боломжтой
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    final pendingAsync = ref.watch(pendingSyncOperationsProvider);
    final failedAsync = ref.watch(failedSyncOperationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Синк',
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
          ref.invalidate(pendingSyncOperationsProvider);
          ref.invalidate(failedSyncOperationsProvider);
          await ref.read(syncNotifierProvider.notifier).sync();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Status Card =====
              SyncStatusCard(syncState: syncState),
              AppSpacing.verticalLG,

              // ===== Manual Sync Button =====
              ManualSyncButton(
                isLoading: syncState.status == SyncStatus.syncing,
                onPressed: () async {
                  await ref.read(syncNotifierProvider.notifier).sync();
                },
              ),
              AppSpacing.verticalLG,

              // ===== Pending Operations Section =====
              if (syncState.pendingCount > 0) ...[
                _buildSectionHeader(
                  '${syncState.pendingCount} өөрчлөлт хүлээгдэж байна',
                  Icons.sync_outlined,
                ),
                AppSpacing.verticalMD,
                pendingAsync.when(
                  data: (operations) => PendingOperationsList(
                    operations: operations,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, _) => _buildErrorCard(error.toString()),
                ),
                AppSpacing.verticalLG,
              ],

              // ===== Failed Operations Section =====
              failedAsync.when(
                data: (failedOps) {
                  if (failedOps.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        '${failedOps.length} алдаатай үйлдэл',
                        Icons.error_outline,
                        color: AppColors.danger,
                      ),
                      AppSpacing.verticalMD,
                      ...failedOps.map((op) => FailedOperationCard(operation: op)),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ===== Empty State =====
              if (syncState.pendingCount == 0) ...[
                _buildEmptyState(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Section header widget
  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  /// Empty state widget (pending count == 0)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.cloud_done,
            size: 80,
            color: AppColors.gray300,
          ),
          AppSpacing.verticalMD,
          const Text(
            'Бүх өөрчлөлт синхрончлогдсон',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Error card widget
  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.danger,
        ),
      ),
    );
  }
}
