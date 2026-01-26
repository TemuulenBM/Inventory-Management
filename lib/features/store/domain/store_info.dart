/**
 * Store Info Model
 *
 * Multi-store дэмжлэг:
 * - Owner олон дэлгүүртэй байж болно
 * - Дэлгүүр бүр өөрийн нэр, байршил, role-тэй
 * - Backend GET /users/:userId/stores endpoint-оос ирнэ
 */

import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_info.freezed.dart';
part 'store_info.g.dart';

/// Хэрэглэгчийн дэлгүүрийн мэдээлэл
///
/// Backend response format:
/// ```json
/// {
///   "id": "uuid",
///   "name": "Store Name",
///   "location": "Location",
///   "role": "owner"
/// }
/// ```
@freezed
class StoreInfo with _$StoreInfo {
  const factory StoreInfo({
    /// Дэлгүүрийн ID
    required String id,

    /// Дэлгүүрийн нэр
    required String name,

    /// Байршил (nullable)
    String? location,

    /// Хэрэглэгчийн энэ дэлгүүр дэх эрх (owner, manager, seller)
    required String role,
  }) = _StoreInfo;

  /// JSON-аас StoreInfo үүсгэх
  factory StoreInfo.fromJson(Map<String, dynamic> json) =>
      _$StoreInfoFromJson(json);
}
