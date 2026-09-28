import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/chat_channel.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/chat_realtime_events.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/entities/message_read.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/repositories/chat_realtime_repository.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/get_channels_use_case.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:ultimate_solution_mobile/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:ultimate_solution_mobile/features/chat/presentation/bloc/channels_bloc.dart';
import 'package:ultimate_solution_mobile/features/chat/presentation/bloc/chat_conversation_bloc.dart';

void main() {
  final channel = ChatChannel(
    id: 'channel-1',
    name: 'Release Planning',
    type: ChatChannelType.group,
    createdByUserId: 'user-1',
    createdAtUtc: DateTime.utc(2026),
    isArchived: false,
    members: const [],
  );

  final message = ChatMessage(
    id: 'message-1',
    channelId: 'channel-1',
    senderUserId: 'user-1',
    body: 'Hello',
    createdAtUtc: DateTime.utc(2026, 1, 2),
  );

  test('ChannelsBloc emits loaded channels after successful fetch', () async {
    final repository = _FakeChatRepository(channels: [channel]);
    final bloc = ChannelsBloc(GetChannelsUseCase(repository));
    addTearDown(bloc.close);

    final states = <ChannelsState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const ChannelsLoadRequested());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(2));
    expect(states.first, isA<ChannelsLoading>());
    expect(states.last, isA<ChannelsLoaded>());
    expect((states.last as ChannelsLoaded).channels.first.name, channel.name);
  });

  test('ChatConversationBloc loads messages and merges send result', () async {
    final repository = _FakeChatRepository(messages: [message]);
    final realtime = _FakeChatRealtimeRepository();
    final bloc = ChatConversationBloc(
      GetMessagesUseCase(repository),
      SendMessageUseCase(repository),
      realtime,
    );
    addTearDown(bloc.close);

    final states = <ChatConversationState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const ChatConversationStarted('channel-1'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(states.any((state) => state is ChatConversationReady), isTrue);
    expect(realtime.connectCalled, isTrue);
    expect(realtime.subscribedChannelId, 'channel-1');

    bloc.add(const ChatMessageSendRequested('Follow up'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final ready = states.whereType<ChatConversationReady>().last;
    expect(ready.messages.any((item) => item.body == 'Follow up'), isTrue);
  });

  test('ChatConversationBloc appends realtime messageCreated events', () async {
    final repository = _FakeChatRepository(messages: const []);
    final realtime = _FakeChatRealtimeRepository();
    final bloc = ChatConversationBloc(
      GetMessagesUseCase(repository),
      SendMessageUseCase(repository),
      realtime,
    );
    addTearDown(bloc.close);

    final states = <ChatConversationState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const ChatConversationStarted('channel-1'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    realtime.emitMessageCreated(message);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final ready = states.whereType<ChatConversationReady>().last;
    expect(ready.messages, hasLength(1));
    expect(ready.messages.first.id, 'message-1');
  });
}

final class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({
    this.channels = const [],
    this.messages = const [],
  });

  final List<ChatChannel> channels;
  final List<ChatMessage> messages;

  @override
  Future<({List<ChatChannel>? channels, Failure? failure})> getChannels() async =>
      (channels: channels, failure: null);

  @override
  Future<({ChatChannel? channel, Failure? failure})> getChannel(
    String channelId,
  ) async => (channel: channels.firstOrNull, failure: null);

  @override
  Future<({ChatChannel? channel, Failure? failure})> createChannel({
    required ChatChannelType type,
    String? name,
    required List<String> memberIds,
  }) async => (channel: channels.firstOrNull, failure: null);

  @override
  Future<({List<ChatMessage>? messages, Failure? failure})> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async => (messages: messages, failure: null);

  @override
  Future<({ChatMessage? message, Failure? failure})> sendMessage({
    required String channelId,
    required String body,
  }) async => (
    message: ChatMessage(
      id: 'message-sent',
      channelId: channelId,
      senderUserId: 'user-1',
      body: body,
      createdAtUtc: DateTime.utc(2026, 1, 3),
    ),
    failure: null,
  );

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

final class _FakeChatRealtimeRepository implements ChatRealtimeRepository {
  final _messageCreated = StreamController<ChatMessage>.broadcast();
  final _messageUpdated = StreamController<ChatMessage>.broadcast();
  final _messageDeleted = StreamController<ChatMessage>.broadcast();
  final _typingChanged = StreamController<TypingChangedEvent>.broadcast();
  final _presenceChanged = StreamController<PresenceChangedEvent>.broadcast();

  bool connectCalled = false;
  String? subscribedChannelId;

  void emitMessageCreated(ChatMessage message) {
    _messageCreated.add(message);
  }

  @override
  Future<void> connect() async {
    connectCalled = true;
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> subscribeChannel(String channelId) async {
    subscribedChannelId = channelId;
  }

  @override
  Future<void> unsubscribeChannel(String channelId) async {}

  @override
  Future<void> startTyping(String channelId) async {}

  @override
  Future<void> stopTyping(String channelId) async {}

  @override
  Stream<ChatMessage> get messageCreated => _messageCreated.stream;

  @override
  Stream<ChatMessage> get messageUpdated => _messageUpdated.stream;

  @override
  Stream<ChatMessage> get messageDeleted => _messageDeleted.stream;

  @override
  Stream<TypingChangedEvent> get typingChanged => _typingChanged.stream;

  @override
  Stream<PresenceChangedEvent> get presenceChanged => _presenceChanged.stream;
}
