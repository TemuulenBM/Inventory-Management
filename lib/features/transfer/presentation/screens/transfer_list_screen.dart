import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/transfer/domain/models/transfer_model.dart';
import 'package:retail_control_platform/features/transfer/presentation/providers/transfer_provider.dart';

/// Шилжүүлгийн жагсаалт дэлгэц
/// Бүх incoming/outgoing шилжүүлгүүдийг харуулна
class TransferListScreen extends ConsumerWidget {
  const TransferListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(transferListProvider);
    final currentStoreId = ref.watch(storeIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Бараа шилжүүлэг',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.createTransfer),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        label: const Text(
          'Шилжүүлэг',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: transfersAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transferListProvider),
            child: ListView.separated(
              padding: AppSpacing.paddingMD,
              itemCount: transfers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _TransferCard(
                  transfer: transfers[index],
                  currentStoreId: currentStoreId ?? '',
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text('Алдаа: $error', textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(transferListProvider),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Шилжүүлэг байхгүй',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Салбар хооронд бараа шилжүүлэхийн тулд\n"Шилжүүлэг" товчийг дарна уу',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// Шилжүүлгийн карт
class _TransferCard extends StatelessWidget {
  final TransferModel transfer;
  final String currentStoreId;

  const _TransferCard({
    required this.transfer,
    required this.currentStoreId,
  });

  @override
  Widget build(BuildContext context) {
    // Одоогийн салбараас шилжүүлсэн эсвэл хүлээн авсан эсэхийг тодорхойлох
    final isOutgoing = transfer.sourceStore.id == currentStoreId;
    final directionIcon = isOutgoing ? Icons.arrow_forward : Icons.arrow_back;
    final directionColor = isOutgoing ? AppColors.warningOrange : AppColors.successGreen;
    final directionLabel = isOutgoing ? 'Илгээсэн' : 'Хүлээн авсан';
    final otherStore = isOutgoing
        ? transfer.destinationStore.name
        : transfer.sourceStore.name;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Толгой мөр: чиглэл + статус
          Row(
            children: [
              Icon(directionIcon, size: 20, color: directionColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$directionLabel → $otherStore',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
              ),
              _StatusBadge(status: transfer.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Бараа мэдээлэл
          Text(
            '${transfer.totalItems} ширхэг бараа (${transfer.items.length} төрөл)',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          // Бараануудын нэрс
          if (transfer.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              transfer.items.map((i) => '${i.productName} ×${i.quantity}').join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Тэмдэглэл
          if (transfer.notes != null && transfer.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '📝 ${transfer.notes}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Огноо + хэн
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                transfer.initiatedBy.name,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                _formatDate(transfer.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}

/// Статус badge
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'completed':
        bgColor = AppColors.successGreen.withValues(alpha: 0.1);
        textColor = AppColors.successGreen;
        label = 'Дууссан';
        break;
      case 'cancelled':
        bgColor = AppColors.danger.withValues(alpha: 0.1);
        textColor = AppColors.danger;
        label = 'Цуцалсан';
        break;
      default:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warningOrange;
        label = 'Хүлээгдэж буй';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusSM,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
