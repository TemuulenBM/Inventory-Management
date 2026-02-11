import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/dashboard/presentation/providers/multi_store_dashboard_provider.dart';

part 'admin_dashboard_provider.g.dart';

/// Super-admin бүх дэлгүүрийн dashboard (API-аас)
/// StoreDashboardSummary model-ийг дахин ашиглана (шинэ model хэрэггүй)
@riverpod
Future<List<StoreDashboardSummary>> adminAllStoresDashboard(
  AdminAllStoresDashboardRef ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != 'super_admin') return [];

  try {
    final response = await apiClient.get(
      ApiEndpoints.adminDashboard,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final storesData = response.data['stores'] as List;
      return storesData
          .map((data) =>
              StoreDashboardSummary.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    throw Exception('Бүх дэлгүүрийн мэдээлэл авахад алдаа гарлаа: $e');
  }
}
