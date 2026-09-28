import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatMessage? message, Failure? failure})> call({
    required String channelId,
    required String body,
  }) {
    return _repository.sendMessage(channelId: channelId, body: body);
  }
}
