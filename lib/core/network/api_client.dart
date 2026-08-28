import 'package:dio/dio.dart';

import 'dio_failure_mapper.dart';

abstract interface class AccessTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

final class InMemoryAccessTokenStore implements AccessTokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

final class ApiClient {
  ApiClient({required AccessTokenStore tokenStore})
    : dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:5000',
          ),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(error.copyWith(error: mapDioError(error)));
        },
      ),
    );
  }

  final Dio dio;
}
