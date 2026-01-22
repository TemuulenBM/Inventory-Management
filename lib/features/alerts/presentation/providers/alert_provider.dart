import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/features/alerts/domain/alert_model.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

part 'alert_provider.g.dart';

/// Alert list with optional filters
@riverpod
Future<List<AlertModel>> alertList(
  AlertListRef ref, {
  AlertSeverity? severityFilter,
  AlertType? typeFilter,
  bool? unresolvedOnly,
}) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query
  // var query = db.select(db.alerts).where((a) => a.storeId.equals(storeId));
  // if (severityFilter != null) {
  //   query = query..where((a) => a.severity.equals(severityFilter));
  // }
  // if (unresolvedOnly == true) {
  //   query = query..where((a) => a.resolvedAt.isNull());
  // }

  // Mock data for Phase 3
  var alerts = _getMockAlerts();

  if (severityFilter != null) {
    alerts = alerts.where((a) => a.severity == severityFilter).toList();
  }

  if (typeFilter != null) {
    alerts = alerts.where((a) => a.type == typeFilter).toList();
  }

  if (unresolvedOnly == true) {
    alerts = alerts.where((a) => a.isUnresolved).toList();
  }

  return alerts;
}

/// Unread alert count (for badge)
@riverpod
Future<int> unreadAlertCount(
  UnreadAlertCountRef ref,
  String storeId,
) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query
  // final count = await (db.selectOnly(db.alerts)
  //     ..where(db.alerts.storeId.equals(storeId))
  //     ..where(db.alerts.isRead.equals(false))
  //     ..addColumns([db.alerts.id.count()]))
  //   .getSingle()
  //   .then((row) => row.read(db.alerts.id.count()) ?? 0);

  // Mock data for Phase 3
  return _getMockAlerts().where((a) => !a.isRead).length;
}

/// Alert actions
@riverpod
class AlertActions extends _$AlertActions {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String alertId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual update
      // await (db.update(db.alerts)..where((a) => a.id.equals(alertId)))
      //   .write(AlertsCompanion(isRead: Value(true)));

      // Invalidate to refresh
      ref.invalidate(alertListProvider);
      ref.invalidate(unreadAlertCountProvider);
    });
  }

  Future<void> dismiss(String alertId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual update
      // await (db.update(db.alerts)..where((a) => a.id.equals(alertId)))
      //   .write(AlertsCompanion(
      //     isDismissed: Value(true),
      //     resolvedAt: Value(DateTime.now()),
      //   ));

      // Invalidate to refresh
      ref.invalidate(alertListProvider);
    });
  }

  Future<void> resolve(String alertId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);

      // TODO: Implement actual update
      // await (db.update(db.alerts)..where((a) => a.id.equals(alertId)))
      //   .write(AlertsCompanion(
      //     isRead: Value(true),
      //     resolvedAt: Value(DateTime.now()),
      //   ));

      // Invalidate to refresh
      ref.invalidate(alertListProvider);
      ref.invalidate(unreadAlertCountProvider);
    });
  }
}

/// Mock data for Phase 3
List<AlertModel> _getMockAlerts() {
  return [
    AlertModel(
      id: 'alert-1',
      storeId: 'store-1',
      type: AlertType.lowStock,
      severity: AlertSeverity.high,
      title: 'Бага нөөц',
      message: 'Sprite 1.5L барааны үлдэгдэл критик түвшинд хүрлээ (8 ширхэг)',
      productId: '2',
      productName: 'Sprite 1.5L',
      isRead: false,
      isDismissed: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AlertModel(
      id: 'alert-2',
      storeId: 'store-1',
      type: AlertType.lowStock,
      severity: AlertSeverity.critical,
      title: 'Маш бага нөөц',
      message: 'Гурил 1кг барааны үлдэгдэл маш бага байна (5 ширхэг)',
      productId: '4',
      productName: 'Гурил 1кг',
      isRead: false,
      isDismissed: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AlertModel(
      id: 'alert-3',
      storeId: 'store-1',
      type: AlertType.systemIssue,
      severity: AlertSeverity.medium,
      title: 'Sync хүлээгдэж байна',
      message: '12 борлуулалт синхрон хийгдэх хэрэгтэй байна',
      isRead: true,
      isDismissed: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AlertModel(
      id: 'alert-4',
      storeId: 'store-1',
      type: AlertType.priceChange,
      severity: AlertSeverity.info,
      title: 'Үнэ өөрчлөгдлөө',
      message: 'Coca Cola 1.5L-ын үнэ 2300₮ → 2500₮ болсон',
      productId: '1',
      productName: 'Coca Cola 1.5L',
      isRead: true,
      isDismissed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}
