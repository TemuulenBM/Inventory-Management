import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';

/// Onboarding-д ашиглах хялбар бараа нэмэх form
class SimpleProductForm extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required String sku,
    required double sellPrice,
    double? costPrice,
    int? initialStock,
  }) onSubmit;

  const SimpleProductForm({super.key, required this.onSubmit});

  @override
  State<SimpleProductForm> createState() => _SimpleProductFormState();
}

class _SimpleProductFormState extends State<SimpleProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await widget.onSubmit(
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      sellPrice: double.parse(_priceController.text.trim()),
      initialStock: _stockController.text.isNotEmpty
          ? int.tryParse(_stockController.text.trim())
          : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _nameController.clear();
        _skuController.clear();
        _priceController.clear();
        _stockController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Бараа амжилттай нэмэгдлээ'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Бараа нэмэхэд алдаа гарлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Бараа нэмэх',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMainLight,
              ),
            ),
            AppSpacing.verticalMD,

            // Нэр
            _buildField(
              controller: _nameController,
              label: 'Барааны нэр',
              hint: 'Жишээ: Цагаан будаа 1кг',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Нэр оруулна уу' : null,
            ),
            AppSpacing.verticalSM,

            // SKU + Үнэ
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _skuController,
                    label: 'SKU код',
                    hint: 'BR001',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'SKU оруулна уу' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _priceController,
                    label: 'Зарах үнэ (₮)',
                    hint: '5000',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Үнэ оруулна уу';
                      if (double.tryParse(v) == null) return 'Буруу үнэ';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSM,

            // Үлдэгдэл
            _buildField(
              controller: _stockController,
              label: 'Анхны үлдэгдэл (заавал биш)',
              hint: '100',
              keyboardType: TextInputType.number,
            ),
            AppSpacing.verticalMD,

            // Нэмэх товч
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Нэмж байна...' : 'Бараа нэмэх'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
