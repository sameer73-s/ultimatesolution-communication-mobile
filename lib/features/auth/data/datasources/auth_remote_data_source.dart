import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login(LoginRequestModel request);
  Future<AuthSessionModel> register(RegisterRequestModel request);
  Future<AuthSessionModel> refresh(RefreshTokenRequestModel request);
}

final class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  const DioAuthRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) =>
      _send('/api/v1/auth/login', request.toJson());

  @override
  Future<AuthSessionModel> register(RegisterRequestModel request) =>
      _send('/api/v1/auth/register', request.toJson());

  @override
  Future<AuthSessionModel> refresh(RefreshTokenRequestModel request) =>
      _send('/api/v1/auth/refresh', request.toJson());

  Future<AuthSessionModel> _send(String path, Map<String, dynamic> body) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      path,
      data: body,
    );
    final payload = response.data ?? const <String, dynamic>{};
    if (payload['success'] != true ||
        payload['data'] is! Map<String, dynamic>) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 500,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    return AuthSessionModel.fromJson(payload['data']! as Map<String, dynamic>);
  }
}
