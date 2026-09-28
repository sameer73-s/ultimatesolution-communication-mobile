import '../../../../core/errors/failures.dart';
import '../entities/chat_channel.dart';
import '../entities/chat_message.dart';
import '../entities/message_read.dart';

abstract interface class ChatRepository {
  Future<({List<ChatChannel>? channels, Failure? failure})> getChannels();

  Future<({ChatChannel? channel, Failure? failure})> getChannel(String channelId);

  Future<({ChatChannel? channel, Failure? failure})> createChannel({
    required ChatChannelType type,
    String? name,
    required List<String> memberIds,
  });

  Future<({List<ChatMessage>? messages, Failure? failure})> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  });

  Future<({ChatMessage? message, Failure? failure})> sendMessage({
    required String channelId,
    required String body,
  });

  Future<({ChatMessage? message, Failure? failure})> editMessage({
    required String messageId,
    required String body,
  });

  Future<({ChatMessage? message, Failure? failure})> deleteMessage(
    String messageId,
  );

  Future<({MessageRead? read, Failure? failure})> markMessageRead(
    String messageId,
  );

  Future<({ChatChannel? channel, Failure? failure})> addMember({
    required String channelId,
    required String userId,
  });

  Future<({ChatChannel? channel, Failure? failure})> removeMember({
    required String channelId,
    required String userId,
  });
}
