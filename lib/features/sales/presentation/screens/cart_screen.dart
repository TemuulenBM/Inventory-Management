import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/widgets/modals/bottom_action_sheet.dart';
import 'package:retail_control_platform/core/widgets/modals/confirm_dialog.dart';
import 'package:retail_control_platform/features/sales/domain/cart_item.dart';
import 'package:retail_control_platform/features/sales/presentation/providers/cart_provider.dart';

/// Cart Screen (Quick Sale)
/// Сагсны бараа, тоо хэмжээ, checkout flow
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isCheckingOut = false;
  String _paymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Сагс',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () => _handleClearCart(context),
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              label: const Text(
                'Цэвэрлэх',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Stack(
              children: [
                // Сагсны бараануудын жагсаалт
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(item);
                  },
                ),

                // Доод хэсгийн хураангуй + Төлөх товч
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomSummary(
                    totalItems: itemCount,
                    total: total,
                  ),
                ),
              ],
            ),
    );
  }

  /// Сагсны нэг бараа
  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Барааны зураг
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: AppRadius.radiusMD,
            ),
            child: item.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: AppRadius.radiusMD,
                    child: Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inventory_2_outlined,
                        size: 32,
                        color: AppColors.gray400,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: AppColors.gray400,
                  ),
          ),
          const SizedBox(width: 12),

          // Барааны мэдээлэл
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.sku,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.product.sellPrice.toStringAsFixed(0)}₮',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC96F53),
                  ),
                ),
              ],
            ),
          ),

          // Тоо хэмжээ удирдлага
          _buildQuantityControls(item),
        ],
      ),
    );
  }

  /// Тоо хэмжээ +/- удирдлага
  Widget _buildQuantityControls(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Хасах
        Material(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (item.quantity > 1) {
                ref
                    .read(cartNotifierProvider.notifier)
                    .updateQuantity(item.product.id, item.quantity - 1);
              } else {
                ref
                    .read(cartNotifierProvider.notifier)
                    .removeProduct(item.product.id);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                size: 18,
                color: item.quantity == 1
                    ? AppColors.danger
                    : AppColors.textMainLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Тоо
        Column(
          children: [
            Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textMainLight,
              ),
            ),
            Text(
              item.product.unit ?? 'ш',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Нэмэх
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              ref
                  .read(cartNotifierProvider.notifier)
                  .updateQuantity(item.product.id, item.quantity + 1);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// Доод хэсгийн хураангуй
  Widget _buildBottomSummary({
    required int totalItems,
    required double total,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Барааны тоо
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Барааны тоо',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '$totalItems ш',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Нийт дүн
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Нийт дүн',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(0)}₮',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMainLight,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Төлөх товч → PaymentBottomSheet харуулах
            Material(
              color: const Color(0xFF00878F),
              borderRadius: AppRadius.radiusXL,
              elevation: 4,
              shadowColor: const Color(0xFF00878F).withValues(alpha: 0.3),
              child: InkWell(
                onTap: _isCheckingOut ? null : () => _showCheckoutSheet(),
                borderRadius: AppRadius.radiusXL,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Төлөх',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checkout bottom sheet харуулах (PaymentBottomSheet)
  void _showCheckoutSheet() {
    final total = ref.read(cartTotalProvider);

    BottomActionSheet.show<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return PaymentBottomSheet(
            subtotal: total,
            paymentMethod: _paymentMethod,
            onPaymentMethodChanged: (method) {
              setSheetState(() => _paymentMethod = method);
              setState(() => _paymentMethod = method);
            },
            onConfirm: () {
              Navigator.pop(context);
              _processCheckout();
            },
            isProcessing: _isCheckingOut,
          );
        },
      ),
    );
  }

  /// Checkout боловсруулах
  /// Checkout боловсруулах
  Future<void> _processCheckout() async {
    setState(() => _isCheckingOut = true);

    try {
      final saleId = await ref
          .read(checkoutActionsProvider.notifier)
          .checkout(paymentMethod: _paymentMethod);

      if (!mounted) return;
      setState(() => _isCheckingOut = false);

      if (saleId != null) {
        // Амжилттай → SuccessDialog → QuickSaleSelect руу буцах
        await SuccessDialog.show(
          context: context,
          title: 'Борлуулалт амжилттай',
          message: 'Борлуулалт бүртгэгдлээ.',
          buttonText: 'Үргэлжлүүлэх',
        );
        if (mounted) {
          context.go(RouteNames.quickSaleSelect);
        }
      } else {
        // Service error (saleId == null) → ErrorDialog
        await ErrorDialog.show(
          context: context,
          message: 'Борлуулалт бүртгэхэд алдаа гарлаа. Дахин оролдоно уу.',
        );
      }
    } catch (e) {
      // Validation error эсвэл unexpected error → ErrorDialog
      if (!mounted) return;
      setState(() => _isCheckingOut = false);

      await ErrorDialog.show(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Сагс цэвэрлэх (ConfirmDialog-аар баталгаажуулах)
  Future<void> _handleClearCart(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Сагс цэвэрлэх',
      message: 'Сагсан дахь бүх барааг устгах уу?',
      confirmText: 'Цэвэрлэх',
      cancelText: 'Цуцлах',
      isDanger: true,
      icon: Icons.delete_outline,
    );

    if (confirmed == true) {
      ref.read(cartNotifierProvider.notifier).clear();
    }
  }

  /// Хоосон сагс
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.gray300,
          ),
          AppSpacing.verticalMD,
          const Text(
            'Сагс хоосон байна',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalSM,
          const Text(
            'Бараа нэмэхийн тулд буцна уу',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiaryLight,
            ),
          ),
          AppSpacing.verticalLG,
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Бараа сонгох'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
