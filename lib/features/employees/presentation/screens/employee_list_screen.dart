import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/widgets/modals/confirm_dialog.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/employees/presentation/providers/employee_provider.dart';
import 'package:retail_control_platform/features/employees/presentation/widgets/employee_card.dart';

/// Ажилтнуудын жагсаалт дэлгэц
/// Owner/Manager: Жагсаалт харах, засах
/// Owner: Нэмэх, устгах боломжтой
class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final employeesAsync = ref.watch(employeeListProvider);
    final isOwner = user?.role == 'owner';
    final canEdit = isOwner || user?.role == 'manager';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Ажилтнууд',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
      ),
      // FloatingActionButton (зөвхөн owner)
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.employeeAdd),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Нэмэх'),
            )
          : null,
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            // Empty state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.gray300,
                  ),
                  AppSpacing.verticalMD,
                  const Text(
                    'Ажилтан байхгүй байна',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (isOwner) ...[
                    AppSpacing.verticalMD,
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.employeeAdd),
                      icon: const Icon(Icons.add),
                      label: const Text('Ажилтан нэмэх'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // List view
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeeListProvider);
            },
            child: ListView.separated(
              padding: AppSpacing.paddingHorizontalLG,
              itemCount: employees.length,
              separatorBuilder: (context, index) => AppSpacing.verticalMD,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return EmployeeCard(
                  employee: employee,
                  canEdit: canEdit,
                  canDelete: isOwner,
                  onTap: canEdit
                      ? () => context.push(
                            RouteNames.employeeEditPath(employee.id),
                          )
                      : null,
                  onDelete: isOwner
                      ? () => _handleDelete(context, ref, employee.id,
                          employee.name)
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              AppSpacing.verticalMD,
              const Text(
                'Ажилтнуудын жагсаалт татахад алдаа гарлаа',
                style: TextStyle(color: AppColors.danger),
              ),
              AppSpacing.verticalMD,
              ElevatedButton(
                onPressed: () => ref.invalidate(employeeListProvider),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ажилтан устгах confirm dialog + API call
  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String employeeId,
    String employeeName,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Ажилтан устгах',
      message: '$employeeName-г устгахдаа итгэлтэй байна уу?',
      confirmText: 'Устгах',
      cancelText: 'Цуцлах',
      isDanger: true,
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Устгаж байна...'),
          duration: Duration(seconds: 1),
        ),
      );

      final success =
          await ref.read(employeeListProvider.notifier).deleteEmployee(employeeId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ажилтан амжилттай устгагдлаа'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ажилтан устгахад алдаа гарлаа'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}
