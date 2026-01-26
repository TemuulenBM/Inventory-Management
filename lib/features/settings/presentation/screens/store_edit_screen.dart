import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/settings/presentation/providers/store_provider.dart';

/// Дэлгүүрийн мэдээлэл засах дэлгэц
/// Owner: edit боломжтой
/// Manager/Seller: read-only
class StoreEditScreen extends ConsumerStatefulWidget {
  const StoreEditScreen({super.key});

  @override
  ConsumerState<StoreEditScreen> createState() => _StoreEditScreenState();
}

class _StoreEditScreenState extends ConsumerState<StoreEditScreen> {
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final success = await ref.read(storeNotifierProvider.notifier).updateStore(
          name: _nameController.text.trim(),
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Амжилттай - буцах
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Дэлгүүрийн мэдээлэл амжилттай шинэчлэгдлээ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorText = 'Дэлгүүрийн мэдээлэл шинэчлэхэд алдаа гарлаа');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final storeAsync = ref.watch(storeNotifierProvider);
    final isOwner = user?.role == 'owner';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Дэлгүүрийн мэдээлэл',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(
              child: Text('Дэлгүүрийн мэдээлэл олдсонгүй'),
            );
          }

          // Initialize controllers with store data (зөвхөн анхны удаа)
          if (_nameController.text.isEmpty) {
            _nameController.text = store.name;
            _locationController.text = store.location ?? '';
          }

          return SingleChildScrollView(
            padding: AppSpacing.paddingHorizontalLG,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppSpacing.verticalXL,

                  // Store icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                  AppSpacing.verticalXL,

                  // Owner биш бол анхааруулга харуулах
                  if (!isOwner) ...[
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Зөвхөн эзэмшигч дэлгүүрийн мэдээлэл засах боломжтой',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalMD,
                  ],

                  // Дэлгүүрийн нэр
                  TextFormField(
                    controller: _nameController,
                    enabled: isOwner,
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
                      enabled: isOwner,
                    ),
                    style: TextStyle(
                      color: isOwner
                          ? AppColors.textMainLight
                          : AppColors.gray500,
                    ),
                  ),
                  AppSpacing.verticalMD,

                  // Байршил
                  TextFormField(
                    controller: _locationController,
                    enabled: isOwner,
                    decoration: _inputDecoration(
                      label: 'Байршил (заавал биш)',
                      hint: 'Жишээ: БЗД, 3-р хороо',
                      icon: Icons.location_on_outlined,
                      enabled: isOwner,
                    ),
                    style: TextStyle(
                      color: isOwner
                          ? AppColors.textMainLight
                          : AppColors.gray500,
                    ),
                  ),
                  AppSpacing.verticalMD,

                  // Timezone (засах боломжгүй)
                  TextFormField(
                    initialValue: store.timezone,
                    enabled: false,
                    decoration: _inputDecoration(
                      label: 'Цагийн бүс',
                      hint: 'Asia/Ulaanbaatar',
                      icon: Icons.access_time_outlined,
                      enabled: false,
                    ),
                    style: const TextStyle(color: AppColors.gray500),
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

                  AppSpacing.verticalXL,

                  // Хадгалах товч (зөвхөн owner-д харуулах)
                  if (isOwner)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Хадгалах',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              AppSpacing.verticalMD,
              Text(
                'Дэлгүүрийн мэдээлэл татахад алдаа гарлаа',
                style: const TextStyle(color: AppColors.danger),
              ),
              AppSpacing.verticalMD,
              ElevatedButton(
                onPressed: () => ref.invalidate(storeNotifierProvider),
                child: const Text('Дахин оролдох'),
              ),
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
    required bool enabled,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.gray500),
      filled: true,
      fillColor: enabled
          ? AppColors.surfaceVariantLight
          : AppColors.gray100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
