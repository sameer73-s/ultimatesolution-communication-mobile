import '../../../../core/errors/failures.dart';
import '../entities/message_read.dart';
import '../repositories/chat_repository.dart';

final class MarkMessageReadUseCase {
  const MarkMessageReadUseCase(this._repository);

  final ChatRepository _repository;

  Future<({MessageRead? read, Failure? failure})> call(String messageId) {
    return _repository.markMessageRead(messageId);
  }
}
