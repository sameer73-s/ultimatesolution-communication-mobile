import '../../../../core/errors/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<({AuthSession? session, Failure? failure})> call() {
    return _repository.refresh();
  }
}
