import '../../../../core/errors/failures.dart';
import '../entities/chat_channel.dart';
import '../repositories/chat_repository.dart';

final class AddChannelMemberUseCase {
  const AddChannelMemberUseCase(this._repository);

  final ChatRepository _repository;

  Future<({ChatChannel? channel, Failure? failure})> call({
    required String channelId,
    required String userId,
  }) {
    return _repository.addMember(channelId: channelId, userId: userId);
  }
}
