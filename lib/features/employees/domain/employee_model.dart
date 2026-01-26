import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

/// Employee model - Ажилтны мэдээлэл (manager, seller)
/// Backend API-аас ирэх users table-ийн мэдээлэл
@freezed
class EmployeeModel with _$EmployeeModel {
  const factory EmployeeModel({
    required String id,
    required String storeId,
    required String phone,
    required String name,
    required String role, // manager, seller (owner биш)
    DateTime? createdAt,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
}
