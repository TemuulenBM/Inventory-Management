import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';

/// Onboarding дэлгэцүүдийн нийтлэг layout wrapper
/// Gradient blobs, progress indicator, header, footer
class OnboardingPageWrapper extends StatelessWidget {
  final int currentStep;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottomButton;
  final bool showBackButton;
  final VoidCallback? onBack;

  const OnboardingPageWrapper({
    super.key,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    required this.child,
    this.bottomButton,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Gradient blob дээд
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Gradient blob доод
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Гол контент
          SafeArea(
            child: Column(
              children: [
                // Толгой хэсэг
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (showBackButton && onBack != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: onBack,
                          color: AppColors.textMainLight,
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      OnboardingProgressIndicator(currentStep: currentStep),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                AppSpacing.verticalMD,

                // Гарчиг
                Padding(
                  padding: AppSpacing.paddingHorizontalLG,
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMainLight,
                          fontFamily: 'Epilogue',
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSM,
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalLG,

                // Гол контент
                Expanded(child: child),

                // Доод товч
                if (bottomButton != null)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: bottomButton!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
