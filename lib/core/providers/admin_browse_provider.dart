import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

part 'admin_browse_provider.g.dart';

/// Super-admin аль дэлгүүрийг browse хийж байгааг хадгалах
/// Browse mode: super-admin тодорхой дэлгүүрийн бараа, бүртгэлийг read-only харах
@riverpod
class AdminBrowseStore extends _$AdminBrowseStore {
  @override
  String? build() => null;

  /// Дэлгүүр browse хийхээр сонгох
  void browseStore(String storeId) {
    state = storeId;
  }

  /// Browse горимоос гарах
  void clearBrowse() {
    state = null;
  }
}

/// Effective store ID — super-admin browse mode эсвэл ердийн storeId
///
/// Super-admin browse mode: adminBrowseStoreProvider-аас авна
/// Ердийн хэрэглэгч: storeIdProvider-аас авна (user.storeId)
///
/// Store-scoped provider-ууд энэ provider-ийг ашиглана:
/// productListProvider, topSellingProductIdsProvider гэх мэт
@riverpod
String? effectiveStoreId(EffectiveStoreIdRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role == 'super_admin') {
    // Super-admin browse mode
    return ref.watch(adminBrowseStoreProvider);
  }
  // Ердийн хэрэглэгч — auth state-ийн storeId
  return ref.watch(storeIdProvider);
}

/// Read-only mode эсэхийг шалгах
/// Super-admin хэрэглэгч ямагт read-only (бичих үйлдэл хийж чадахгүй)
@riverpod
bool isReadOnlyMode(IsReadOnlyModeRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == 'super_admin';
}
