import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class EditMessageUseCase {
  const EditMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatMessage? message, Failure? failure})> call({
    required String messageId,
    required String body,
  }) {
    return _repository.editMessage(messageId: messageId, body: body);
  }
}
