import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Shimmer loading placeholder
/// Ашиглалт: Product cards, list items loading state
class LoadingShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const LoadingShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: child,
    );
  }
}

/// Product card shimmer
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: AppColors.gray200,
            ),
          ),

          // Content placeholder
          Padding(
            padding: AppSpacing.paddingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                AppSpacing.verticalXS,
                // Second line
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                AppSpacing.verticalSM,
                // Price
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List item shimmer
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.listItemPadding,
      child: Row(
        children: [
          // Avatar/Image
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontalMD,

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
                AppSpacing.verticalXS,
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: AppRadius.radiusSM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid shimmer (for product grid)
class GridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GridShimmer({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const ProductCardShimmer(),
      ),
    );
  }
}

/// List shimmer
class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({
    super.key,
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) => const ListItemShimmer(),
      ),
    );
  }
}
