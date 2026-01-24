import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

part 'store_provider.g.dart';

/// StoreId provider - Одоогийн хэрэглэгчийн store ID-г авах
/// Auth state-аас автоматаар авна
@riverpod
String? storeId(StoreIdRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.storeId;
}

/// Required StoreId provider - StoreId байхгүй бол exception throw хийнэ
/// Store-тэй холбоотой бүх provider-уудад ашиглана
@riverpod
String requireStoreId(RequireStoreIdRef ref) {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) {
    throw StateError('Store ID шаардлагатай боловч хэрэглэгч нэвтрээгүй байна');
  }
  return storeId;
}

/// Current user ID provider
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
}

/// Required user ID provider
@riverpod
String requireUserId(RequireUserIdRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    throw StateError('User ID шаардлагатай боловч хэрэглэгч нэвтрээгүй байна');
  }
  return userId;
}
