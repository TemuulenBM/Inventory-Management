import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/shifts/domain/shift_model.dart';
import 'package:retail_control_platform/features/shifts/presentation/widgets/inventory_count_sheet.dart';

/// Ээлж хаах dialog-ын буцаах утга
/// closeBalance: кассын бодит мөнгө
/// inventoryCounts: тоолсон бараанууд (сонголттой)
typedef CloseShiftResult = ({
  int closeBalance,
  List<Map<String, dynamic>>? inventoryCounts,
});

/// Ээлж хаах dialog — мөнгөн тулгалт + бараа тоолж тулгах
/// Кассанд байгаа бодит мөнгийг оруулж, хүлээгдэж буй дүнтэй харьцуулна.
/// Зөрүү ихтэй бол warning харуулна.
/// Сонголтоор бараа тоолох боломжтой.
///
/// **Best Practice**: Мөнгөн тулгалт (cash reconciliation) бол жижиглэн
/// худалдааны хяналтын хамгийн чухал хэрэгсэл. Худалдагчийн ээлж бүрийн
/// эцэст бодит кассын мөнгийг тоолж, систем дээрх хүлээгдэж буй дүнтэй
/// харьцуулснаар мөнгөн алдагдлыг шууд илрүүлнэ.
class CloseShiftDialog extends StatefulWidget {
  final ShiftModel shift;

  const CloseShiftDialog({super.key, required this.shift});

  /// Dialog харуулж, CloseShiftResult буцаана. null = цуцалсан
  static Future<CloseShiftResult?> show(
      BuildContext context, ShiftModel shift) {
    return showDialog<CloseShiftResult?>(
      context: context,
      builder: (context) => CloseShiftDialog(shift: shift),
    );
  }

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  /// Бараа тоолгын мэдээлэл (null = тоолоогүй)
  List<Map<String, dynamic>>? _inventoryCounts;

  /// Хүлээгдэж буй мөнгө = нээлтийн үлдэгдэл + бэлэн мөнгөн борлуулалт
  int get _expectedBalance =>
      (widget.shift.openBalance ?? 0) + widget.shift.totalSales.toInt();

