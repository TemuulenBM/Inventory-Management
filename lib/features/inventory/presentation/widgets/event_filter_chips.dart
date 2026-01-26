import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_model.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/inventory_event_provider.dart';

/// Event filter chips widget
/// Horizontal scroll-тэй filter chips харуулна
/// Дизайн: design/untitled_screen/screen.png
class EventFilterChips extends ConsumerWidget {
  const EventFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(inventoryEventFilterNotifierProvider);
    final notifier = ref.read(inventoryEventFilterNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalMD,
        child: Row(
          children: [
            // Бүгд
            _FilterChip(
              label: 'Бүгд',
              isSelected: filter.eventType == null,
              onTap: () => notifier.setEventType(null),
              selectedColor: AppColors.primary,
            ),
            AppSpacing.horizontalSM,

            // Борлуулалт
            _FilterChip(
              label: 'Борлуулалт',
              icon: Icons.shopping_cart_outlined,
              isSelected: filter.eventType == InventoryEventType.sale,
              onTap: () => notifier.setEventType(InventoryEventType.sale),
              selectedColor: AppColors.dangerRed,
            ),
            AppSpacing.horizontalSM,

            // Буцаалт
            _FilterChip(
              label: 'Буцаалт',
              icon: Icons.undo_outlined,
              isSelected: filter.eventType == InventoryEventType.return_,
              onTap: () => notifier.setEventType(InventoryEventType.return_),
              selectedColor: AppColors.successGreen,
            ),
            AppSpacing.horizontalSM,

            // Тохируулга
            _FilterChip(
              label: 'Тоол',
              icon: Icons.edit_outlined,
              isSelected: filter.eventType == InventoryEventType.adjust,
              onTap: () => notifier.setEventType(InventoryEventType.adjust),
              selectedColor: AppColors.gray600,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? 12 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.gray300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textMainLight,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMainLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
