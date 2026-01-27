/**
 * Store Selection Screen
 *
 * Multi-store дэмжлэг:
 * - Owner олон дэлгүүртэй үед дэлгүүр сонгох screen
 * - Одоогийн сонгогдсон store-ийг харуулах
 * - Дэлгүүр солих, шинэ дэлгүүр нэмэх боломжтой
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/buttons/primary_button.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/store/domain/store_info.dart';
import 'package:retail_control_platform/features/store/presentation/providers/user_stores_provider.dart';

/// Дэлгүүр сонгох screen
///
/// Owner олон дэлгүүртэй байх боломжтой.
/// Энэ screen дээр:
/// - Бүх дэлгүүрүүдийн жагсаалт харагдана
/// - Одоогийн сонгогдсон store check mark-тай
/// - Дэлгүүр дарж солих боломжтой
/// - FAB дээр дарж шинэ дэлгүүр үүсгэх боломжтой
class StoreSelectionScreen extends ConsumerWidget {
  const StoreSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(userStoresProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Дэлгүүр сонгох'),
        centerTitle: true,
        elevation: 0,
      ),
      body: storesAsync.when(
        data: (stores) {
          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Дэлгүүр байхгүй байна',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Доорх товчийг дарж шинэ дэлгүүр үүсгэнэ үү',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: stores.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final store = stores[index];
              final isSelected = store.id == currentUser?.storeId;

              return Card(
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.gray300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isSelected
                      ? null
                      : () => _onStoreSelected(context, ref, store.id),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Store icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.store,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),

                        // Store info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                              if (store.location != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        store.location!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondaryLight,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              // Role badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(store.role)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getRoleLabel(store.role),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _getRoleColor(store.role),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Алдаа гарлаа',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: AppSpacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Дахин оролдох',
                onPressed: () => ref.invalidate(userStoresProvider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onCreateStore(context),
        icon: const Icon(Icons.add),
        label: const Text('Дэлгүүр нэмэх'),
      ),
    );
  }

  /// Дэлгүүр сонгох
  Future<void> _onStoreSelected(
    BuildContext context,
    WidgetRef ref,
    String storeId,
  ) async {
    // Loading indicator харуулах
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Store сонгох
    final success =
        await ref.read(userStoresProvider.notifier).selectStore(storeId);

    if (context.mounted) {
      // Loading dialog хаах
      Navigator.of(context).pop();

      if (success) {
        // Success: Settings screen руу буцах
        context.pop();

        // Success message with store name
        final stores = ref.read(userStoresProvider).valueOrNull ?? [];
        StoreInfo? selectedStore;
        try {
          selectedStore = stores.firstWhere((s) => s.id == storeId);
        } catch (e) {
          selectedStore = null;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selectedStore != null
                  ? '${selectedStore.name} руу амжилттай шилжлээ'
                  : 'Дэлгүүр амжилттай солигдлоо',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Дэлгүүр солихоо алдаа гарлаа'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Шинэ дэлгүүр үүсгэх
  void _onCreateStore(BuildContext context) {
    // TODO: Onboarding screen руу шилжих (store үүсгэх)
    // Одоогоор placeholder message харуулах
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Дэлгүүр үүсгэх feature удахгүй нэмэгдэнэ'),
      ),
    );
  }

  /// Role-оос хамаарч өнгө авах
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return AppColors.primary;
      case 'manager':
        return AppColors.warning;
      case 'seller':
        return AppColors.secondary;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  /// Role label
  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Эзэмшигч';
      case 'manager':
        return 'Менежер';
      case 'seller':
        return 'Борлуулагч';
      default:
        return role;
    }
  }
}
