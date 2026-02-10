import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/transfer/presentation/providers/transfer_provider.dart';

/// Шилжүүлэг үүсгэх дэлгэц
/// 1. Очих салбар сонгох → 2. Бараа сонгох → 3. Баталгаажуулах
class CreateTransferScreen extends ConsumerStatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  ConsumerState<CreateTransferScreen> createState() =>
      _CreateTransferScreenState();
}

class _CreateTransferScreenState extends ConsumerState<CreateTransferScreen> {
  String? _selectedDestStoreId;
  String? _selectedDestStoreName;
  final _notesController = TextEditingController();

  /// Сонгосон бараанууд: { productId: quantity }
  final Map<String, int> _selectedItems = {};

  /// Бараануудын мэдээлэл (UI-д харуулахад)
  final Map<String, ProductWithStock> _productInfoMap = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinationStoresAsync = ref.watch(availableDestinationStoresProvider);
    final productsAsync = ref.watch(productListProvider());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Шилжүүлэг үүсгэх',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 1. Очих салбар =====
            _buildSectionTitle('Очих салбар'),
            const SizedBox(height: AppSpacing.sm),
            destinationStoresAsync.when(
              data: (stores) {
                if (stores.isEmpty) {
                  return _buildInfoCard(
                    'Бусад салбар олдсонгүй',
                    'Шилжүүлэг хийхийн тулд 2+ салбартай байх шаардлагатай.',
                  );
                }
                return _buildStoreSelector(stores);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildInfoCard(
                'Алдаа',
                'Салбарын мэдээлэл авахад алдаа гарлаа',
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ===== 2. Бараа сонгох =====
            _buildSectionTitle('Шилжүүлэх бараа'),
            const SizedBox(height: AppSpacing.sm),
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildInfoCard('Бараа байхгүй', '');
                }
                return _buildProductList(products);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  _buildInfoCard('Алдаа', 'Бараа авахад алдаа гарлаа'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ===== 3. Тэмдэглэл =====
            _buildSectionTitle('Тэмдэглэл (заавал биш)'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Жишээ: Сайн зарагддаг бараа шилжүүлэв',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ===== 4. Баталгаажуулах товч =====
            _buildSubmitSection(),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  /// Салбар сонгох dropdown
  Widget _buildStoreSelector(List<Map<String, String>> stores) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDestStoreId,
          hint: const Text('Салбар сонгох...'),
          items: stores.map((store) {
            return DropdownMenuItem<String>(
              value: store['id'],
              child: Text(store['name'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDestStoreId = value;
              _selectedDestStoreName =
                  stores.firstWhere((s) => s['id'] == value)['name'];
            });
          },
        ),
      ),
    );
  }

  /// Бараа жагсаалт + тоо оруулах
  Widget _buildProductList(List<ProductWithStock> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final product = products[index];
          final qty = _selectedItems[product.id] ?? 0;
          final isSelected = qty > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Бараа мэдээлэл
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      Text(
                        'Үлдэгдэл: ${product.stockQuantity} ш',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.isLowStock
                              ? AppColors.danger
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Тоо нэмэх/хасах товч
                if (isSelected) ...[
                  IconButton(
                    onPressed: () => _updateQuantity(product, qty - 1),
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                    color: AppColors.danger,
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$qty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: qty < product.stockQuantity
                        ? () => _updateQuantity(product, qty + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    color: AppColors.secondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ] else ...[
                  TextButton(
                    onPressed: product.stockQuantity > 0
                        ? () => _updateQuantity(product, 1)
                        : null,
                    child: Text(
                      product.stockQuantity > 0 ? 'Нэмэх' : 'Дууссан',
                      style: TextStyle(
                        fontSize: 13,
                        color: product.stockQuantity > 0
                            ? AppColors.secondary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateQuantity(ProductWithStock product, int newQty) {
    setState(() {
      if (newQty <= 0) {
        _selectedItems.remove(product.id);
        _productInfoMap.remove(product.id);
      } else {
        _selectedItems[product.id] = newQty;
        _productInfoMap[product.id] = product;
      }
    });
  }

  /// Баталгаажуулах хэсэг
  Widget _buildSubmitSection() {
    final canSubmit = _selectedDestStoreId != null && _selectedItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Хураангуй
        if (_selectedItems.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.05),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Шилжүүлгийн хураангуй',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_selectedDestStoreName != null)
                  Text('Очих: $_selectedDestStoreName'),
                const SizedBox(height: AppSpacing.xs),
                ..._selectedItems.entries.map((entry) {
                  final product = _productInfoMap[entry.key];
                  return Text(
                    '• ${product?.name ?? entry.key}: ${entry.value} ш',
                    style: const TextStyle(fontSize: 13),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Товч
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canSubmit && !_isSubmitting ? _submitTransfer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Шилжүүлэг хийх',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitTransfer() async {
    if (_selectedDestStoreId == null || _selectedItems.isEmpty) return;

    setState(() => _isSubmitting = true);

    final items = _selectedItems.entries.map((entry) => {
      'product_id': entry.key,
      'quantity': entry.value,
    }).toList();

    final action = ref.read(createTransferActionProvider.notifier);
    final success = await action.submit(
      destinationStoreId: _selectedDestStoreId!,
      items: items,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Шилжүүлэг амжилттай хийгдлээ!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Шилжүүлэг хийхэд алдаа гарлаа'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
