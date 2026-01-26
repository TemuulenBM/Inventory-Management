import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/employees/domain/employee_model.dart';

part 'employee_provider.g.dart';

/// Employee list provider
/// Backend API ашиглан ажилтнуудын жагсаалт татаж, CRUD хийнэ
@riverpod
class EmployeeList extends _$EmployeeList {
  @override
  Future<List<EmployeeModel>> build() async {
    // Ажилтнуудын жагсаалт татах
    return _fetchEmployees();
  }

  /// Ажилтнуудын жагсаалт татах
  Future<List<EmployeeModel>> _fetchEmployees() async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return [];
      }

      // GET /stores/:storeId/users
      final response = await apiClient.get(ApiEndpoints.users(storeId));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final usersData = response.data['users'] as List;
        return usersData
            .map((userData) => EmployeeModel.fromJson(userData))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Шинэ ажилтан нэмэх
  ///
  /// Backend: POST /stores/:storeId/users
  /// Body: { phone: string, name: string, role: 'manager' | 'seller' }
  Future<bool> createEmployee({
    required String phone,
    required String name,
    required String role,
  }) async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return false;
      }

      // Утасны дугаар форматлах (+976 prefix)
      final formattedPhone = phone.startsWith('+976') ? phone : '+976$phone';

      // POST request хийх
      final response = await apiClient.post(
        ApiEndpoints.users(storeId),
        data: {
          'phone': formattedPhone,
          'name': name,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // List refresh хийх
        ref.invalidateSelf();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Ажилтны мэдээлэл шинэчлэх
  ///
  /// Backend: PUT /stores/:storeId/users/:userId
  /// Body: { name?: string }
  Future<bool> updateEmployee(String userId, {String? name}) async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return false;
      }

      // PUT request хийх
      final response = await apiClient.put(
        ApiEndpoints.user(storeId, userId),
        data: {
          if (name != null) 'name': name,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // List refresh хийх
        ref.invalidateSelf();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Ажилтан устгах
  ///
  /// Backend: DELETE /stores/:storeId/users/:userId
  Future<bool> deleteEmployee(String userId) async {
    try {
      final storeId = ref.read(storeIdProvider);
      if (storeId == null) {
        return false;
      }

      // DELETE request хийх
      final response =
          await apiClient.delete(ApiEndpoints.user(storeId, userId));

      if (response.statusCode == 200 && response.data['success'] == true) {
        // List refresh хийх
        ref.invalidateSelf();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
