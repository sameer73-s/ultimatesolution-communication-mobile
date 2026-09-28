import '../../../../core/errors/failures.dart';
import '../entities/chat_channel.dart';
import '../repositories/chat_repository.dart';

final class GetChannelsUseCase {
  const GetChannelsUseCase(this._repository);

  final ChatRepository _repository;

  Future<({List<ChatChannel>? channels, Failure? failure})> call() {
    return _repository.getChannels();
  }
}
