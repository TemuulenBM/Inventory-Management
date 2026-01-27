import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';

/// Шинэ категори нэмэх dialog
/// Хэрэглэгч өөрийн категори үүсгэх боломжтой
class CustomCategoryDialog extends StatefulWidget {
  const CustomCategoryDialog({super.key});

  /// Dialog харуулж, категорийн нэр буцаана (эсвэл null хэрвээ цуцалбал)
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const CustomCategoryDialog(),
    );
  }

  @override
  State<CustomCategoryDialog> createState() => _CustomCategoryDialogState();
}

class _CustomCategoryDialogState extends State<CustomCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_categoryController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.verticalLG,

              // Гарчиг
              const Text(
                'Шинэ категори нэмэх',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalMD,

              // Тайлбар
              const Text(
                'Та өөрийн категори үүсгэж, барааг ангилах боломжтой.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalLG,

              // Категорийн нэр TextField
              TextFormField(
                controller: _categoryController,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Категорийн нэр',
                  hintText: 'жнь: Эм, Ном, Хувцас гэх мэт',
                  prefixIcon: const Icon(Icons.category_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                    borderSide: const BorderSide(
                      color: Color(0xFFDC2626),
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                    borderSide: const BorderSide(
                      color: Color(0xFFDC2626),
                      width: 2,
                    ),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Категорийн нэр оруулна уу';
                  }
                  if (value.trim().length > 100) {
                    return 'Категорийн нэр 100 тэмдэгтээс бага байх ёстой';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              AppSpacing.verticalXL,

              // Товчнууд
              Row(
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Цуцлах'),
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMD,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Нэмэх'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
