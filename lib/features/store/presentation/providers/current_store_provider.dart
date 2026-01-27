/**
 * Current Store Provider
 *
 * Одоогийн сонгогдсон дэлгүүрийн мэдээллийг авах provider.
 * userStoresProvider-аас storeId-тай тохирох store-ийг олно.
 * API call давхардуулахгүй, аль хэдийн татсан жагсаалтаас хайна.
 */

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/store/domain/store_info.dart';
import 'package:retail_control_platform/features/store/presentation/providers/user_stores_provider.dart';

part 'current_store_provider.g.dart';

/// Одоогийн сонгогдсон дэлгүүрийн мэдээлэл
///
/// userStoresProvider-аас одоогийн storeId-тай тохирох store-ийг олно.
/// API call давхардуулахгүй - аль хэдийн татаж авсан жагсаалтаас хайна.
///
/// Returns: StoreInfo | null
/// - null: storeId байхгүй эсвэл store олдохгүй
/// - StoreInfo: Одоогийн сонгогдсон дэлгүүрийн мэдээлэл (нэр, байршил, role)
@riverpod
Future<StoreInfo?> currentStore(CurrentStoreRef ref) async {
  // Одоогийн storeId авах
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return null;

  try {
    // userStoresProvider-аас store жагсаалт авах
    // (аль хэдийн API call хийгдсэн, cache-аас авна)
    final stores = await ref.watch(userStoresProvider.future);

    // Одоогийн storeId-тай тохирох store олох
    return stores.firstWhere(
      (store) => store.id == storeId,
      orElse: () => throw StateError('Store not found in user stores list'),
    );
  } catch (e) {
    // Store олдохгүй эсвэл error - null буцаана
    // Super-admin эсвэл store_members-д байхгүй
    return null;
  }
}
