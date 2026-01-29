import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/core/widgets/indicators/sync_status_badge.dart';

/// Sync статусын card
///
/// Current status, last sync time, next auto-sync countdown харуулна
/// Status icon болон text SyncStatus enum-аас хамаарна
class SyncStatusCard extends StatelessWidget {
  final SyncState syncState;

  const SyncStatusCard({super.key, required this.syncState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMainLight,
                      ),
                    ),
                    if (syncState.errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        syncState.errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Last sync time
          SyncInfo(
            isSynced: syncState.status == SyncStatus.synced,
            lastSyncTime: syncState.lastSyncTime,
            isSyncing: syncState.status == SyncStatus.syncing,
          ),

          // Auto-sync info (if online)
          if (syncState.isOnline && syncState.status != SyncStatus.syncing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  'Автомат синк: 5 минут тутам',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Status icon олох (SyncStatus-аас хамаарна)
  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (syncState.status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = AppColors.successGreen;
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = AppColors.primary;
        break;
      case SyncStatus.pendingChanges:
        icon = Icons.cloud_upload;
        color = AppColors.warningOrange;
        break;
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = AppColors.gray500;
        break;
      case SyncStatus.error:
        icon = Icons.error_outline;
        color = AppColors.danger;
        break;
    }

    return Icon(icon, size: 28, color: color);
  }

  /// Status text олох (монгол хэл)
  String _getStatusText() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return 'Синхрончлогдсон';
      case SyncStatus.syncing:
        return 'Синхрончилж байна...';
      case SyncStatus.pendingChanges:
        return 'Хүлээгдэж буй өөрчлөлтүүд';
      case SyncStatus.offline:
        return 'Оффлайн горимд';
      case SyncStatus.error:
        return 'Алдаа гарлаа';
    }
  }
}
