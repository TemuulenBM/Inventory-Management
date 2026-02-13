import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

/// Бараа тоолох BottomSheet
/// Ээлж хаах үед кассанд байгаа барааг тоолж, системтэй тулгана.
/// Зөвхөн тоо оруулсан бараануудыг буцаана.
///
/// Буцаах утга: List<Map<String, dynamic>> — [{product_id, physical_count}]
class InventoryCountSheet extends ConsumerStatefulWidget {
  final String storeId;

  const InventoryCountSheet({super.key, required this.storeId});

  @override
  ConsumerState<InventoryCountSheet> createState() =>
      _InventoryCountSheetState();
}

class _InventoryCountSheetState extends ConsumerState<InventoryCountSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// Бараа бүрийн тоолсон тоо хадгалах (productId -> count)
  final Map<String, int> _counts = {};

  /// TextField controller-уудыг productId-аар хадгалах
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider());

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.verticalMD,

          // Гарчиг
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Бараа тоолох',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      Text(
                        'Бодит тоог оруулж системтэй тулгана',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalMD,

          // Хайлт
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Бараа хайх...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiaryLight,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          AppSpacing.verticalSM,

          // Тоолсон тоо
          if (_counts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16,
                        color: AppColors.secondary.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      '${_counts.length} бараа тоологдсон',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AppSpacing.verticalSM,

          // Барааны жагсаалт
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _filterProducts(products);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: AppColors.gray300),
                        AppSpacing.verticalSM,
                        Text(
                          _searchQuery.isNotEmpty
                              ? '"$_searchQuery" олдсонгүй'
                              : 'Бараа байхгүй',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _buildProductRow(filtered[index]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Бараа ачаалахад алдаа гарлаа',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ),

          // Доод товчнууд
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMainLight,
                      side: const BorderSide(color: AppColors.gray300),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Алгасах'),
                  ),
                ),
                AppSpacing.horizontalMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: _counts.isNotEmpty ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.gray300,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _counts.isNotEmpty
                          ? 'Хадгалах (${_counts.length})'
                          : 'Хадгалах',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Хайлтын үр дүнгээр бараа шүүх
  List<ProductWithStock> _filterProducts(List<ProductWithStock> products) {
    if (_searchQuery.isEmpty) return products;
    final q = _searchQuery.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q))
        .toList();
  }

  /// Нэг барааны мөр
  Widget _buildProductRow(ProductWithStock product) {
    // Controller авах эсвэл шинэ үүсгэх
    final controller = _controllers.putIfAbsent(
      product.id,
      () => TextEditingController(),
    );

    final physicalCount = _counts[product.id];
    final discrepancy =
        physicalCount != null ? physicalCount - product.stockQuantity : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Барааны мэдээлэл
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      product.sku,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Системийн тоо
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Систем: ${product.stockQuantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Тоолсон тоо оруулах
          SizedBox(
            width: 72,
            height: 40,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '-',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _counts.remove(product.id);
                  } else {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      _counts[product.id] = parsed;
                    }
                  }
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          // Зөрүү харуулах
          SizedBox(
            width: 48,
            child: discrepancy != null
                ? Text(
                    discrepancy == 0
                        ? '='
                        : discrepancy > 0
                            ? '+$discrepancy'
                            : '$discrepancy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: discrepancy == 0
                          ? const Color(0xFF2E7D32)
                          : discrepancy.abs() <= 2
                              ? const Color(0xFFE65100)
                              : const Color(0xFFC62828),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Хадгалах — тоолсон бараануудыг буцаана
  void _handleSave() {
    final result = _counts.entries
        .map((e) => {
              'product_id': e.key,
              'physical_count': e.value,
            })
        .toList();

    Navigator.of(context).pop(result);
  }
}
