import 'package:freezed_annotation/freezed_annotation.dart';
import 'inventory_event_model.dart';

part 'inventory_event_filter.freezed.dart';

/// Барааны хөдөлгөөний filter state
/// Riverpod provider-т ашиглагдана
@freezed
class InventoryEventFilter with _$InventoryEventFilter {
  const InventoryEventFilter._();

  const factory InventoryEventFilter({
    /// Event төрлөөр шүүх (null = бүгд)
    InventoryEventType? eventType,

    /// Эхлэх огноо
    DateTime? startDate,

    /// Дуусах огноо
    DateTime? endDate,

    /// Хуудас (pagination)
    @Default(1) int page,

    /// Хуудас бүрт хэдэн бичлэг
    @Default(20) int limit,
  }) = _InventoryEventFilter;

  /// Filter идэвхтэй эсэх (ямар нэгэн filter тохируулсан)
  bool get hasActiveFilter =>
      eventType != null || startDate != null || endDate != null;

  /// Date range идэвхтэй эсэх
  bool get hasDateRange => startDate != null || endDate != null;

  /// Query parameters хэлбэрт хөрвүүлэх (API дуудлагад)
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (eventType != null) {
      params['eventType'] = eventType!.value;
    }
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    return params;
  }
}
