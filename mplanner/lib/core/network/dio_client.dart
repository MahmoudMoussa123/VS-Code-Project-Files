import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';
import '../error/app_exception.dart';
import '../services/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (e, handler) {
      handler.reject(_mapError(e));
    },
  ));

  return dio;
});

DioError _mapError(DioError e) {
  final status = e.response?.statusCode;
  if (status == 404) {
    return e;
  }
  if (e.type == DioErrorType.connectionTimeout || e.type == DioErrorType.receiveTimeout) {
    throw const NetworkException('Network timeout');
  }
  throw NetworkException('Network error', statusCode: status, cause: e);
}