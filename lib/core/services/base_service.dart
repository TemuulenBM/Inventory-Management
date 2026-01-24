import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';

/// Base Service - Бүх service-үүдийн суурь класс
/// API Client болон Local Database-тэй ажиллах нийтлэг функцүүд
abstract class BaseService {
  final AppDatabase db;

  BaseService({required this.db});

  /// API Client instance
  ApiClient get api => apiClient;

  /// Сүлжээнд холбогдсон эсэхийг шалгах
  Future<bool> get isOnline async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  /// SyncQueue-д үйлдэл нэмэх (offline үед)
  Future<int> enqueueOperation({
    required String entityType,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    return await db.enqueueSyncOperation(
      entityType: entityType,
      operation: operation,
      payload: jsonEncode(payload),
    );
  }

  /// API хүсэлт хийх ба алдааг ApiResult-д хөрвүүлэх
  Future<ApiResult<T>> safeApiCall<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await apiCall();

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data['success'] == true) {
          return ApiResult.success(parser(response.data));
        } else {
          return ApiResult.error(
            response.data['message'] ?? 'Алдаа гарлаа',
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResult.error(
          response.data['message'] ?? 'Сервер алдаа',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.message}');
      }

      String message;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Холболт хугацаа хэтэрлээ. Дахин оролдоно уу.';
          break;
        case DioExceptionType.connectionError:
          message = 'Сүлжээнд холбогдож чадсангүй';
          break;
        case DioExceptionType.badResponse:
          message = e.response?.data?['message'] ?? 'Сервер алдаа';
          break;
        default:
          message = 'Алдаа гарлаа: ${e.message}';
      }

      return ApiResult.error(
        message,
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      return ApiResult.error(
        'Тодорхойгүй алдаа гарлаа',
        originalError: e,
      );
    }
  }

  /// Debug log
  void log(String message) {
    if (kDebugMode) {
      print('[${runtimeType.toString()}] $message');
    }
  }
}
