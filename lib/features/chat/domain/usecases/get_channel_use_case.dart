import '../../../../core/errors/failures.dart';
import '../entities/chat_channel.dart';
import '../repositories/chat_repository.dart';

final class GetChannelUseCase {
  const GetChannelUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatChannel? channel, Failure? failure})> call(String channelId) {
    return _repository.getChannel(channelId);
  }
}
