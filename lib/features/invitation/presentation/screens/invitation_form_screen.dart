import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/invitation/domain/invitation_model.dart';
import 'package:retail_control_platform/features/invitation/presentation/providers/invitation_provider.dart';

/// Урилга илгээх форм дэлгэц
/// Super-admin шинэ owner урилах форм
class InvitationFormScreen extends ConsumerStatefulWidget {
  const InvitationFormScreen({super.key});

  @override
  ConsumerState<InvitationFormScreen> createState() => _InvitationFormScreenState();
}

class _InvitationFormScreenState extends ConsumerState<InvitationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _role = 'owner';
  int _expiresInDays = 7;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Урилга илгээх',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Урилга авсан хэрэглэгч OTP код ашиглан бүртгүүлж, шинэ дэлгүүр үүсгэнэ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalLG,

              // Phone number input
              _buildPhoneInput(),
              AppSpacing.verticalMD,

              // Role selector
              _buildRoleSelector(),
              AppSpacing.verticalMD,

              // Expires in days
              _buildExpirySelector(),
              AppSpacing.verticalXL,

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                  label: Text(
                    _isLoading ? 'Илгээж байна...' : 'Урилга илгээх',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phone input (8 digits)
  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Утасны дугаар',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: InputDecoration(
            hintText: '99112233',
            prefixText: '+976 ',
            prefixStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.textMainLight,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Утасны дугаар оруулна уу';
            }
            if (value.length != 8) {
              return '8 оронтой дугаар оруулна уу';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Role selector (owner only for MVP)
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Хэрэглэгчийн эрх',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: [
              const Icon(Icons.badge_outlined, size: 20, color: AppColors.gray600),
              const SizedBox(width: 12),
              const Text(
                'Эзэмшигч (Owner)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMainLight,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Тогтмол',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Expiry days selector
  Widget _buildExpirySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дуусах хугацаа',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _expiresInDays,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
              items: [1, 3, 7, 14, 30].map((days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text(
                    '$days хоног',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMainLight,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _expiresInDays = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Submit handler
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = '+976${_phoneController.text}';
      final request = CreateInvitationRequest(
        phone: phone,
        role: _role,
        expiresInDays: _expiresInDays,
      );

      await ref.read(invitationNotifierProvider.notifier).createInvitation(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$phone дугаарт урилга илгээлээ'),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Алдаа: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
