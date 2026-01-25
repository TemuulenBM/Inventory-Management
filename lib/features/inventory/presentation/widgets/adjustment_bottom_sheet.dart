import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/inventory_event_provider.dart';

/// Тохируулга нэмэх bottom sheet
/// FAB дарахад нээгдэнэ
/// Дизайн: design/untitled_screen/screen.png
class AdjustmentBottomSheet extends ConsumerStatefulWidget {
  final String productId;
  final String? productName;

  const AdjustmentBottomSheet({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  ConsumerState<AdjustmentBottomSheet> createState() =>
      _AdjustmentBottomSheetState();
}

class _AdjustmentBottomSheetState extends ConsumerState<AdjustmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isAdding = true; // true = нэмэх, false = хасах

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adjustmentState = ref.watch(adjustmentActionsProvider);
    final isLoading = adjustmentState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.verticalLG,

            // Title
            Row(
              children: [
                const Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 24,
                ),
                AppSpacing.horizontalSM,
                const Text(
                  'Үлдэгдэл тохируулах',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
              ],
            ),

            // Product name (хэрэв байвал)
            if (widget.productName != null) ...[
              AppSpacing.verticalSM,
              Text(
                widget.productName!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
            AppSpacing.verticalLG,

            // Нэмэх/Хасах toggle
            Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Нэмэх',
                    icon: Icons.add,
                    isSelected: _isAdding,
                    color: AppColors.successGreen,
                    onTap: () => setState(() => _isAdding = true),
                  ),
                ),
                AppSpacing.horizontalMD,
                Expanded(
                  child: _ToggleButton(
                    label: 'Хасах',
                    icon: Icons.remove,
                    isSelected: !_isAdding,
                    color: AppColors.dangerRed,
                    onTap: () => setState(() => _isAdding = false),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLG,

            // Тоо хэмжээ input
            TextFormField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Тоо хэмжээ',
                hintText: '0',
                prefixIcon: Icon(
                  _isAdding ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: _isAdding ? AppColors.successGreen : AppColors.dangerRed,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                  borderSide: BorderSide(
                    color: _isAdding ? AppColors.successGreen : AppColors.dangerRed,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Тоо хэмжээ оруулна уу';
                }
                final qty = int.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'Зөв тоо оруулна уу';
                }
                return null;
              },
            ),
            AppSpacing.verticalMD,

            // Шалтгаан input
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Шалтгаан',
                hintText: 'Жишээ: Тооллого, Гэмтэл, Буцаалт, гэх мэт',
                prefixIcon: const Icon(Icons.notes, color: AppColors.gray500),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Шалтгаан оруулна уу';
                }
                return null;
              },
            ),
            AppSpacing.verticalXL,

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isAdding ? AppColors.successGreen : AppColors.dangerRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLG,
                  ),
                  elevation: 0,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isAdding ? Icons.add : Icons.remove),
                label: Text(
                  isLoading
                      ? 'Хадгалж байна...'
                      : (_isAdding ? 'Нэмэх' : 'Хасах'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.parse(_qtyController.text);
    final qtyChange = _isAdding ? qty : -qty;

    final success = await ref
        .read(adjustmentActionsProvider.notifier)
        .createAdjustment(
          productId: widget.productId,
          qtyChange: qtyChange,
          reason: _reasonController.text,
        );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              AppSpacing.horizontalSM,
              const Text('Тохируулга амжилттай хадгалагдлаа'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
    }
  }
}

/// Toggle button for add/remove selection
class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.gray100,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.gray500,
              size: 24,
            ),
            AppSpacing.horizontalSM,
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
