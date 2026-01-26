import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/invitation/domain/invitation_model.dart';

part 'invitation_provider.g.dart';

/// Урилгын жагсаалт provider
/// GET /invitations
@riverpod
Future<List<InvitationModel>> invitationList(
  InvitationListRef ref, {
  InvitationStatus? status,
}) async {
  final queryParams = <String, dynamic>{};
  if (status != null) {
    queryParams['status'] = status.name;
  }

  final response = await apiClient.get(
    ApiEndpoints.invitations,
    queryParameters: queryParams,
  );

  if (response.statusCode == 200 && response.data['success'] == true) {
    final invitations = (response.data['invitations'] as List)
        .map((json) => InvitationModel.fromJson(json))
        .toList();
    return invitations;
  }

  throw Exception('Урилгын жагсаалт татаж чадсангүй');
}

/// Урилга үүсгэх/устгах notifier
@riverpod
class InvitationNotifier extends _$InvitationNotifier {
  @override
  void build() {
    // No initial state needed
  }

  /// Урилга үүсгэх
  /// POST /invitations
  Future<InvitationModel> createInvitation(CreateInvitationRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.invitations,
        data: request.toJson(),
      );

      // 200 OK эсвэл 201 Created хүлээн авах
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final invitation = InvitationModel.fromJson(response.data['invitation']);

        // Жагсаалт refresh хийх
        ref.invalidate(invitationListProvider);

        return invitation;
      }

      throw Exception(response.data['error'] ?? 'Урилга үүсгэхэд алдаа гарлаа');
    } on DioException catch (e) {
      // Backend-ээс ирсэн error message татах
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Урилга үүсгэхэд алдаа гарлаа');
    }
  }

  /// Урилга цуцлах (DELETE)
  /// DELETE /invitations/:id
  Future<void> deleteInvitation(String invitationId) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.invitation(invitationId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Жагсаалт refresh хийх
        ref.invalidate(invitationListProvider);
        return;
      }

      throw Exception(response.data['error'] ?? 'Урилга устгахад алдаа гарлаа');
    } on DioException catch (e) {
      // Backend-ээс ирсэн error message татах
      if (e.response?.data != null && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Урилга устгахад алдаа гарлаа');
    }
  }
}
