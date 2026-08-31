import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/login_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/logout_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/refresh_session_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/domain/usecases/register_use_case.dart';
import 'package:ultimate_solution_mobile/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  final session = AuthSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAtUtc: DateTime(2030),
    roles: ['Employee'],
  );

  test('emits authenticated after successful login', () async {
    final repository = _FakeAuthRepository(session: session);
    final bloc = AuthBloc(
      LoginUseCase(repository),
      RegisterUseCase(repository),
      RefreshSessionUseCase(repository),
      LogoutUseCase(repository),
    );
    addTearDown(bloc.close);

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(
      const LoginSubmitted(email: 'user@example.com', password: 'Password1!'),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(2));
    expect(states.first, isA<AuthLoading>());
    expect(states.last, isA<AuthAuthenticated>());
  });

  test('emits unauthenticated failure when refresh has no session', () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      LoginUseCase(repository),
      RegisterUseCase(repository),
      RefreshSessionUseCase(repository),
      LogoutUseCase(repository),
    );
    addTearDown(bloc.close);

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const RefreshRequested());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(2));
    expect(states.last, isA<AuthUnauthenticated>());
    expect(
      (states.last as AuthUnauthenticated).failure,
      isA<UnauthorizedFailure>(),
    );
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final AuthSession? session;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async => (
    session: session,
    failure: session == null ? const UnknownFailure() : null,
  );

  @override
  Future<({AuthSession? session, Failure? failure})> register({
    required String email,
    required String password,
    required String displayName,
  }) async => (
    session: session,
    failure: session == null ? const UnknownFailure() : null,
  );

  @override
  Future<({AuthSession? session, Failure? failure})> refresh() async =>
      (session: null, failure: const UnauthorizedFailure());

  @override
  Future<void> logout() async {}
}
