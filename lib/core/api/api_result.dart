import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

/// API Result - API хүсэлтийн үр дүнг хадгалах union type
/// Success эсвэл Error төлөвтэй байж болно
@freezed
class ApiResult<T> with _$ApiResult<T> {
  /// Амжилттай үр дүн
  const factory ApiResult.success(T data) = ApiSuccess<T>;

  /// Алдаатай үр дүн
  const factory ApiResult.error(
    String message, {
    int? statusCode,
    dynamic originalError,
  }) = ApiError<T>;
}

/// ApiResult extensions
extension ApiResultExtension<T> on ApiResult<T> {
  /// Success бол data буцаах, error бол null
  T? get dataOrNull => when(
        success: (data) => data,
        error: (_, __, ___) => null,
      );

  /// Success эсэх
  bool get isSuccess => this is ApiSuccess<T>;

  /// Error эсэх
  bool get isError => this is ApiError<T>;

  /// Error message авах (error бол)
  String? get errorMessage => when(
        success: (_) => null,
        error: (message, _, __) => message,
      );

  /// Map success data to another type
  ApiResult<R> mapData<R>(R Function(T data) mapper) => when(
        success: (data) => ApiResult.success(mapper(data)),
        error: (message, statusCode, originalError) =>
            ApiResult.error(message, statusCode: statusCode, originalError: originalError),
      );
}
