import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_event_model.freezed.dart';
part 'inventory_event_model.g.dart';

/// Барааны хөдөлгөөний төрөл
/// Backend-тэй нийцтэй: INITIAL, SALE, ADJUST, RETURN
@JsonEnum(valueField: 'value')
enum InventoryEventType {
  initial('INITIAL'),
  sale('SALE'),
  adjust('ADJUST'),
  return_('RETURN');

  const InventoryEventType(this.value);
  final String value;

  /// String-ээс enum руу хөрвүүлэх
  static InventoryEventType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INITIAL':
        return InventoryEventType.initial;
      case 'SALE':
        return InventoryEventType.sale;
      case 'ADJUST':
        return InventoryEventType.adjust;
      case 'RETURN':
        return InventoryEventType.return_;
      default:
        return InventoryEventType.adjust;
    }
  }

  /// Монгол нэр
  String get label {
    switch (this) {
      case InventoryEventType.initial:
        return 'Анхны үлдэгдэл';
      case InventoryEventType.sale:
        return 'Борлуулалт';
      case InventoryEventType.adjust:
        return 'Тохируулга';
      case InventoryEventType.return_:
        return 'Буцаалт';
    }
  }
}

/// Хэрэглэгчийн товч мэдээлэл (event-д хамааралтай)
@freezed
class EventActor with _$EventActor {
  const factory EventActor({
    required String id,
    required String name,
    String? avatarUrl,
  }) = _EventActor;

  factory EventActor.fromJson(Map<String, dynamic> json) =>
      _$EventActorFromJson(json);
}

/// Барааны хөдөлгөөний event model
/// Event Sourcing pattern: Бүх өөрчлөлтийг immutable event хэлбэрээр хадгална
@freezed
class InventoryEventModel with _$InventoryEventModel {
  const InventoryEventModel._();

  const factory InventoryEventModel({
    required String id,
    required String storeId,
    required String productId,
    required InventoryEventType type,
    required int qtyChange,
    required DateTime timestamp,
    required EventActor actor,
    String? productName,
    String? shiftId,
    String? reason,
  }) = _InventoryEventModel;

  factory InventoryEventModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryEventModelFromJson(json);

  /// API response-оос model үүсгэх (backend format)
  factory InventoryEventModel.fromApiResponse(Map<String, dynamic> json) {
    // actorName байхгүй бол "Хэрэглэгч" гэж харуулна
    final actorName = json['actorName'] as String?;
    final displayName = (actorName != null && actorName.isNotEmpty)
        ? actorName
        : 'Хэрэглэгч';

    return InventoryEventModel(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      productId: json['productId'] as String,
      type: InventoryEventType.fromString(json['eventType'] as String),
      qtyChange: json['qtyChange'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actor: EventActor(
        id: json['actorId'] as String,
        name: displayName,
        avatarUrl: null,
      ),
      productName: json['productName'] as String?,
      shiftId: json['shiftId'] as String?,
      reason: json['reason'] as String?,
    );
  }

  /// Тоо хэмжээ форматтай текст (+10 эсвэл -5)
  String get formattedQty {
    if (qtyChange >= 0) return '+$qtyChange';
    return '$qtyChange';
  }

  /// Өнөөдөр үү шалгах
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Өчигдөр үү шалгах
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;
  }
}
