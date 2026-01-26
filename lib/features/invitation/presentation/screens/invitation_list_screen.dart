import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/widgets/modals/confirm_dialog.dart';
import 'package:retail_control_platform/features/invitation/domain/invitation_model.dart';
import 'package:retail_control_platform/features/invitation/presentation/providers/invitation_provider.dart';

/// Урилгын жагсаалт дэлгэц
/// Super-admin илгээсэн урилгуудын жагсаалт
class InvitationListScreen extends ConsumerStatefulWidget {
  const InvitationListScreen({super.key});

  @override
  ConsumerState<InvitationListScreen> createState() => _InvitationListScreenState();
}

class _InvitationListScreenState extends ConsumerState<InvitationListScreen> {
  InvitationStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(invitationListProvider(status: _selectedStatus));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Урилгын жагсаалт',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),
          AppSpacing.verticalSM,

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(invitationListProvider);
              },
              child: invitationsAsync.when(
                data: (invitations) => invitations.isEmpty
                    ? _buildEmptyState()
                    : _buildList(invitations),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.createInvitation),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Урилга илгээх',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Filter tabs (All, Pending, Used, Expired)
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Бүгд', null),
          const SizedBox(width: 8),
          _buildFilterChip('Хүлээгдэж буй', InvitationStatus.pending),
          const SizedBox(width: 8),
          _buildFilterChip('Ашигласан', InvitationStatus.used),
          const SizedBox(width: 8),
          _buildFilterChip('Дууссан', InvitationStatus.expired),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, InvitationStatus? status) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.primary : AppColors.gray600,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.gray300,
      ),
    );
  }

  /// Invitation list
  Widget _buildList(List<InvitationModel> invitations) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invitations.length,
      separatorBuilder: (context, index) => AppSpacing.verticalSM,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return _buildInvitationCard(invitation);
      },
    );
  }

  /// Invitation card
  Widget _buildInvitationCard(InvitationModel invitation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (phone + status badge)
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 20, color: AppColors.gray500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invitation.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
              ),
              _buildStatusBadge(invitation.status),
            ],
          ),
          const SizedBox(height: 12),

          // Role
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: AppColors.gray500),
              const SizedBox(width: 8),
              Text(
                _getRoleName(invitation.role),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Invited at
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.gray500),
              const SizedBox(width: 8),
              Text(
                'Илгээсэн: ${DateFormat('yyyy-MM-dd HH:mm').format(invitation.invitedAt)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Expires at
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18, color: AppColors.gray500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Дуусах: ${DateFormat('yyyy-MM-dd HH:mm').format(invitation.expiresAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),

          // Delete button (pending only)
          if (invitation.status == InvitationStatus.pending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleDelete(invitation),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Цуцлах',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Status badge
  Widget _buildStatusBadge(InvitationStatus status) {
    final String label;
    final Color color;

    switch (status) {
      case InvitationStatus.pending:
        label = 'Хүлээгдэж буй';
        color = AppColors.warningOrange;
        break;
      case InvitationStatus.used:
        label = 'Ашигласан';
        color = AppColors.successGreen;
        break;
      case InvitationStatus.expired:
        label = 'Дууссан';
        color = AppColors.gray500;
        break;
      case InvitationStatus.revoked:
        label = 'Цуцалсан';
        color = AppColors.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline,
              size: 50,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Урилга олдсонгүй',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Шинэ owner бүртгүүлэхийн тулд\nурилга илгээнэ үү',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Алдаа гарлаа',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Delete invitation handler
  Future<void> _handleDelete(InvitationModel invitation) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Урилга цуцлах',
      message: '${invitation.phone} дугаарт илгээсэн урилгыг цуцлах уу?',
      confirmText: 'Цуцлах',
      cancelText: 'Буцах',
      isDanger: true,
      icon: Icons.delete_outline,
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(invitationNotifierProvider.notifier).deleteInvitation(invitation.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Урилга цуцлагдлаа'),
              duration: Duration(seconds: 2),
            ),
          );
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
      }
    }
  }

  /// Get role name in Mongolian
  String _getRoleName(String role) {
    switch (role) {
      case 'owner':
        return 'Эзэмшигч';
      case 'manager':
        return 'Менежер';
      case 'seller':
        return 'Худалдагч';
      default:
        return role;
    }
  }
}
