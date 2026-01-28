import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/widgets/modals/confirm_dialog.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/settings/presentation/widgets/settings_section.dart';
import 'package:retail_control_platform/features/store/presentation/providers/current_store_provider.dart';

/// Тохиргооны дэлгэц
/// Profile, дэлгүүрийн мэдээлэл, аппын тохиргоо, logout
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Тохиргоо',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Profile section =====
            _buildProfileCard(context, user),
            AppSpacing.verticalLG,

            // ===== Super-admin section =====
            if (user?.role == 'super_admin') ...[
              SettingsSection(
                title: 'АДМИН',
                tiles: [
                  SettingsTile(
                    icon: Icons.mail_outline,
                    iconColor: AppColors.primary,
                    title: 'Урилга илгээх',
                    subtitle: 'Шинэ owner бүртгүүлэх',
                    onTap: () => context.push(RouteNames.createInvitation),
                  ),
                  SettingsTile(
                    icon: Icons.list_alt_outlined,
                    iconColor: AppColors.secondary,
                    title: 'Урилгын жагсаалт',
                    subtitle: 'Илгээсэн урилгууд',
                    onTap: () => context.push(RouteNames.invitations),
                  ),
                ],
              ),
              AppSpacing.verticalMD,
            ],

            // ===== Дэлгүүрийн мэдээлэл =====
            if (user?.role != 'super_admin') ...[
              Consumer(
                builder: (context, ref, child) {
                  final currentStoreAsync = ref.watch(currentStoreProvider);

                  return SettingsSection(
                    title: 'ДЭЛГҮҮР',
                    tiles: [
                      // Multi-store: Owner үед дэлгүүр солих товч
                      if (user?.role == 'owner')
                        currentStoreAsync.when(
                          data: (store) => SettingsTile(
                            icon: Icons.swap_horiz,
                            iconColor: AppColors.secondary,
                            title: 'Дэлгүүр солих',
                            subtitle: store != null
                                ? 'Одоогийн: ${store.name}'
                                : 'Олон дэлгүүрийн хооронд солих',
                            onTap: () => context.push(RouteNames.storeSelection),
                          ),
                          loading: () => SettingsTile(
                            icon: Icons.swap_horiz,
                            iconColor: AppColors.secondary,
                            title: 'Дэлгүүр солих',
                            subtitle: 'Ачаалж байна...',
                            onTap: () => context.push(RouteNames.storeSelection),
                          ),
                          error: (_, __) => SettingsTile(
                            icon: Icons.swap_horiz,
                            iconColor: AppColors.secondary,
                            title: 'Дэлгүүр солих',
                            subtitle: 'Олон дэлгүүрийн хооронд солих',
                            onTap: () => context.push(RouteNames.storeSelection),
                          ),
                        ),
                      // Дэлгүүрийн мэдээлэл tile
                      currentStoreAsync.when(
                        data: (store) => SettingsTile(
                          icon: Icons.store_outlined,
                          title: 'Дэлгүүрийн мэдээлэл',
                          subtitle: store != null
                              ? '${store.name}${store.location != null ? ' • ${store.location}' : ''}'
                              : (user?.storeId != null
                                  ? 'ID: ${user!.storeId!.substring(0, 8)}...'
                                  : null),
                          onTap: () => context.push(RouteNames.storeEdit),
                        ),
                        loading: () => SettingsTile(
                          icon: Icons.store_outlined,
                          title: 'Дэлгүүрийн мэдээлэл',
                          subtitle: 'Ачаалж байна...',
                          onTap: () => context.push(RouteNames.storeEdit),
                        ),
                        error: (_, __) => SettingsTile(
                          icon: Icons.store_outlined,
                          title: 'Дэлгүүрийн мэдээлэл',
                          subtitle: user?.storeId != null
                              ? 'ID: ${user!.storeId!.substring(0, 8)}...'
                              : null,
                          onTap: () => context.push(RouteNames.storeEdit),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.people_outline,
                        title: 'Ажилтнууд',
                        subtitle: 'Худалдагч, менежер удирдах',
                        onTap: () => context.push(RouteNames.employees),
                      ),
                    ],
                  );
                },
              ),
              AppSpacing.verticalMD,
            ],

            // ===== Аппын тохиргоо =====
            // Super-admin-д store-specific features (Ээлж, Синк, Сэрэмжлүүлэг) хэрэггүй
            // Учир нь super-admin нь storeId = null (дэлгүүргүй)
            if (user?.role != 'super_admin') ...[
              SettingsSection(
                title: 'АППЛКЕЙШН',
                tiles: [
                  SettingsTile(
                    icon: Icons.access_time_outlined,
                    iconColor: AppColors.secondary,
                    title: 'Ээлж',
                    subtitle: 'Ээлжийн удирдлага',
                    onTap: () => context.go(RouteNames.shifts),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.warningOrange,
                    title: 'Сэрэмжлүүлэг',
                    subtitle: 'Мэдэгдэл, анхааруулга',
                    onTap: () => context.go(RouteNames.alerts),
                  ),
                  SettingsTile(
                    icon: Icons.sync_outlined,
                    iconColor: AppColors.successGreen,
                    title: 'Синк',
                    subtitle: 'Offline/Online синхрончлол',
                    onTap: () => context.go(RouteNames.syncConflicts),
                  ),
                ],
              ),
              AppSpacing.verticalMD,
            ],

            // ===== Тусламж =====
            SettingsSection(
              title: 'ТУСЛАМЖ',
              tiles: [
                SettingsTile(
                  icon: Icons.help_outline,
                  iconColor: AppColors.gray600,
                  title: 'Тусламж',
                  subtitle: 'Заавар, холбоо барих',
                  onTap: () {
                    // TODO: Help screen
                  },
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  iconColor: AppColors.gray600,
                  title: 'Аппын тухай',
                  subtitle: 'Хувилбар 1.0.0',
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  onTap: () {
                    // TODO: About screen
                  },
                ),
              ],
            ),
            AppSpacing.verticalLG,

            // ===== Logout =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Гарах',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            AppSpacing.verticalXXL,
          ],
        ),
      ),
    );
  }

  /// Profile card бүтэц
  Widget _buildProfileCard(BuildContext context, dynamic user) {
    final name = user?.name ?? 'Хэрэглэгч';
    final phone = user?.phone ?? '';
    final role = user?.role ?? 'seller';

    String roleName;
    Color roleColor;
    switch (role) {
      case 'super_admin':
        roleName = 'Супер Админ';
        roleColor = AppColors.primary;
        break;
      case 'owner':
        roleName = 'Эзэмшигч';
        roleColor = AppColors.primary;
        break;
      case 'manager':
        roleName = 'Менежер';
        roleColor = AppColors.secondary;
        break;
      default:  // seller
        roleName = 'Худалдагч';
        roleColor = AppColors.gray600;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          AppSpacing.horizontalMD,

          // Мэдээлэл
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit icon
          IconButton(
            onPressed: () => context.push(RouteNames.profileEdit),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.gray500,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// Logout хийх
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Гарах',
      message: 'Та системээс гарахдаа итгэлтэй байна уу?',
      confirmText: 'Гарах',
      cancelText: 'Цуцлах',
      isDanger: true,
      icon: Icons.logout,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        context.go(RouteNames.authPhone);
      }
    }
  }
}
