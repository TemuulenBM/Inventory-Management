import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/providers/admin_browse_provider.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

/// Main Shell - Bottom Navigation Bar агуулсан wrapper
/// Dashboard, Quick Sale, Inventory, Settings дэлгэцүүдэд хамаарна
/// Role-based navigation:
/// - Super-admin (browse mode-гүй): Нүүр + Тохиргоо
/// - Super-admin (browse mode): Нүүр + Бараа + Түүх + Тохиргоо + read-only banner
/// - Owner/Manager/Seller: Нүүр + Бараа + Түүх + Тохиргоо
class MainShell extends ConsumerWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Super-admin эсэхийг шалгах
    final user = ref.watch(currentUserProvider);
    final isSuperAdmin = user?.role == 'super_admin';

    // Browse mode: super-admin тодорхой дэлгүүрийг харж байгаа эсэх
    final browsingStoreId = isSuperAdmin
        ? ref.watch(adminBrowseStoreProvider)
        : null;
    final isBrowseMode = browsingStoreId != null;

    // Browse mode-д бүх 4 tab, үгүй бол role-д тохирсон tabs
    final navItems = _buildNavigationItems(isSuperAdmin, isBrowseMode);

    return Scaffold(
      body: Column(
        children: [
          // Browse mode banner (super-admin дэлгүүр харж байгаа үед)
          if (isBrowseMode)
            _buildBrowseModeBanner(context, ref),

          // Үндсэн content
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.map((item) {
                return _buildNavItem(
                  context,
                  index: item['index'] as int,
                  icon: item['icon'] as IconData,
                  activeIcon: item['activeIcon'] as IconData,
                  label: item['label'] as String,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Browse mode banner — "Зөвхөн харах" горим + буцах товч
  Widget _buildBrowseModeBanner(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFFFEF3C7),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outlined,
              size: 16,
              color: Color(0xFFB45309),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Зөвхөн харах горим',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Browse горимоос гарах → dashboard руу буцах
                ref.read(adminBrowseStoreProvider.notifier).clearBrowse();
                context.go('/dashboard');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB45309).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Буцах',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Role + browse mode-д тохирсон navigation items буцаах
  /// Super-admin (browse mode): бүх 4 tab (read-only горимоор)
  /// Super-admin (browse mode-гүй): Нүүр + Тохиргоо
  /// Owner/Manager/Seller: бүх 4 tab
  List<Map<String, dynamic>> _buildNavigationItems(
    bool isSuperAdmin,
    bool isBrowseMode,
  ) {
    if (isSuperAdmin && !isBrowseMode) {
      // Super-admin browse mode-гүй: зөвхөн Нүүр болон Тохиргоо
      return [
        {
          'index': 0,
          'icon': Icons.storefront_outlined,
          'activeIcon': Icons.storefront,
          'label': 'Нүүр',
        },
        {
          'index': 3,
          'icon': Icons.settings_outlined,
          'activeIcon': Icons.settings,
          'label': 'Тохиргоо',
        },
      ];
    } else {
      // Owner/Manager/Seller эсвэл super-admin browse mode: бүх tabs
      return [
        {
          'index': 0,
          'icon': Icons.storefront_outlined,
          'activeIcon': Icons.storefront,
          'label': 'Нүүр',
        },
        {
          'index': 1,
          'icon': Icons.inventory_2_outlined,
          'activeIcon': Icons.inventory_2,
          'label': 'Бараа',
        },
        {
          'index': 2,
          'icon': Icons.history_outlined,
          'activeIcon': Icons.history,
          'label': 'Түүх',
        },
        {
          'index': 3,
          'icon': Icons.settings_outlined,
          'activeIcon': Icons.settings,
          'label': 'Тохиргоо',
        },
      ];
    }
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(context, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.primary : AppColors.gray400,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Аль хэдийн тэр дэлгэц дээр байвал алгасах

    // Index → route mapping (role-independent, одоогийн navigation items-аас хамаарна)
    // Navigation items-ын index нь _buildNavigationItems-ээс ирнэ
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
