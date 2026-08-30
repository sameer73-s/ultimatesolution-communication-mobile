import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStore);

  final AuthRemoteDataSource _remote;
  final AccessTokenStore _tokenStore;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) => _execute(
    () => _remote.login(LoginRequestModel(email: email, password: password)),
  );

  @override
  Future<({AuthSession? session, Failure? failure})> register({
    required String email,
    required String password,
    required String displayName,
  }) => _execute(
    () => _remote.register(
      RegisterRequestModel(
        email: email,
        password: password,
        displayName: displayName,
      ),
    ),
  );

  @override
  Future<({AuthSession? session, Failure? failure})> refresh() async {
    final refreshToken = await _tokenStore.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) {
      return (session: null, failure: const UnauthorizedFailure());
    }
    return _execute(
      () => _remote.refresh(RefreshTokenRequestModel(refreshToken)),
    );
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clear();
  }

  Future<({AuthSession? session, Failure? failure})> _execute(
    Future<AuthSessionModel> Function() action,
  ) async {
    try {
      final model = await action();
      await _tokenStore.write(model.accessToken);
      await _tokenStore.writeRefresh(model.refreshToken);
      return (session: model.toEntity(), failure: null);
    } catch (error) {
      return (
        session: null,
        failure: error is Failure ? error : const UnknownFailure(),
      );
    }
  }
}
