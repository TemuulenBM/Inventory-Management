import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';

/// Гараар sync хийх товч
///
/// Manual sync trigger - хэрэглэгч дарахад бүх pending operations sync хийгдэнэ
/// Loading state: Syncing үед CircularProgressIndicator харуулна
class ManualSyncButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const ManualSyncButton({
    super.key,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync, size: 20),
        label: Text(
          isLoading ? 'Синхрончилж байна...' : 'Гараар синхрончлох',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.gray300,
        ),
      ),
    );
  }
}
