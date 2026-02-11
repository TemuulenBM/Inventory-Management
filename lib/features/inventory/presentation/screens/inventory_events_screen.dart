import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/sync/sync_provider.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/inventory_event_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/widgets/adjustment_bottom_sheet.dart';
import 'package:retail_control_platform/features/inventory/presentation/widgets/event_filter_chips.dart';
import 'package:retail_control_platform/features/inventory/presentation/widgets/inventory_event_card.dart';

/// Барааны хөдөлгөөний түүх дэлгэц
/// productId байвал тухайн барааны түүх, байхгүй бол бүх түүх харуулна
/// Дизайн: design/untitled_screen/screen.png
class InventoryEventsScreen extends ConsumerWidget {
  /// Тодорхой барааны түүх харуулах бол productId өгнө
  /// Bottom nav-аас ирвэл null байна (бүх түүх)
  final String? productId;

  const InventoryEventsScreen({
    super.key,
    this.productId,
  });

  /// Тодорхой бараа эсэх
  bool get isSpecificProduct => productId != null && productId!.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Тодорхой бараа бол productDetailProvider, үгүй бол null
    final productAsync = isSpecificProduct
        ? ref.watch(productDetailProvider(productId!))
        : const AsyncValue<dynamic>.data(null);

    // Тодорхой бараа бол productInventoryEventsProvider, үгүй бол allInventoryEventsProvider
    final eventsAsync = isSpecificProduct
        ? ref.watch(productInventoryEventsProvider(productId!))
        : ref.watch(allInventoryEventsProvider);

    final filter = ref.watch(inventoryEventFilterNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // Back товч зөвхөн тодорхой бараанаас ирсэн үед харагдана
        leading: isSpecificProduct
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: false,
        title: const Text(
          'Барааны хөдөлгөөн',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: true,
        actions: [
          // Sync status (динамик)
          _buildSyncBadge(ref),
        ],
      ),
      body: Column(
        children: [
          // Product header
          productAsync.when(
            data: (product) => product != null
                ? _ProductHeader(
                    name: product.name,
                    sku: product.sku,
                    currentStock: product.stockQuantity,
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Filter section
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Date filter button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Date picker button
                      InkWell(
                        onTap: () => _showDatePicker(context, ref),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                filter.hasDateRange
                                    ? _formatDateRange(filter.startDate, filter.endDate)
                                    : 'Бүх огноо',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMainLight,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.expand_more,
                                size: 18,
                                color: AppColors.gray500,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Total summary
                      eventsAsync.when(
                        data: (events) {
                          final total = events.fold<int>(
                            0,
                            (sum, e) => sum + e.qtyChange,
                          );
                          return Text(
                            'Нийт: ${total >= 0 ? '+$total' : total} ш',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                const EventFilterChips(),
              ],
            ),
          ),

          // Active date filter indicator
          if (filter.hasDateRange)
            _DateFilterIndicator(
              startDate: filter.startDate,
              endDate: filter.endDate,
              onClear: () {
                ref
                    .read(inventoryEventFilterNotifierProvider.notifier)
                    .clearDateFilter();
              },
            ),

          // Events list with pull-to-refresh
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const _EmptyState();
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    // Provider-г invalidate хийж дахин татах
                    if (isSpecificProduct) {
                      ref.invalidate(productInventoryEventsProvider(productId!));
                    } else {
                      ref.invalidate(allInventoryEventsProvider);
                    }
                  },
                  child: ListView.builder(
                    padding: AppSpacing.paddingMD,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return InventoryEventCard(event: events[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, _) => _ErrorState(error: error.toString()),
            ),
          ),
        ],
      ),
      // FAB зөвхөн тодорхой бараа үед харагдана (adjustment бол productId шаардлагатай)
      floatingActionButton: isSpecificProduct
          ? FloatingActionButton.extended(
              onPressed: () => _showAdjustmentSheet(context, ref),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text(
                'Тохируулга',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(inventoryEventFilterNotifierProvider);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filter.hasDateRange
          ? DateTimeRange(
              start: filter.startDate!,
              end: filter.endDate ?? DateTime.now(),
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textMainLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(inventoryEventFilterNotifierProvider.notifier)
          .setDateRange(picked.start, picked.end);
    }
  }

  void _showAdjustmentSheet(BuildContext context, WidgetRef ref) {
    // productId байхгүй бол FAB харагдахгүй тул энд орохгүй
    if (productId == null) return;

    final product = ref.read(productDetailProvider(productId!)).valueOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AdjustmentBottomSheet(
        productId: productId!,
        productName: product?.name,
      ),
    );
  }

  /// Динамик sync badge — бодит sync төлөв
  Widget _buildSyncBadge(WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    final status = syncState.status;

    Color dotColor;
    Color bgColor;
    IconData icon;

    switch (status) {
      case SyncStatus.synced:
        dotColor = const Color(0xFF059669);
        bgColor = const Color(0xFFDCFCE7);
        icon = Icons.cloud_done;
      case SyncStatus.syncing:
        dotColor = const Color(0xFF1976D2);
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.sync;
      case SyncStatus.pendingChanges:
        dotColor = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF4E6);
        icon = Icons.cloud_upload;
      case SyncStatus.offline:
        dotColor = const Color(0xFF757575);
        bgColor = const Color(0xFFF5F5F5);
        icon = Icons.cloud_off;
      case SyncStatus.error:
        dotColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.error_outline;
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 20,
        color: dotColor,
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final format = DateFormat('MM/dd');
    if (start == null) return 'Өнөөдөр';
    if (end == null) return format.format(start);
    return '${format.format(start)} - ${format.format(end)}';
  }
}

/// Product header widget
class _ProductHeader extends StatelessWidget {
  final String name;
  final String sku;
  final int currentStock;

  const _ProductHeader({
    required this.name,
    required this.sku,
    required this.currentStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Epilogue',
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sku,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          // Current stock badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$currentStock ш',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Date filter indicator
class _DateFilterIndicator extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onClear;

  const _DateFilterIndicator({
    this.startDate,
    this.endDate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MM/dd');
    final dateText = startDate != null && endDate != null
        ? '${format.format(startDate!)} - ${format.format(endDate!)}'
        : startDate != null
            ? format.format(startDate!)
            : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.date_range,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
          AppSpacing.verticalLG,
          const Text(
            'Түүх байхгүй',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
          AppSpacing.verticalSM,
          const Text(
            'Энэ барааны хөдөлгөөн хараахан бүртгэгдээгүй байна',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.errorBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.dangerRed,
            ),
          ),
          AppSpacing.verticalLG,
          const Text(
            'Алдаа гарлаа',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
          AppSpacing.verticalSM,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
