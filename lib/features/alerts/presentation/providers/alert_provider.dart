import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/services/alert_service.dart';
import 'package:retail_control_platform/features/alerts/domain/alert_model.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

part 'alert_provider.g.dart';

/// AlertService provider
@riverpod
AlertService alertService(AlertServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return AlertService(db: db);
}

/// Alert list with optional filters
/// Offline-first: Local DB эхлээд, background-д API refresh
@riverpod
Future<List<AlertModel>> alertList(
  AlertListRef ref, {
  AlertSeverity? severityFilter,
  AlertType? typeFilter,
  bool? unresolvedOnly,
}) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final service = ref.watch(alertServiceProvider);
  final result = await service.getAlerts(
    storeId,
    severityFilter: severityFilter,
    typeFilter: typeFilter,
    unresolvedOnly: unresolvedOnly,
  );

  return result.when(
    success: (alerts) => alerts,
    error: (_, __, ___) => [],
  );
}

/// Unread alert count (for badge)
@riverpod
Future<int> unreadAlertCount(
  UnreadAlertCountRef ref,
  String storeId,
) async {
  final service = ref.watch(alertServiceProvider);
  final result = await service.getUnreadCount(storeId);

  return result.when(
    success: (count) => count,
    error: (_, __, ___) => 0,
  );
}

/// Alert actions
@riverpod
class AlertActions extends _$AlertActions {
  @override
  FutureOr<void> build() {}

  /// Сэрэмжлүүлэг шийдвэрлэх
  Future<bool> resolve(String alertId) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    if (storeId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(alertServiceProvider);
    final result = await service.resolveAlert(storeId, alertId);

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Invalidate to refresh
        ref.invalidate(alertListProvider);
        ref.invalidate(unreadAlertCountProvider(storeId));
        return true;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }

  /// Сэрэмжлүүлэгийг уншсан гэж тэмдэглэх
  Future<bool> markAsRead(String alertId) async {
    return resolve(alertId);
  }

  /// Сэрэмжлүүлэг хаях
  Future<bool> dismiss(String alertId) async {
    return resolve(alertId);
  }
}
