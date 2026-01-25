import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';

/// Main Shell - Bottom Navigation Bar агуулсан wrapper
/// Dashboard, Quick Sale, Inventory, Settings дэлгэцүүдэд хамаарна
class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront,
                  label: 'Нүүр',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Бараа',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'Түүх',
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Тохиргоо',
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
