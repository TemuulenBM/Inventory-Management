import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_model.freezed.dart';
part 'invitation_model.g.dart';

/// Урилгын төлөв (status)
enum InvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('used')
  used,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
}

/// Урилгын мэдээлэл
/// Backend-ээс ирэх invitation object
@freezed
class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    required String id,
    required String phone,
    required String role,
    required InvitationStatus status,
    @JsonKey(name: 'invited_by') String? invitedBy,
    @JsonKey(name: 'invited_at') required DateTime invitedAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'used_at') DateTime? usedAt,
    @JsonKey(name: 'used_by') String? usedBy,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);
}

/// Урилга үүсгэх request DTO
@freezed
class CreateInvitationRequest with _$CreateInvitationRequest {
  const factory CreateInvitationRequest({
    required String phone,
    @Default('owner') String role,
    @Default(7) int expiresInDays,
  }) = _CreateInvitationRequest;

  factory CreateInvitationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvitationRequestFromJson(json);
}
