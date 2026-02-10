import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

/// Shift model (seller work session)
@freezed
class ShiftModel with _$ShiftModel {
  const ShiftModel._();

  const factory ShiftModel({
    required String id,
    required String sellerId,
    required String sellerName,
    required String storeId,
    required DateTime startTime,
    DateTime? endTime,
    required double totalSales,
    required int transactionCount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    /// Ээлж эхлэх мөнгө
    int? openBalance,
    /// Ээлж хаах мөнгө (бодит тоолсон)
    int? closeBalance,
    /// Хүлээгдэж буй мөнгө (open_balance + cash борлуулалт)
    int? expectedBalance,
    /// Мөнгөн зөрүү (close_balance - expected_balance)
    int? discrepancy,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);

  /// Check if shift is currently active
  bool get isActive => endTime == null;

  /// Calculate shift duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Format duration as "Xц Yмин"
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}ц ${minutes}мин';
  }

  /// Мөнгөн зөрүү байгаа эсэх (₮5,000-с дээш)
  bool get hasDiscrepancy =>
      discrepancy != null && discrepancy!.abs() > 5000;

  /// Зөрүү эерэг бол илүүдэлтэй, сөрөг бол дутуу
  String get discrepancyLabel {
    if (discrepancy == null || discrepancy == 0) return 'Тохирч байна';
    if (discrepancy! > 0) return 'Илүүдэлтэй';
    return 'Дутуу';
  }
}
