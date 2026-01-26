import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/onboarding_page_wrapper.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/simple_product_form.dart';

/// Эхний бараанууд нэмэх дэлгэц
class OnboardingProductsScreen extends ConsumerStatefulWidget {
  final String storeId;

  const OnboardingProductsScreen({super.key, required this.storeId});

  @override
  ConsumerState<OnboardingProductsScreen> createState() =>
      _OnboardingProductsScreenState();
}

class _OnboardingProductsScreenState
    extends ConsumerState<OnboardingProductsScreen> {
  final List<_AddedProduct> _addedProducts = [];

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      currentStep: 1,
      title: 'Бараа нэмэх',
      subtitle: 'Эхний бараануудаа нэмнэ үү. Дараа нэмж болно.',
      onBack: () => context.go(RouteNames.onboardingStoreSetup),
      bottomButton: Column(
        children: [
          // Үргэлжлүүлэх товч
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.go(RouteNames.onboardingInvite, extra: widget.storeId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _addedProducts.isEmpty ? 'Алгасах' : 'Үргэлжлүүлэх',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingHorizontalLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Нэмсэн барааны тоо
            if (_addedProducts.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.successGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_addedProducts.length} бараа нэмэгдлээ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSM,

              // Нэмсэн барааны жагсаалт
              ...List.generate(_addedProducts.length, (index) {
                final product = _addedProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
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
                              ),
                              Text(
                                '${product.sku} • ₮${product.sellPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check, color: AppColors.success, size: 18),
                      ],
                    ),
                  ),
                );
              }),
              AppSpacing.verticalMD,
            ],

            // Бараа нэмэх form
            SimpleProductForm(
              onSubmit: ({
                required String name,
                required String sku,
                required double sellPrice,
                double? costPrice,
                int? initialStock,
              }) async {
                final notifier =
                    ref.read(onboardingNotifierProvider.notifier);
                final success = await notifier.addProduct(
                  name: name,
                  sku: sku,
                  sellPrice: sellPrice,
                  costPrice: costPrice,
                  initialStock: initialStock,
                );
                if (success) {
                  setState(() {
                    _addedProducts.add(_AddedProduct(
                      name: name,
                      sku: sku,
                      sellPrice: sellPrice,
                    ));
                  });
                }
                return success;
              },
            ),
            AppSpacing.verticalLG,
          ],
        ),
      ),
    );
  }
}

/// Нэмсэн барааны мэдээлэл (UI-д харуулахад)
class _AddedProduct {
  final String name;
  final String sku;
  final double sellPrice;

  _AddedProduct({
    required this.name,
    required this.sku,
    required this.sellPrice,
  });
}
