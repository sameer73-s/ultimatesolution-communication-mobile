import '../../../../core/errors/failures.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  Future<({AuthSession? session, Failure? failure})> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<({AuthSession? session, Failure? failure})> refresh();

  Future<void> logout();
}
