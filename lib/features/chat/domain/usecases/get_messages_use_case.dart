import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

final class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<({List<ChatMessage>? messages, Failure? failure})> call({
    required String channelId,
    String? search,
    int take = 50,
  }) {
    return _repository.getMessages(
      channelId: channelId,
      search: search,
      take: take,
    );
  }
}
