import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/invite_seller_card.dart';
import 'package:retail_control_platform/features/onboarding/presentation/widgets/onboarding_page_wrapper.dart';

/// Худалдагч урих дэлгэц
class OnboardingInviteScreen extends ConsumerStatefulWidget {
  final String storeId;

  const OnboardingInviteScreen({super.key, required this.storeId});

  @override
  ConsumerState<OnboardingInviteScreen> createState() =>
      _OnboardingInviteScreenState();
}

class _OnboardingInviteScreenState
    extends ConsumerState<OnboardingInviteScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'seller';
  bool _isLoading = false;
  String? _errorText;
  final List<_InvitedUser> _invitedUsers = [];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      setState(() => _errorText = 'Утасны дугаар оруулна уу (8 оронтой)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final success = await notifier.inviteSeller(
      phone: phone,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      role: _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Урилга амжилттай илгээгдсэн - list-д нэмэх
        _invitedUsers.add(_InvitedUser(
          phone: phone,
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          role: _selectedRole,
        ));
        _phoneController.clear();
        _nameController.clear();
        setState(() {});

        // Success message харуулах
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Урилга амжилттай илгээгдлээ. Урилгаа хүлээн авсан хүн app татаж, OTP-аар нэвтэрнэ.',
            ),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorText = 'Урихад алдаа гарлаа. Дахин оролдоно уу.');
      }
    }
  }

  void _handleFinish() {
    context.go(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      currentStep: 2,
      title: 'Худалдагч урих',
      subtitle: 'Ажилтнуудаа урина уу. Дараа нэмж болно.',
      onBack: () =>
          context.go(RouteNames.onboardingProducts, extra: widget.storeId),
      bottomButton: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _invitedUsers.isEmpty ? 'Алгасах' : 'Дуусгах',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingHorizontalLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Урисан хүмүүсийн жагсаалт
            if (_invitedUsers.isNotEmpty) ...[
              ...List.generate(_invitedUsers.length, (index) {
                final user = _invitedUsers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InviteSellerCard(
                    phone: user.phone,
                    name: user.name,
                    role: user.role,
                  ),
                );
              }),
              AppSpacing.verticalMD,
            ],

            // Урих form
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray200.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ажилтан урих',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMainLight,
                    ),
                  ),
                  AppSpacing.verticalMD,

                  // Утасны дугаар
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    decoration: _inputDecoration(
                      label: 'Утасны дугаар',
                      hint: '99112233',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  AppSpacing.verticalSM,

                  // Нэр
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Нэр (заавал биш)',
                      hint: 'Болд',
                      icon: Icons.person_outlined,
                    ),
                  ),
                  AppSpacing.verticalSM,

                  // Role сонголт
                  Row(
                    children: [
                      const Text(
                        'Эрх: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildRoleChip('seller', 'Худалдагч'),
                      const SizedBox(width: 8),
                      _buildRoleChip('manager', 'Менежер'),
                    ],
                  ),

                  // Алдааны текст
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
                  AppSpacing.verticalMD,

                  // Урих товч
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleInvite,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Icon(Icons.person_add_outlined),
                      label:
                          Text(_isLoading ? 'Урьж байна...' : 'Урих'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLG,
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
      prefixIcon: Icon(icon, color: AppColors.gray500),
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

/// Урисан хэрэглэгчийн мэдээлэл (UI-д харуулахад)
class _InvitedUser {
  final String phone;
  final String? name;
  final String role;

  _InvitedUser({
    required this.phone,
    this.name,
    required this.role,
  });
}
