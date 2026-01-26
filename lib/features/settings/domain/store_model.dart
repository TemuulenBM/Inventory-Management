import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

/// Store model - Backend API-аас ирэх дэлгүүрийн мэдээлэл
@freezed
class StoreModel with _$StoreModel {
  const factory StoreModel({
    required String id,
    required String name,
    String? location, // Байршил (заавал биш)
    required String ownerId,
    required String timezone,
    DateTime? createdAt,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);
}
