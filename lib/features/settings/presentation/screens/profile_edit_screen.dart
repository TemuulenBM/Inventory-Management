import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/settings/presentation/providers/profile_provider.dart';

/// Profile засварлах дэлгэц
/// Хэрэглэгчийн нэр засах (утас зөвхөн харуулна)
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Одоогийн нэрийг form-д оруулах
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.name != null) {
        _nameController.text = user!.name!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final newName = _nameController.text.trim();
    final success = await ref.read(profileNotifierProvider.notifier).updateProfile(
          name: newName,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Амжилттай - буцах
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile амжилттай шинэчлэгдлээ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorText = 'Profile шинэчлэхэд алдаа гарлаа');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Profile засах',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingHorizontalLG,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppSpacing.verticalXL,

              // Profile icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outlined,
                  color: AppColors.primary,
                  size: 50,
                ),
              ),
              AppSpacing.verticalXL,

              // Нэр
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Нэр оруулна уу';
                  }
                  if (value.trim().length < 2) {
                    return 'Нэр хамгийн багадаа 2 тэмдэгт байх ёстой';
                  }
                  return null;
                },
                decoration: _inputDecoration(
                  label: 'Нэр',
                  hint: 'Жишээ: Болд',
                  icon: Icons.badge_outlined,
                ),
              ),
              AppSpacing.verticalMD,

              // Утас (засах боломжгүй)
              TextFormField(
                initialValue: user?.phone ?? '',
                enabled: false,
                decoration: _inputDecoration(
                  label: 'Утасны дугаар',
                  hint: '+976XXXXXXXX',
                  icon: Icons.phone_outlined,
                ),
                style: const TextStyle(color: AppColors.gray500),
              ),
              AppSpacing.verticalMD,

              // Роль (засах боломжгүй)
              TextFormField(
                initialValue: _getRoleName(user?.role ?? ''),
                enabled: false,
                decoration: _inputDecoration(
                  label: 'Роль',
                  hint: 'Таны эрх',
                  icon: Icons.shield_outlined,
                ),
                style: const TextStyle(color: AppColors.gray500),
              ),

              // Алдааны текст
              if (_errorText != null) ...{
                AppSpacing.verticalMD,
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              },

              AppSpacing.verticalXL,

              // Хадгалах товч
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Хадгалах',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
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
      prefixIcon: Icon(icon, color: AppColors.gray500),
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'owner':
        return 'Эзэн';
      case 'manager':
        return 'Менежер';
      case 'seller':
        return 'Худалдагч';
      case 'super_admin':
        return 'Супер админ';
      default:
        return role;
    }
  }
}
