import 'package:flutter_test/flutter_test.dart';

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
