import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// API Client - Backend API-тай холбогдох
/// Dio ашиглан HTTP requests илгээнэ
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Refresh token concurrent request хамгаалалт
  bool _isRefreshing = false;

  ApiClient._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request interceptor - add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // DELETE request body байхгүй үед Content-Type header устгах
          // Fastify "Body cannot be empty when content-type is set" алдаа өгөхөөс сэргийлнэ
          if (options.method == 'DELETE' && options.data == null) {
            options.headers.remove('Content-Type');
            options.headers.remove('content-type');
          }

          if (kDebugMode) {
            print('📤 ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('📥 ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('   ${error.message}');
          }

          // Sentry breadcrumb — алдааны context бүрдүүлэх
          Sentry.addBreadcrumb(Breadcrumb.http(
            url: error.requestOptions.uri,
            method: error.requestOptions.method,
            statusCode: error.response?.statusCode,
            reason: error.message,
          ));

          // 401 Unauthorized - try to refresh token
          // IMPORTANT: /auth/refresh хүсэлтийг давтахгүй (infinite loop үүсгэхгүй)
          final isRefreshRequest = error.requestOptions.path.contains('/auth/refresh');
          if (error.response?.statusCode == 401 && !isRefreshRequest) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry the original request
              final options = error.requestOptions;
              final token = await _storage.read(key: _accessTokenKey);
              options.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh амжилтгүй - tokens устгах
              await clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Refresh token хийх
  Future<bool> _tryRefreshToken() async {
    // Аль хэдийн refresh хийж байгаа бол дахин хийхгүй
    if (_isRefreshing) return false;

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tokens = response.data['tokens'];
        await saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
        _isRefreshing = false;
        return true;
      }
      _isRefreshing = false;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      _isRefreshing = false;
      return false;
    }
  }

  /// Token хадгалах
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Token устгах (logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if user has tokens
  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  // ============================================================================
  // HTTP Methods
  // ============================================================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    // DELETE request interceptor дээр Content-Type header устгана
    // (body байхгүй үед, Fastify алдаа өгөхгүй байх)
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Convenience getter
ApiClient get apiClient => ApiClient.instance;
