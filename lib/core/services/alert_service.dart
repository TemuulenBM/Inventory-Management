import 'package:drift/drift.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/services/base_service.dart';
import 'package:retail_control_platform/features/alerts/domain/alert_model.dart';

/// AlertService - Сэрэмжлүүлэгтэй холбоотой бүх үйлдлүүд
/// API + Local Database integration with offline-first pattern
class AlertService extends BaseService {
  AlertService({required super.db});

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Сэрэмжлүүлэг жагсаалт авах
  Future<ApiResult<List<AlertModel>>> getAlerts(
    String storeId, {
    AlertSeverity? severityFilter,
    AlertType? typeFilter,
    bool? unresolvedOnly,
  }) async {
    try {
      // 1. Local DB-аас унших
      final localAlerts = await _getLocalAlerts(
        storeId,
        severityFilter: severityFilter,
        typeFilter: typeFilter,
        unresolvedOnly: unresolvedOnly,
      );

      // 2. Online бол API-аас refresh
      if (await isOnline) {
        _refreshAlertsFromApi(storeId);
      }

      return ApiResult.success(localAlerts);
    } catch (e) {
      log('getAlerts error: $e');
      return ApiResult.error('Сэрэмжлүүлэг унших үед алдаа гарлаа');
    }
  }

  /// Уншаагүй сэрэмжлүүлэг тоолох
  Future<ApiResult<int>> getUnreadCount(String storeId) async {
    try {
      final alerts = await _getLocalAlerts(storeId, unresolvedOnly: true);
      return ApiResult.success(alerts.length);
    } catch (e) {
      log('getUnreadCount error: $e');
      return ApiResult.error('Сэрэмжлүүлэг тоолоход алдаа гарлаа');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Сэрэмжлүүлэг шийдвэрлэх
  Future<ApiResult<void>> resolveAlert(
    String storeId,
    String alertId,
  ) async {
    try {
      // 1. Local DB-д update
      await (db.update(db.alerts)..where((a) => a.id.equals(alertId))).write(
        AlertsCompanion(
          resolved: const Value(true),
        ),
      );

      // 2. Online бол API руу илгээх
      if (await isOnline) {
        try {
          await api.put(ApiEndpoints.resolveAlert(storeId, alertId));
        } catch (e) {
          log('API resolveAlert error: $e');
          // Queue for later
          await enqueueOperation(
            entityType: 'alert',
            operation: 'resolve',
            payload: {
              'alert_id': alertId,
              'store_id': storeId,
            },
          );
        }
      } else {
        await enqueueOperation(
          entityType: 'alert',
          operation: 'resolve',
          payload: {
            'alert_id': alertId,
            'store_id': storeId,
          },
        );
      }

      return const ApiResult.success(null);
    } catch (e) {
      log('resolveAlert error: $e');
      return ApiResult.error('Сэрэмжлүүлэг шийдвэрлэхэд алдаа гарлаа');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Local DB-аас сэрэмжлүүлэг унших
  Future<List<AlertModel>> _getLocalAlerts(
    String storeId, {
    AlertSeverity? severityFilter,
    AlertType? typeFilter,
    bool? unresolvedOnly,
  }) async {
    var query = db.select(db.alerts)..where((a) => a.storeId.equals(storeId));

    // Severity filter
    if (severityFilter != null) {
      final severityStr = _severityToString(severityFilter);
      query = query..where((a) => a.level.equals(severityStr));
    }

    // Type filter
    if (typeFilter != null) {
      final typeStr = _typeToString(typeFilter);
      query = query..where((a) => a.type.equals(typeStr));
    }

    // Unresolved only
    if (unresolvedOnly == true) {
      query = query..where((a) => a.resolved.equals(false));
    }

    // Order by creation date
    query = query..orderBy([(a) => OrderingTerm.desc(a.createdAt)]);

    final alertsData = await query.get();

    // Product мэдээлэл нэмэх
    final alertModels = <AlertModel>[];
    for (final alert in alertsData) {
      String? productName;
      if (alert.productId != null) {
        final product = await (db.select(db.products)
              ..where((p) => p.id.equals(alert.productId!)))
            .getSingleOrNull();
        productName = product?.name;
      }

      alertModels.add(AlertModel(
        id: alert.id,
        storeId: alert.storeId,
        type: _stringToType(alert.type),
        severity: _stringToSeverity(alert.level),
        title: _getAlertTitle(alert.type),
        message: alert.message,
        productId: alert.productId,
        productName: productName,
        isRead: alert.resolved, // Using resolved as read for now
        isDismissed: false,
        createdAt: alert.createdAt,
        resolvedAt: alert.resolved ? DateTime.now() : null,
      ));
    }

    return alertModels;
  }

  /// API-аас сэрэмжлүүлэг refresh
  Future<void> _refreshAlertsFromApi(String storeId) async {
    try {
      final response = await api.get(
        ApiEndpoints.alerts(storeId),
        queryParameters: {'limit': 50},
      );

      if (response.data['success'] == true) {
        final alertsData = response.data['alerts'] as List? ?? [];

        for (final data in alertsData) {
          final companion = AlertsCompanion(
            id: Value(data['id']),
            storeId: Value(storeId),
            type: Value(data['alert_type'] ?? 'low_stock'),
            productId: Value(data['product_id']),
            message: Value(data['message'] ?? ''),
            level: Value(data['level'] ?? 'info'),
            createdAt: data['created_at'] != null
                ? Value(DateTime.parse(data['created_at']))
                : Value(DateTime.now()),
            resolved: Value(data['resolved'] ?? false),
          );

          await db.into(db.alerts).insertOnConflictUpdate(companion);
        }

        log('Refreshed ${alertsData.length} alerts from API');
      }
    } catch (e) {
      log('_refreshAlertsFromApi error: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS - Enum conversions
  // ============================================================================

  String _severityToString(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return 'info';
      case AlertSeverity.low:
        return 'info';
      case AlertSeverity.medium:
        return 'warning';
      case AlertSeverity.high:
        return 'error';
      case AlertSeverity.critical:
        return 'critical';
    }
  }

  AlertSeverity _stringToSeverity(String level) {
    switch (level) {
      case 'info':
        return AlertSeverity.info;
      case 'warning':
        return AlertSeverity.medium;
      case 'error':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.info;
    }
  }

  String _typeToString(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return 'low_stock';
      case AlertType.negativeStock:
        return 'negative_inventory';
      case AlertType.suspiciousActivity:
        return 'suspicious_activity';
      case AlertType.systemIssue:
        return 'system';
    }
  }

  AlertType _stringToType(String type) {
    switch (type) {
      case 'low_stock':
        return AlertType.lowStock;
      case 'negative_inventory':
        return AlertType.negativeStock;
      case 'suspicious_activity':
        return AlertType.suspiciousActivity;
      case 'system':
        return AlertType.systemIssue;
      default:
        // Backend-аас танихгүй type ирвэл systemIssue болгон хувиргана
        return AlertType.systemIssue;
    }
  }

  String _getAlertTitle(String type) {
    switch (type) {
      case 'low_stock':
        return 'Бага үлдэгдэл';
      case 'negative_inventory':
        return 'Сөрөг үлдэгдэл';
      case 'suspicious_activity':
        return 'Сэжигтэй үйлдэл';
      case 'system':
        return 'Системийн мэдэгдэл';
      default:
        return 'Мэдэгдэл';
    }
  }
}
