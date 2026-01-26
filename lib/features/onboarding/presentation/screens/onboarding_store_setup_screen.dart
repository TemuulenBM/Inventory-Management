import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/onboarding_page_wrapper.dart';

/// Store тохиргоо дэлгэц
/// Дэлгүүрийн нэр, байршил оруулах
class OnboardingStoreSetupScreen extends ConsumerStatefulWidget {
  const OnboardingStoreSetupScreen({super.key});

  @override
  ConsumerState<OnboardingStoreSetupScreen> createState() =>
      _OnboardingStoreSetupScreenState();
}

class _OnboardingStoreSetupScreenState
    extends ConsumerState<OnboardingStoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final success = await notifier.createStore(
      name: _nameController.text.trim(),
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final storeId = notifier.storeId;
        context.go(RouteNames.onboardingProducts, extra: storeId);
      } else {
        setState(() => _errorText = 'Дэлгүүр үүсгэхэд алдаа гарлаа');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      currentStep: 0,
      title: 'Дэлгүүрийн мэдээлэл',
      subtitle: 'Дэлгүүрийнхээ нэр, байршлыг оруулна уу',
      onBack: () => context.go(RouteNames.onboardingWelcome),
      bottomButton: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Үргэлжлүүлэх',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingHorizontalLG,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Store icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              AppSpacing.verticalXL,

              // Дэлгүүрийн нэр
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Дэлгүүрийн нэр оруулна уу';
                  }
                  return null;
                },
                decoration: _inputDecoration(
                  label: 'Дэлгүүрийн нэр',
                  hint: 'Жишээ: Номин маркет',
                  icon: Icons.storefront_outlined,
                ),
              ),
              AppSpacing.verticalMD,

              // Байршил
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration(
                  label: 'Байршил (заавал биш)',
                  hint: 'Жишээ: БЗД, 3-р хороо',
                  icon: Icons.location_on_outlined,
                ),
              ),

              // Алдааны текст
              if (_errorText != null) ...[
                AppSpacing.verticalMD,
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.gray500),
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