  /// Оруулсан closeBalance утга (null = хараахан оруулаагүй)
  int? get _closeBalance {
    final text = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  /// Зөрүү = бодит мөнгө - хүлээгдэж буй мөнгө
  int? get _discrepancy {
    final close = _closeBalance;
    if (close == null) return null;
    return close - _expectedBalance;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(widget.shift.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final numberFormat = NumberFormat('#,###', 'mn');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stop_circle_outlined,
                  size: 32,
                  color: AppColors.danger,
                ),
              ),
              AppSpacing.verticalLG,

              // Гарчиг
              const Text(
                'Ээлж хаах',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalMD,

              // Хураангуй мэдээлэл
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight,
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Ажилтан', widget.shift.sellerName),
                    AppSpacing.verticalSM,
                    _buildSummaryRow('Хугацаа', '${hours}ц ${minutes}мин'),
                    AppSpacing.verticalSM,
                    _buildSummaryRow(
                      'Борлуулалт',
                      '₮${numberFormat.format(widget.shift.totalSales.toInt())}',
                    ),
                    AppSpacing.verticalSM,
                    _buildSummaryRow(
                      'Гүйлгээ',
                      '${widget.shift.transactionCount} удаа',
                    ),
                    if (widget.shift.openBalance != null) ...[
                      AppSpacing.verticalSM,
                      _buildSummaryRow(
                        'Нээлтийн үлдэгдэл',
                        '₮${numberFormat.format(widget.shift.openBalance!)}',
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.verticalLG,

              // Хүлээгдэж буй мөнгө
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Хүлээгдэж буй дүн',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '₮${numberFormat.format(_expectedBalance)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalMD,

              // Кассын бодит мөнгө оруулах input
              TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Кассанд байгаа мөнгө',
                  hintText: '₮0',
                  prefixText: '₮ ',
                  prefixStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              AppSpacing.verticalMD,

              // Зөрүүний мэдээлэл (бодит цагт)
              _buildDiscrepancyInfo(numberFormat),
              AppSpacing.verticalMD,

              const Text(
                'Ээлжийг хаасны дараа шинэ борлуулалт бүртгэгдэхгүй.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalMD,

              // Бараа тоолох товч (сонголттой)
              _buildInventoryCountButton(),
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
                      // closeBalance оруулаагүй бол товч идэвхгүй
                      onPressed: _closeBalance != null
                          ? () => Navigator.of(context).pop((
                                closeBalance: _closeBalance!,
                                inventoryCounts: _inventoryCounts,
                              ))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.gray300,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMD,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Хаах'),
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

  /// Зөрүүний мэдээлэл widget
  /// Бодит цагт closeBalance оруулахад зөрүүг тооцоолж харуулна
  Widget _buildDiscrepancyInfo(NumberFormat numberFormat) {
    final discrepancy = _discrepancy;

    // Хараахан оруулаагүй бол зааварчилгаа харуулна
    if (discrepancy == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: AppRadius.radiusMD,
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: AppColors.gray500),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Кассанд байгаа бодит мөнгийг тоолж оруулна уу',
                style: TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ),
          ],
        ),
      );
    }

    // Зөрүүний түвшин тодорхойлох
    final absDiscrepancy = discrepancy.abs();
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    if (absDiscrepancy == 0) {
      // Тохирч байна
      bgColor = const Color(0xFFEBF5EC);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle;
      message = 'Тохирч байна';
    } else if (absDiscrepancy <= 5000) {
      // Бага зөрүү — мэдээлэл
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1565C0);
      icon = Icons.info;
      message = discrepancy > 0
          ? '₮${numberFormat.format(absDiscrepancy)} илүүдэлтэй'
          : '₮${numberFormat.format(absDiscrepancy)} дутуу';
    } else if (absDiscrepancy <= 20000) {
      // Дунд зөрүү — анхааруулга
      bgColor = const Color(0xFFFFF4E6);
      textColor = const Color(0xFFE65100);
      icon = Icons.warning_amber_rounded;
      message = discrepancy > 0
          ? '₮${numberFormat.format(absDiscrepancy)} илүүдэлтэй'
          : '₮${numberFormat.format(absDiscrepancy)} дутуу';
    } else {
      // Их зөрүү — ноцтой анхааруулга
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
      icon = Icons.error;
      message = discrepancy > 0
          ? '₮${numberFormat.format(absDiscrepancy)} илүүдэлтэй!'
          : '₮${numberFormat.format(absDiscrepancy)} дутуу!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мөнгөн зөрүү',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Бараа тоолох товч + тоологдсон мэдээлэл
  Widget _buildInventoryCountButton() {
    if (_inventoryCounts != null && _inventoryCounts!.isNotEmpty) {
      // Аль хэдийн тоолсон — мэдээлэл харуулна
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5EC),
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          children: [
            const Icon(Icons.inventory_2, size: 20, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_inventoryCounts!.length} бараа тоологдсон',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            // Дахин тоолох
            TextButton(
              onPressed: _openInventoryCountSheet,
              child: const Text(
                'Засах',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Тоолоогүй — товч харуулна
    return TextButton.icon(
      onPressed: _openInventoryCountSheet,
      icon: const Icon(Icons.inventory_2_outlined, size: 18),
      label: const Text('Бараа тоолж тулгах (сонголттой)'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondaryLight,
      ),
    );
  }

  /// Бараа тоолох sheet нээх
  Future<void> _openInventoryCountSheet() async {
    final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InventoryCountSheet(
        storeId: widget.shift.storeId,
      ),
    );

    if (result != null) {
      setState(() => _inventoryCounts = result);
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}
