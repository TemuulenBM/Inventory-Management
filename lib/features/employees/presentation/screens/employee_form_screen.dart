import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/modals/confirm_dialog.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/employees/presentation/providers/employee_provider.dart';

/// Ажилтан нэмэх/засах form дэлгэц
/// Create mode: employeeId == null
/// Edit mode: employeeId != null
class EmployeeFormScreen extends ConsumerStatefulWidget {
  final String? employeeId;

  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormScreen> createState() =>
      _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'seller';
  bool _isLoading = false;
  String? _errorText;

  bool get _isEditMode => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Edit mode: Load employee data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEmployeeData();
      });
    }
  }

  void _loadEmployeeData() {
    final employeesAsync = ref.read(employeeListProvider);
    employeesAsync.whenData((employees) {
      final employee =
          employees.firstWhere((e) => e.id == widget.employeeId);
      _nameController.text = employee.name;
      _phoneController.text = employee.phone;
      setState(() {
        _selectedRole = employee.role;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    bool success;
    if (_isEditMode) {
      // Update employee
      success = await ref.read(employeeListProvider.notifier).updateEmployee(
            widget.employeeId!,
            name: _nameController.text.trim(),
          );
    } else {
      // Create employee
      success = await ref.read(employeeListProvider.notifier).createEmployee(
            phone: _phoneController.text.trim(),
            name: _nameController.text.trim(),
            role: _selectedRole,
          );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Ажилтны мэдээлэл амжилттай шинэчлэгдлээ'
                  : 'Ажилтан амжилттай нэмэгдлээ',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorText = _isEditMode
            ? 'Ажилтны мэдээлэл шинэчлэхэд алдаа гарлаа'
            : 'Ажилтан нэмэхэд алдаа гарлаа. Утасны дугаар бүртгэлтэй эсэхийг шалгана уу.');
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Ажилтан устгах',
      message: '${_nameController.text}-г устгахдаа итгэлтэй байна уу?',
      confirmText: 'Устгах',
      cancelText: 'Цуцлах',
      isDanger: true,
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isLoading = true);

      final success = await ref
          .read(employeeListProvider.notifier)
          .deleteEmployee(widget.employeeId!);

      if (mounted) {
        if (success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ажилтан амжилттай устгагдлаа'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorText = 'Ажилтан устгахад алдаа гарлаа';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.role == 'owner';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          _isEditMode ? 'Ажилтан засах' : 'Ажилтан нэмэх',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
        // Delete button (edit mode, owner only)
        actions: [
          if (_isEditMode && isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _isLoading ? null : _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingHorizontalLG,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppSpacing.verticalXL,

              // Employee icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.primary,
                  size: 50,
                ),
              ),
              AppSpacing.verticalXL,

              // Утасны дугаар (create mode only)
              if (!_isEditMode) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Утасны дугаар оруулна уу';
                    }
                    final phone = value.trim();
                    // +976XXXXXXXX эсвэл XXXXXXXX format
                    if (!RegExp(r'^(\+976)?\d{8}$').hasMatch(phone)) {
                      return 'Утасны дугаар буруу байна (8 оронтой)';
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    label: 'Утасны дугаар',
                    hint: '+976XXXXXXXX',
                    icon: Icons.phone_outlined,
                  ),
                ),
                AppSpacing.verticalMD,
              ] else ...[
                // Edit mode: Phone read-only
                TextFormField(
                  controller: _phoneController,
                  enabled: false,
                  decoration: _inputDecoration(
                    label: 'Утасны дугаар',
                    hint: '+976XXXXXXXX',
                    icon: Icons.phone_outlined,
                  ),
                  style: const TextStyle(color: AppColors.gray500),
                ),
                AppSpacing.verticalMD,
              ],

              // Нэр
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Нэр оруулна уу';
                  }
                  if (value.trim().length < 2) {
                    return 'Нэр хамгийн багадаа 2 тэмдэгт байх ёстой';
                  }
                  return null;
                },
                decoration: _inputDecoration(
                  label: 'Нэр',
                  hint: 'Жишээ: Болд',
                  icon: Icons.badge_outlined,
                ),
              ),
              AppSpacing.verticalMD,

              // Роль (create mode only, edit mode read-only)
              if (!_isEditMode) ...[
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: _inputDecoration(
                    label: 'Роль',
                    hint: 'Ажилтны роль сонгох',
                    icon: Icons.shield_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'manager',
                      child: Text('Менежер'),
                    ),
                    DropdownMenuItem(
                      value: 'seller',
                      child: Text('Худалдагч'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
              ] else ...[
                // Edit mode: Role read-only
                TextFormField(
                  initialValue: _getRoleName(_selectedRole),
                  enabled: false,
                  decoration: _inputDecoration(
                    label: 'Роль',
                    hint: 'Ажилтны роль',
                    icon: Icons.shield_outlined,
                  ),
                  style: const TextStyle(color: AppColors.gray500),
                ),
              ],

              // Алдааны текст
              if (_errorText != null) ...[
                AppSpacing.verticalMD,
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              AppSpacing.verticalXL,

              // Хадгалах товч
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Хадгалах' : 'Нэмэх',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.gray500),
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'manager':
        return 'Менежер';
      case 'seller':
        return 'Худалдагч';
      default:
        return role;
    }
  }
}
