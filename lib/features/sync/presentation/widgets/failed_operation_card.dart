import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/features/sync/presentation/providers/sync_actions_provider.dart';

/// Failed үйлдлийн card (retry/delete buttons-тай)
///
/// PendingOperationCard-тай адил layout, гэхдээ:
/// - Error message display (red background)
/// - Retry button
/// - Delete button (confirm dialog-тай)
class FailedOperationCard extends ConsumerWidget {
  final SyncQueueData operation;

  const FailedOperationCard({super.key, required this.operation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityIcon = _getEntityIcon(operation.entityType);
    final entityLabel = _translateEntityType(operation.entityType);
    final operationLabel = _translateOperation(operation.operation);
    final description = _getOperationDescription(operation);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header (entity + operation)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(entityIcon, size: 20, color: AppColors.danger),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$entityLabel • $operationLabel',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(operation.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Error message
          if (operation.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      operation.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.danger,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final success = await ref
                        .read(syncActionsProvider.notifier)
                        .retryOperation(operation.id);

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Дахин оролдож байна...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Дахин'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await _showDeleteConfirm(context);
                    if (confirmed == true) {
                      final success = await ref
                          .read(syncActionsProvider.notifier)
                          .deleteOperation(operation.id);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Устгагдлаа'),
                            backgroundColor: AppColors.gray600,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Устгах'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Delete confirm dialog харуулах
  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Устгах уу?'),
        content: const Text('Энэ үйлдлийг queue-аас бүрмөсөн устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Цуцлах'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
  }

  // Helper methods (PendingOperationCard-тай адил)
  IconData _getEntityIcon(String entityType) {
    switch (entityType) {
      case 'product':
        return Icons.inventory_2_outlined;
      case 'sale':
        return Icons.shopping_cart_outlined;
      case 'inventory_event':
        return Icons.swap_vert;
      case 'shift':
        return Icons.access_time_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _translateEntityType(String entityType) {
    switch (entityType) {
      case 'product':
        return 'Бараа';
      case 'sale':
        return 'Борлуулалт';
      case 'inventory_event':
        return 'Үлдэгдэл';
      case 'shift':
        return 'Ээлж';
      default:
        return entityType;
    }
  }

  String _translateOperation(String operation) {
    switch (operation) {
      case 'create':
      case 'create_sale':
      case 'create_product':
        return 'Шинээр нэмсэн';
      case 'update':
      case 'update_product':
        return 'Засварласан';
      case 'delete':
        return 'Устгасан';
      case 'open_shift':
        return 'Нээсэн';
      case 'close_shift':
        return 'Хаасан';
      default:
        return operation;
    }
  }

  String? _getOperationDescription(SyncQueueData operation) {
    try {
      final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

      if (payload['name'] != null) {
        return payload['name'] as String;
      }

      if (payload['total_amount'] != null) {
        return '₮${payload['total_amount']}';
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}м өмнө';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}ц өмнө';
    } else {
      return '${diff.inDays} өдрийн өмнө';
    }
  }
}
