import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

/// Main Shell - Bottom Navigation Bar агуулсан wrapper
/// Dashboard, Quick Sale, Inventory, Settings дэлгэцүүдэд хамаарна
/// Role-based navigation: super-admin зөвхөн Dashboard болон Settings харна
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

    // Role-д тохирсон navigation items үүсгэх
    final navItems = _buildNavigationItems(isSuperAdmin);

    return Scaffold(
      body: child,
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

  /// Role-д тохирсон navigation items буцаах
  /// Super-admin: Dashboard (index 0), Settings (index 3)
  /// Owner/Manager/Seller: Dashboard (0), Inventory (1), History (2), Settings (3)
  List<Map<String, dynamic>> _buildNavigationItems(bool isSuperAdmin) {
    if (isSuperAdmin) {
      // Super-admin: зөвхөн Нүүр болон Тохиргоо
      // Index values нь _onItemTapped switch statement-тай таарч байх ёстой
      return [
        {
          'index': 0, // /dashboard
          'icon': Icons.storefront_outlined,
          'activeIcon': Icons.storefront,
          'label': 'Нүүр',
        },
        {
          'index': 3, // /settings (switch statement-д index 3 = settings)
          'icon': Icons.settings_outlined,
          'activeIcon': Icons.settings,
          'label': 'Тохиргоо',
        },
      ];
    } else {
      // Owner/Manager/Seller: бүх tabs
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
