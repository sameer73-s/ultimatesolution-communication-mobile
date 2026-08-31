import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/core/network/api_client.dart';
import 'package:ultimate_solution_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ultimate_solution_mobile/features/auth/data/models/auth_models.dart';
import 'package:ultimate_solution_mobile/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  test('persists access and refresh tokens and refreshes after repository recreation', () async {
    final tokenStore = InMemoryAccessTokenStore();
    final remote = _FakeAuthRemoteDataSource();
    final firstRepository = AuthRepositoryImpl(remote, tokenStore);

    final loginResult = await firstRepository.login(
      email: 'user@example.com',
      password: 'Password1!',
    );
    expect(loginResult.failure, isNull);
    expect(await tokenStore.read(), 'access-token');
    expect(await tokenStore.readRefresh(), 'refresh-token');

    final secondRepository = AuthRepositoryImpl(remote, tokenStore);
    final refreshResult = await secondRepository.refresh();
    expect(refreshResult.failure, isNull);
    expect(remote.lastRefreshToken, 'refresh-token');
  });

  test('surfaces Failure embedded in DioException.error instead of UnknownFailure', () async {
    const mapped = NetworkFailure('Unable to reach the server.');
    final remote = _ThrowingAuthRemoteDataSource(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.connectionError,
        error: mapped,
      ),
    );
    final repository = AuthRepositoryImpl(remote, InMemoryAccessTokenStore());

    final result = await repository.login(
      email: 'user@example.com',
      password: 'Password1!',
    );

    expect(result.session, isNull);
    expect(result.failure, same(mapped));
    expect(result.failure, isNot(isA<UnknownFailure>()));
    expect(result.failure?.message, 'Unable to reach the server.');
  });

  test('surfaces ApiFailure from DioException.error with backend message', () async {
    const mapped = ApiFailure('Invalid email or password.', statusCode: 401);
    final remote = _ThrowingAuthRemoteDataSource(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 401,
        ),
        error: mapped,
      ),
    );
    final repository = AuthRepositoryImpl(remote, InMemoryAccessTokenStore());

    final result = await repository.login(
      email: 'user@example.com',
      password: 'Password1!',
    );

    expect(result.failure, same(mapped));
    expect(result.failure?.message, 'Invalid email or password.');
  });
}

final class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? lastRefreshToken;

  AuthSessionModel get _session => AuthSessionModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAtUtc: DateTime.utc(2030),
    roles: const ['Employee'],
  );

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) async => _session;

  @override
  Future<AuthSessionModel> register(RegisterRequestModel request) async =>
      _session;

  @override
  Future<AuthSessionModel> refresh(RefreshTokenRequestModel request) async {
    lastRefreshToken = request.refreshToken;
    return _session;
  }
}

final class _ThrowingAuthRemoteDataSource implements AuthRemoteDataSource {
  _ThrowingAuthRemoteDataSource(this._error);

  final Object _error;

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) async =>
      throw _error;

  @override
  Future<AuthSessionModel> register(RegisterRequestModel request) async =>
      throw _error;

  @override
  Future<AuthSessionModel> refresh(RefreshTokenRequestModel request) async =>
      throw _error;
}
