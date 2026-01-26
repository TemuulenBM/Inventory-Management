import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';

/// Onboarding Welcome Screen
/// Апп-ын танилцуулга + "Эхлүүлэх" товч
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Gradient blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Гол контент
          SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Лого
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: AppRadius.radiusXXL,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.radiusXL,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalXL,

                  // Гарчиг
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.5,
                        fontFamily: 'Epilogue',
                        color: AppColors.textMainLight,
                      ),
                      children: [
                        TextSpan(text: 'Тавтай морилно уу!\n'),
                        TextSpan(
                          text: 'Дэлгүүрээ бүртгэцгээе',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalMD,

                  // Тайлбар
                  const Text(
                    'Хэдхэн алхамаар дэлгүүрийнхээ мэдээллийг оруулж,\nбараа бүртгэж, худалдагчаа урина.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalXL,

                  // Feature-ууд
                  _buildFeatureRow(
                    Icons.store_outlined,
                    'Дэлгүүрийн бүртгэл',
                  ),
                  AppSpacing.verticalSM,
                  _buildFeatureRow(
                    Icons.inventory_2_outlined,
                    'Бараа бүртгэл',
                  ),
                  AppSpacing.verticalSM,
                  _buildFeatureRow(
                    Icons.people_outline,
                    'Худалдагч урих',
                  ),

                  const Spacer(flex: 3),

                  // Эхлүүлэх товч
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(RouteNames.onboardingStoreSetup);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Эхлүүлэх',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalMD,

                  // Footer
                  const Text(
                    'Mongolian Retail Solution © 2026',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}
