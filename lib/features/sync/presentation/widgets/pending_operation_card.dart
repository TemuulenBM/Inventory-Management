import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/database/app_database.dart';

/// Нэг pending үйлдлийн card
///
/// Entity icon, operation translation, description, timestamp харуулна
/// Retry count badge (if retryCount > 0)
class PendingOperationCard extends StatelessWidget {
  final SyncQueueData operation;

  const PendingOperationCard({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final entityIcon = _getEntityIcon(operation.entityType);
    final entityLabel = _translateEntityType(operation.entityType);
    final operationLabel = _translateOperation(operation.operation);
    final description = _getOperationDescription(operation);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Entity icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(entityIcon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Content
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

          // Retry count badge (if > 0)
          if (operation.retryCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${operation.retryCount} оролдлого',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warningOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Entity type-аас icon олох
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

  /// Entity type монголоор орчуулах
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

  /// Operation монголоор орчуулах
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

  /// JSON payload-аас description гаргаж авах
  ///
  /// Try-catch ашиглаж safe parsing хийнэ
  /// Malformed JSON байвал null return хийж, crash хийхгүй
  String? _getOperationDescription(SyncQueueData operation) {
    try {
      final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

      // Product name
      if (payload['name'] != null) {
        return payload['name'] as String;
      }

      // Sale total
      if (payload['total_amount'] != null) {
        return '₮${payload['total_amount']}';
      }

      return null;
    } catch (e) {
      // JSON parsing алдаа - null return
      return null;
    }
  }

  /// Timestamp-ыг relative format руу хөрвүүлэх
  ///
  /// "5м өмнө", "1ц өмнө", "2 өдрийн өмнө"
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
