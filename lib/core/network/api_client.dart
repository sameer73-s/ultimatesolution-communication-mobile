import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dio_failure_mapper.dart';

abstract interface class AccessTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<String?> readRefresh();
  Future<void> writeRefresh(String token);
  Future<void> clear();
}

/// Durable token storage for authenticated sessions.
/// Uses the platform secure storage implementation provided by
/// `flutter_secure_storage`.
final class SecureAccessTokenStore implements AccessTokenStore {
  SecureAccessTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> write(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeRefresh(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// Temporary in-memory storage for development and tests only.
/// It must never be used for production authentication sessions.
final class InMemoryAccessTokenStore implements AccessTokenStore {
  String? _token;
  String? _refreshToken;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<String?> readRefresh() async => _refreshToken;

  @override
  Future<void> writeRefresh(String token) async => _refreshToken = token;

  @override
  Future<void> clear() async {
    _token = null;
    _refreshToken = null;
  }
}

final class ApiClient {
  ApiClient({required AccessTokenStore tokenStore})
    : dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:5042',
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
