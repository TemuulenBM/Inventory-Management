import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_model.freezed.dart';
part 'transfer_model.g.dart';

/// Шилжүүлгийн үндсэн мэдээлэл
/// Backend API-аас ирэх response-тэй тохирно
@freezed
class TransferModel with _$TransferModel {
  const TransferModel._();

  const factory TransferModel({
    required String id,
    required TransferStore sourceStore,
    required TransferStore destinationStore,
    required TransferUser initiatedBy,
    required String status,
    String? notes,
    required List<TransferItemModel> items,
    required String createdAt,
    String? completedAt,
  }) = _TransferModel;

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);

  /// Шилжүүлэг дууссан эсэх
  bool get isCompleted => status == 'completed';

  /// Шилжүүлэг цуцлагдсан эсэх
  bool get isCancelled => status == 'cancelled';

  /// Шилжүүлэг хүлээгдэж буй эсэх
  bool get isPending => status == 'pending';

  /// Нийт бараа тоо
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

/// Шилжүүлэгтэй холбоотой салбар
@freezed
class TransferStore with _$TransferStore {
  const factory TransferStore({
    required String id,
    required String name,
  }) = _TransferStore;

  factory TransferStore.fromJson(Map<String, dynamic> json) =>
      _$TransferStoreFromJson(json);
}

/// Шилжүүлэг эхлүүлсэн хэрэглэгч
@freezed
class TransferUser with _$TransferUser {
  const factory TransferUser({
    required String id,
    required String name,
  }) = _TransferUser;

  factory TransferUser.fromJson(Map<String, dynamic> json) =>
      _$TransferUserFromJson(json);
}

/// Шилжүүлгийн бараа (тоо ширхэгтэй)
@freezed
class TransferItemModel with _$TransferItemModel {
  const factory TransferItemModel({
    required String id,
    required String productId,
    required String productName,
    required int quantity,
  }) = _TransferItemModel;

  factory TransferItemModel.fromJson(Map<String, dynamic> json) =>
      _$TransferItemModelFromJson(json);
}
