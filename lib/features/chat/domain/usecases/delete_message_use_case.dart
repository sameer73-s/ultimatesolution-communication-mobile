import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class DeleteMessageUseCase {
  const DeleteMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatMessage? message, Failure? failure})> call(String messageId) {
    return _repository.deleteMessage(messageId);
  }
}
