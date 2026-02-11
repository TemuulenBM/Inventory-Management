import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_model.dart';

/// Барааны хөдөлгөөний event card
/// Timeline item болгон харуулна
/// Дизайн: design/untitled_screen/screen.png
class InventoryEventCard extends StatelessWidget {
  final InventoryEventModel event;
  final VoidCallback? onTap;

  const InventoryEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  /// Event төрлийн өнгө
  Color get _eventColor {
    switch (event.type) {
      case InventoryEventType.initial:
        return AppColors.secondary; // Teal
      case InventoryEventType.sale:
        return AppColors.dangerRed; // Red
      case InventoryEventType.adjust:
        return AppColors.gray600; // Gray
      case InventoryEventType.return_:
        return AppColors.successGreen; // Green
    }
  }

  /// Event төрлийн icon
  IconData get _eventIcon {
    switch (event.type) {
      case InventoryEventType.initial:
        return Icons.inventory_2_outlined;
      case InventoryEventType.sale:
        return Icons.shopping_cart_outlined;
      case InventoryEventType.adjust:
        return Icons.edit_outlined;
      case InventoryEventType.return_:
        return Icons.undo_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Огноо формат
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');

    String dateStr;
    if (event.isToday) {
      dateStr = 'Өнөөдөр, ${timeFormat.format(event.timestamp)}';
    } else if (event.isYesterday) {
      dateStr = 'Өчигдөр, ${timeFormat.format(event.timestamp)}';
    } else {
      dateStr = '${dateFormat.format(event.timestamp)}, ${timeFormat.format(event.timestamp)}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / Icon
              _buildAvatar(),
              AppSpacing.horizontalMD,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event type badge + Actor name
                    Row(
                      children: [
                        // Event type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _eventColor.withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Text(
                            event.type.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _eventColor,
                            ),
                          ),
                        ),
                        AppSpacing.horizontalSM,

                        // Actor name
                        Expanded(
                          child: Text(
                            event.actor.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMainLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalXS,

                    // Timestamp
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),

                    // Product name (хэрэв байвал)
                    if (event.productName != null) ...[
                      AppSpacing.verticalXS,
                      Text(
                        event.productName!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],

                    // Reason (хэрэв байвал)
                    if (event.reason != null && event.reason!.isNotEmpty) ...[
                      AppSpacing.verticalSM,
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ТАЙЛБАР',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _eventColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatReason(event.reason!),
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.gray700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Qty change
              Text(
                event.formattedQty,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Epilogue',
                  color: event.qtyChange >= 0
                      ? AppColors.successGreen
                      : AppColors.dangerRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Raw reason текстийг user-friendly формат руу хөрвүүлэх
  /// "Sale 704cd990-490a-..." → "Борлуулалт #704cd990"
  /// "Void sale 704cd990-..." → "Цуцалсан #704cd990"
  String _formatReason(String reason) {
    if (reason.startsWith('Sale ') && reason.length > 12) {
      final id = reason.substring(5, 13);
      return 'Борлуулалт #$id';
    }
    if (reason.startsWith('Void sale ') && reason.length > 17) {
      final id = reason.substring(10, 18);
      return 'Цуцалсан #$id';
    }
    return reason;
  }

  /// Avatar widget
  Widget _buildAvatar() {
    // Хэрэв avatar URL байвал зураг харуулах
    if (event.actor.avatarUrl != null) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(event.actor.avatarUrl!),
      );
    }

    // Avatar байхгүй бол event type icon харуулах
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _eventColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _eventIcon,
        size: 22,
        color: _eventColor,
      ),
    );
  }
}
