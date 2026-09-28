import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/chat_channel.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/message_read.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/get_channels_use_case.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/send_message_use_case.dart';

void main() {
  test('GetChannelsUseCase delegates to ChatRepository only', () async {
    final repository = _RecordingChatRepository();
    final result = await GetChannelsUseCase(repository)();

    expect(result.channels, isEmpty);
    expect(repository.getChannelsCalled, isTrue);
  });

  test('GetMessagesUseCase passes channelId and pagination args', () async {
    final repository = _RecordingChatRepository();
    await GetMessagesUseCase(repository)(
      channelId: 'channel-1',
      search: 'approved',
      take: 10,
    );

    expect(repository.lastMessagesChannelId, 'channel-1');
    expect(repository.lastSearch, 'approved');
    expect(repository.lastTake, 10);
  });

  test('SendMessageUseCase delegates body to ChatRepository', () async {
    final repository = _RecordingChatRepository();
    final result = await SendMessageUseCase(repository)(
      channelId: 'channel-1',
      body: 'Hello',
    );

    expect(result.message?.body, 'Hello');
    expect(repository.lastSendBody, 'Hello');
  });
}

final class _RecordingChatRepository implements ChatRepository {
  bool getChannelsCalled = false;
  String? lastMessagesChannelId;
  String? lastSearch;
  int? lastTake;
  String? lastSendBody;

  @override
  Future<({List<ChatChannel>? channels, Failure? failure})> getChannels() async {
    getChannelsCalled = true;
    return (channels: const <ChatChannel>[], failure: null);
  }

  @override
  Future<({ChatChannel? channel, Failure? failure})> getChannel(
    String channelId,
  ) async => (channel: null, failure: const UnknownFailure());

  @override
  Future<({ChatChannel? channel, Failure? failure})> createChannel({
    required ChatChannelType type,
    String? name,
    required List<String> memberIds,
  }) async => (channel: null, failure: const UnknownFailure());

  @override
  Future<({List<ChatMessage>? messages, Failure? failure})> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async {
    lastMessagesChannelId = channelId;
    lastSearch = search;
    lastTake = take;
    return (messages: const <ChatMessage>[], failure: null);
  }

  @override
  Future<({ChatMessage? message, Failure? failure})> sendMessage({
    required String channelId,
    required String body,
  }) async {
    lastSendBody = body;
    return (
      message: ChatMessage(
        id: 'm1',
        channelId: channelId,
        senderUserId: 'u1',
        body: body,
        createdAtUtc: DateTime.utc(2026),
      ),
      failure: null,
    );
  }

  @override
  Future<({ChatMessage? message, Failure? failure})> editMessage({
    required String messageId,
    required String body,
  }) async => (message: null, failure: const UnknownFailure());

  @override
  Future<({ChatMessage? message, Failure? failure})> deleteMessage(
    String messageId,
  ) async => (message: null, failure: const UnknownFailure());

  @override
  Future<({MessageRead? read, Failure? failure})> markMessageRead(
    String messageId,
  ) async => (read: null, failure: const UnknownFailure());

  @override
  Future<({ChatChannel? channel, Failure? failure})> addMember({
    required String channelId,
    required String userId,
  }) async => (channel: null, failure: const UnknownFailure());

  @override
  Future<({ChatChannel? channel, Failure? failure})> removeMember({
    required String channelId,
    required String userId,
  }) async => (channel: null, failure: const UnknownFailure());
}
