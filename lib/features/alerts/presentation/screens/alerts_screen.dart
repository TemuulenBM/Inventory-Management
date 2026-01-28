import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/widgets/cards/alert_card.dart'
    as alert_ui;
import 'package:retail_control_platform/features/alerts/domain/alert_model.dart';
import 'package:retail_control_platform/features/alerts/presentation/providers/alert_provider.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';

/// Сэрэмжлүүлгийн жагсаалт дэлгэц
/// Filter chips, alert cards, resolve/dismiss actions
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertType? _selectedType;
  bool _unresolvedOnly = true;

  @override
  Widget build(BuildContext context) {
    final storeId = ref.watch(storeIdProvider);
    final alertsAsync = ref.watch(
      alertListProvider(
        typeFilter: _selectedType,
        unresolvedOnly: _unresolvedOnly ? true : null,
      ),
    );
    final lowStockAsync =
        storeId != null ? ref.watch(lowStockProductsProvider(storeId)) : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Сэрэмжлүүлэг',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
        actions: [
          // Шийдвэрлэгдээгүй/бүгд toggle
          TextButton(
            onPressed: () {
              setState(() => _unresolvedOnly = !_unresolvedOnly);
            },
            child: Text(
              _unresolvedOnly ? 'Бүгд' : 'Шийдвэрлээгүй',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Filter chips =====
          _buildFilterChips(),

          // ===== Alert жагсаалт =====
          Expanded(
            child: alertsAsync.when(
              data: (serverAlerts) {
                // Low stock products хослуулах
                if (lowStockAsync == null) {
                  // storeId байхгүй бол зөвхөн server alerts
                  if (serverAlerts.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildAlertList(serverAlerts, []);
                }

                return lowStockAsync.when(
                  data: (lowStockProducts) {
                    // Server alerts + low stock products хослуулах
                    final combinedItems = <dynamic>[];

                    // 1. Server alerts нэмэх
                    combinedItems.addAll(serverAlerts);

                    // 2. Low stock products нэмэх (зөвхөн "Бүгд" эсвэл "Бага үлдэгдэл" filter)
                    if (_selectedType == null ||
                        _selectedType == AlertType.lowStock) {
                      combinedItems.addAll(lowStockProducts);
                    }

                    // 3. Sort by date
                    combinedItems.sort((a, b) {
                      final dateA = a is AlertModel
                          ? a.createdAt
                          : (a as ProductWithStock).updatedAt;
                      final dateB = b is AlertModel
                          ? b.createdAt
                          : (b as ProductWithStock).updatedAt;
                      return (dateB ?? DateTime.now())
                          .compareTo(dateA ?? DateTime.now());
                    });

                    if (combinedItems.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildAlertList(
                      serverAlerts,
                      lowStockProducts,
                      combinedItems: combinedItems,
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (_, __) {
                    // Low stock алдаа - зөвхөн server alerts харуулах
                    if (serverAlerts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildAlertList(serverAlerts, []);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  /// Alert list builder (server alerts + low stock products)
  Widget _buildAlertList(
    List<AlertModel> serverAlerts,
    List<ProductWithStock> lowStockProducts, {
    List<dynamic>? combinedItems,
  }) {
    final items = combinedItems ??
        <dynamic>[...serverAlerts, ...lowStockProducts];

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(alertListProvider);
        final storeId = ref.read(storeIdProvider);
        if (storeId != null) {
          ref.invalidate(lowStockProductsProvider(storeId));
        }
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item is AlertModel) {
            return _buildAlertItem(item);
          } else if (item is ProductWithStock) {
            return _buildLowStockItem(item);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Filter chips (AlertType enum-ээр - backend-тэй тохирсон)
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(null, 'Бүгд', Icons.list),
          const SizedBox(width: 8),
          _buildChip(
              AlertType.lowStock, 'Бага үлдэгдэл', Icons.inventory_2_outlined),
          const SizedBox(width: 8),
          _buildChip(AlertType.negativeStock, 'Сөрөг', Icons.error_outline),
          const SizedBox(width: 8),
          _buildChip(AlertType.suspiciousActivity, 'Сэжигтэй',
              Icons.security_outlined),
          const SizedBox(width: 8),
          _buildChip(
              AlertType.systemIssue, 'Систем', Icons.warning_amber_outlined),
        ],
      ),
    );
  }

  Widget _buildChip(AlertType? type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.gray600,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedType = type);
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.gray300,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? Colors.white : AppColors.textMainLight,
      ),
      showCheckmark: false,
    );
  }

  /// Alert item (AlertCard widget reuse + actions)
  Widget _buildAlertItem(AlertModel alert) {
    return alert_ui.AlertCard(
      title: alert.title,
      subtitle: '${alert.message}\n${_formatTime(alert.createdAt)}',
      severity: _mapSeverity(alert),
      isRead: alert.isRead,
      onTap: () => _showAlertDetail(alert),
      actions: alert.isUnresolved
          ? [
              alert_ui.AlertActionButton(
                text: 'Шийдвэрлэх',
                onPressed: () => _resolveAlert(alert.id),
                color: AppColors.successGreen,
              ),
              alert_ui.AlertActionButton(
                text: 'Хаах',
                onPressed: () => _dismissAlert(alert.id),
                color: AppColors.gray600,
              ),
            ]
          : null,
    );
  }

  /// Low stock product item (client-generated alert)
  Widget _buildLowStockItem(ProductWithStock product) {
    return alert_ui.AlertCard(
      title: product.name,
      subtitle:
          '${product.unit ?? product.category ?? ''} • ${product.stockQuantity} үлдсэн',
      severity: alert_ui.AlertSeverity.lowStock,
      productImageUrl: product.imageUrl,
      productLocalImagePath: product.localImagePath,
      isRead: false, // Low stock items үргэлж unread
      onTap: () {
        // Future: Product detail руу очих
        // context.push('/products/${product.id}');
      },
    );
  }

  /// Domain AlertType → UI AlertSeverity mapping
  /// Domain model-д AlertType болон AlertSeverity тус тусдаа байгаа бол
  /// UI widget-ийн AlertSeverity руу хөрвүүлнэ
  alert_ui.AlertSeverity _mapSeverity(AlertModel alert) {
    switch (alert.type) {
      case AlertType.lowStock:
        return alert_ui.AlertSeverity.lowStock;
      case AlertType.negativeStock:
        return alert_ui.AlertSeverity.negative;
      case AlertType.suspiciousActivity:
        return alert_ui.AlertSeverity.suspicious;
      case AlertType.systemIssue:
        if (alert.severity == AlertSeverity.critical ||
            alert.severity == AlertSeverity.high) {
          return alert_ui.AlertSeverity.negative;
        }
        return alert_ui.AlertSeverity.info;
    }
  }

  /// Цаг формат
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} минутын өмнө';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} цагийн өмнө';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} өдрийн өмнө';
    }
    return '${dateTime.month}/${dateTime.day}';
  }

  /// Alert дэлгэрэнгүй харуулах
  void _showAlertDetail(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
        title: Text(
          alert.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            if (alert.productName != null) ...[
              AppSpacing.verticalMD,
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 16, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Text(
                    alert.productName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.verticalMD,
            Text(
              _formatTime(alert.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
        actions: [
          if (alert.isUnresolved) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _dismissAlert(alert.id);
              },
              child: const Text('Хаах'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resolveAlert(alert.id);
              },
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.successGreen),
              child: const Text('Шийдвэрлэх'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Хаах'),
            ),
        ],
      ),
    );
  }

  /// Шийдвэрлэх
  Future<void> _resolveAlert(String alertId) async {
    final success =
        await ref.read(alertActionsProvider.notifier).resolve(alertId);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сэрэмжлүүлэг шийдвэрлэгдлээ'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  /// Хаах (dismiss)
  Future<void> _dismissAlert(String alertId) async {
    final success =
        await ref.read(alertActionsProvider.notifier).dismiss(alertId);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сэрэмжлүүлэг хаагдлаа'),
          backgroundColor: AppColors.gray600,
        ),
      );
    }
  }

  /// Хоосон state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: AppColors.gray300,
          ),
          AppSpacing.verticalMD,
          const Text(
            'Сэрэмжлүүлэг байхгүй',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalSM,
          Text(
            _unresolvedOnly
                ? 'Шийдвэрлэгдээгүй сэрэмжлүүлэг алга'
                : 'Ямар нэг сэрэмжлүүлэг бүртгэгдээгүй байна',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Алдааны state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          AppSpacing.verticalMD,
          const Text(
            'Алдаа гарлаа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
          AppSpacing.verticalSM,
          TextButton(
            onPressed: () => ref.invalidate(alertListProvider),
            child: const Text('Дахин оролдох'),
          ),
        ],
      ),
    );
  }
}
