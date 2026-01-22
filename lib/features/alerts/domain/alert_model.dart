import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

/// Alert severity levels
enum AlertSeverity {
  info,
  low,
  medium,
  high,
  critical,
}

/// Alert type categories
enum AlertType {
  lowStock,
  negativeStock,
  expiringSoon,
  priceChange,
  systemIssue,
  syncConflict,
}

/// Alert model
@freezed
class AlertModel with _$AlertModel {
  const AlertModel._();

  const factory AlertModel({
    required String id,
    required String storeId,
    required AlertType type,
    required AlertSeverity severity,
    required String title,
    required String message,
    String? productId,
    String? productName,
    DateTime? actionDeadline,
    required bool isRead,
    required bool isDismissed,
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);

  /// Check if alert is unresolved
  bool get isUnresolved => resolvedAt == null && !isDismissed;

  /// Get severity color name (for UI)
  String get severityColor {
    switch (severity) {
      case AlertSeverity.info:
        return 'blue';
      case AlertSeverity.low:
        return 'yellow';
      case AlertSeverity.medium:
        return 'orange';
      case AlertSeverity.high:
        return 'red';
      case AlertSeverity.critical:
        return 'darkRed';
    }
  }
}
