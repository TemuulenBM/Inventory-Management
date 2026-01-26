import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

/// OTP Verification Screen
/// Дизайн: design/auth_phone_&_otp/screen.png (доод хэсэг)
class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool trustDevice;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.trustDevice = false,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String? _errorText;
  int _countdown = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 59);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleOtpComplete(String otp) async {
    setState(() => _errorText = null);

    // Verify OTP (trustDevice flag дамжуулах)
    await ref.read(authNotifierProvider.notifier).verifyOtp(
          widget.phoneNumber,
          otp,
          trustDevice: widget.trustDevice,
        );

    // Check state
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      authState.when(
        initial: () {},
        authenticated: (user) {
          // Super-admin → Dashboard (onboarding давна)
          if (user.role == 'super_admin') {
            context.go(RouteNames.dashboard);
          }
          // Owner/Manager/Seller: Store байхгүй бол → Onboarding, байвал → Dashboard
          else if (user.storeId == null) {
            context.go(RouteNames.onboardingWelcome);
          } else {
            context.go(RouteNames.dashboard);
          }
        },
        error: (message) {
          setState(() => _errorText = message);
        },
        unauthenticated: () {},
        loading: () {},
        otpSent: (phone) {},
      );
    }
  }

  void _handleResend() async {
    if (_countdown > 0) return;

    // Resend OTP
    await ref.read(authNotifierProvider.notifier).sendOtp(widget.phoneNumber);
    _startCountdown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Баталгаажуулах код дахин илгээлээ'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Decorative gradient blobs
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
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      color: AppColors.textMainLight,
                    ),
                  ),

                  // Main content (centered)
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.radiusXXL,
                            border: Border.all(
                              color: AppColors.gray100,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gray200.withValues(alpha: 0.5),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with countdown
                              _buildHeader(),
                              AppSpacing.verticalMD,

                              // Description
                              _buildDescription(),
                              AppSpacing.verticalLG,

                              // OTP Input with Pinput
                              _buildPinput(),
                              if (_errorText != null) ...[
                                AppSpacing.verticalSM,
                                Text(
                                  _errorText!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              AppSpacing.verticalLG,

                              // Resend button
                              _buildResendButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (authState.maybeMap(loading: (_) => true, orElse: () => false))
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
        const Text(
          'Код оруулах',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: AppRadius.radiusSM,
          ),
          child: Text(
            '${_countdown.toString().padLeft(2, '0')}s',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    // Format phone number for display (e.g., 9911 2233)
    String formattedPhone = widget.phoneNumber;
    if (widget.phoneNumber.length == 8) {
      formattedPhone =
          '${widget.phoneNumber.substring(0, 4)} ${widget.phoneNumber.substring(4)}';
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.gray500,
          fontFamily: 'Noto Sans',
        ),
        children: [
          const TextSpan(text: 'Бид '),
          TextSpan(
            text: formattedPhone,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const TextSpan(
            text: ' дугаар руу 6 оронтой баталгаажуулах код илгээлээ.',
          ),
        ],
      ),
    );
  }

  Widget _buildPinput() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.primary.withValues(alpha: 0.05),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        color: AppColors.primary.withValues(alpha: 0.05),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.danger, width: 2),
        color: AppColors.danger.withValues(alpha: 0.05),
      ),
    );

    return Pinput(
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      forceErrorState: _errorText != null,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      closeKeyboardWhenCompleted: true,
      keyboardType: TextInputType.number,
      autofocus: true,
      onCompleted: _handleOtpComplete,
      onChanged: (value) {
        if (_errorText != null) {
          setState(() => _errorText = null);
        }
      },
    );
  }

  Widget _buildResendButton() {
    final canResend = _countdown == 0;

    return InkWell(
      onTap: canResend ? _handleResend : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            size: 18,
            color: canResend ? AppColors.primary : AppColors.gray300,
          ),
          const SizedBox(width: 8),
          Text(
            'Дахин илгээх',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: canResend ? AppColors.primary : AppColors.gray300,
              decoration:
                  canResend ? TextDecoration.underline : TextDecoration.none,
              decorationThickness: 2,
            ),
          ),
        ],
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
