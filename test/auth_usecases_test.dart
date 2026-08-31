import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/login_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/logout_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/refresh_session_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/register_use_case.dart';

void main() {
  final session = AuthSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAtUtc: DateTime(2030),
    roles: ['Employee'],
  );

  test('LoginUseCase delegates credentials to AuthRepository', () async {
    final repository = _RecordingAuthRepository(session: session);

    final result = await LoginUseCase(repository)(
      email: 'user@example.com',
      password: 'Password1!',
    );

    expect(result.session, session);
    expect(repository.loginEmail, 'user@example.com');
    expect(repository.loginPassword, 'Password1!');
  });

  test(
    'RegisterUseCase delegates registration data to AuthRepository',
    () async {
      final repository = _RecordingAuthRepository(session: session);

      final result = await RegisterUseCase(repository)(
        email: 'user@example.com',
        password: 'Password1!',
        displayName: 'User',
      );

      expect(result.session, session);
      expect(repository.registerEmail, 'user@example.com');
      expect(repository.registerPassword, 'Password1!');
      expect(repository.registerDisplayName, 'User');
    },
  );

  test('RefreshSessionUseCase delegates refresh to AuthRepository', () async {
    final repository = _RecordingAuthRepository(session: session);

    final result = await RefreshSessionUseCase(repository)();

    expect(result.session, session);
    expect(repository.refreshCalled, isTrue);
  });

  test('LogoutUseCase delegates logout to AuthRepository', () async {
    final repository = _RecordingAuthRepository(session: session);

    await LogoutUseCase(repository)();

    expect(repository.logoutCalled, isTrue);
  });
}

final class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository({required this.session});

  final AuthSession session;
  String? loginEmail;
  String? loginPassword;
  String? registerEmail;
  String? registerPassword;
  String? registerDisplayName;
  bool refreshCalled = false;
  bool logoutCalled = false;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    loginPassword = password;
    return (session: session, failure: null);
  }

  @override
  Future<({AuthSession? session, Failure? failure})> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    registerEmail = email;
    registerPassword = password;
    registerDisplayName = displayName;
    return (session: session, failure: null);
  }

  @override
  Future<({AuthSession? session, Failure? failure})> refresh() async {
    refreshCalled = true;
    return (session: session, failure: null);
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}
