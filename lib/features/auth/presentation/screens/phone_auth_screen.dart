import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/widgets/inputs/phone_input.dart';
import 'package:retail_control_platform/core/widgets/buttons/primary_button.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/auth/domain/auth_state.dart';

/// Phone Authentication Screen
/// Дизайн: design/auth_phone_&_otp/screen.png
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _trustDevice = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    // Validate phone number (8 digits)
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 8) {
      setState(() {
        _errorText = 'Утасны дугаар 8 оронтой байх ёстой';
      });
      return;
    }

    setState(() => _errorText = null);

    // Эхлээд trusted device-ээр нэвтрэх оролдлого хийх
    final deviceLoginSuccess = await ref
        .read(authNotifierProvider.notifier)
        .tryDeviceLogin(phone);

    if (deviceLoginSuccess) {
      // Trusted device-ээр амжилттай нэвтэрсэн - Dashboard руу
      if (mounted) {
        context.go(RouteNames.dashboard);
      }
      return;
    }

    // Trusted биш бол OTP илгээх
    await ref.read(authNotifierProvider.notifier).sendOtp(phone);

    // Check state and navigate
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      authState.whenOrNull(
        error: (message) {
          setState(() => _errorText = message);
        },
        otpSent: (sentPhone) {
          // OTP sent - navigate to OTP screen (trustDevice flag дамжуулах)
          context.push(
            RouteNames.authOtp,
            extra: {'phone': phone, 'trustDevice': _trustDevice},
          );
        },
      );
    }
  }

  /// Тусламжийн dialog харуулах
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Тусламж',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mongolian Retail Solution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Борлуулалтын удирдлагын систем',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Холбоо барих:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactRow(Icons.phone, '7000-0000'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.email, 'support@retail.mn'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.web, 'www.retail.mn'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Хаах',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray400),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Decorative gradient blobs (background)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
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

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section
                    Column(
                      children: [
                        // Header
                        _buildHeader(),
                        AppSpacing.verticalXXL,

                        // Headline
                        _buildHeadline(),
                        AppSpacing.verticalXXL,

                        // Phone input form
                        _buildPhoneForm(authState),
                      ],
                    ),

                    // Footer at bottom
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App logo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.radiusLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),

        // Help button
        InkWell(
          onTap: () => _showHelpDialog(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.gray400,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        // Title with accent
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
              color: AppColors.textMainLight,
              fontFamily: 'Epilogue',
            ),
            children: [
              TextSpan(text: 'Тавтай '),
              TextSpan(
                text: 'морил',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSM,

        // Subtitle
        const Text(
          'Борлуулалтын системд нэвтрэх',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(AuthState authState) {
    final isLoading = authState.maybeMap(loading: (_) => true, orElse: () => false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone input label
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Утасны дугаар',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ),

        // Phone input field (using PhoneInput widget)
        PhoneInput(
          controller: _phoneController,
          errorText: _errorText,
          autofocus: true,
          onEditingComplete: _handleContinue,
          onChanged: (value) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
        ),
        AppSpacing.verticalMD,

        // Trust device checkbox (glass card)
        _buildTrustDeviceCheckbox(),
        AppSpacing.verticalLG,

        // Continue button
        PrimaryButton(
          text: 'Үргэлжлүүлэх',
          onPressed: isLoading ? null : _handleContinue,
          isLoading: isLoading,
          icon: Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _buildTrustDeviceCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.3),
          ],
        ),
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _trustDevice = !_trustDevice;
          });
        },
        borderRadius: AppRadius.radiusLG,
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _trustDevice
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.5),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: _trustDevice ? AppColors.primary : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: _trustDevice
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            AppSpacing.horizontalMD,

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Энэ төхөөрөмжид итгэх',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _trustDevice
                          ? AppColors.primary
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Дараагийн удаа код нэхэхгүй',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Mongolian Retail Solution © 2026',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.gray400,
      ),
      textAlign: TextAlign.center,
    );
  }
}
