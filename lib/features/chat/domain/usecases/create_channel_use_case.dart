import '../../../../core/errors/failures.dart';
import '../entities/chat_channel.dart';
import '../repositories/chat_repository.dart';

final class CreateChannelUseCase {
  const CreateChannelUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatChannel? channel, Failure? failure})> call({
    required ChatChannelType type,
    String? name,
    required List<String> memberIds,
  }) {
    return _repository.createChannel(
      type: type,
      name: name,
      memberIds: memberIds,
    );
  }
}
