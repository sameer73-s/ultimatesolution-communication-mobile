import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ultimate_solution_mobile/core/errors/failures.dart';
import 'package:ultimate_solution_mobile/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ultimate_solution_mobile/features/chat/data/models/chat_models.dart';
import 'package:ultimate_solution_mobile/features/chat/data/repositories/chat_repository_impl.dart';

void main() {
  test('maps channel list models to entities', () async {
    final remote = _FakeChatRemoteDataSource();
    final repository = ChatRepositoryImpl(remote);

    final result = await repository.getChannels();

    expect(result.failure, isNull);
    expect(result.channels, isNotNull);
    expect(result.channels, hasLength(1));
    expect(result.channels!.first.name, 'Release Planning');
    expect(result.channels!.first.members, hasLength(1));
  });

  test('surfaces Failure embedded in DioException.error instead of UnknownFailure', () async {
    const mapped = NetworkFailure('Unable to reach the server.');
    final remote = _ThrowingChatRemoteDataSource(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/channels'),
        type: DioExceptionType.connectionError,
        error: mapped,
      ),
    );
    final repository = ChatRepositoryImpl(remote);

    final result = await repository.getChannels();

    expect(result.channels, isNull);
    expect(result.failure, same(mapped));
    expect(result.failure, isNot(isA<UnknownFailure>()));
  });

  test('sendMessage returns created message entity', () async {
    final remote = _FakeChatRemoteDataSource();
    final repository = ChatRepositoryImpl(remote);

    final result = await repository.sendMessage(
      channelId: 'channel-1',
      body: 'Hello',
    );

    expect(result.failure, isNull);
    expect(result.message?.body, 'Hello');
    expect(result.message?.channelId, 'channel-1');
    expect(result.message?.senderUserId, 'user-1');
  });
}

final class _FakeChatRemoteDataSource implements ChatRemoteDataSource {
  ChatChannelModel get _channel => ChatChannelModel(
    id: 'channel-1',
    name: 'Release Planning',
    type: 2,
    createdByUserId: 'user-1',
    createdAtUtc: DateTime.utc(2026, 1, 1),
    isArchived: false,
    members: [
      ChannelMembershipModel(
        userId: 'user-2',
        role: 1,
        joinedAtUtc: DateTime.utc(2026, 1, 1),
      ),
    ],
  );

  ChatMessageModel get _message => ChatMessageModel(
    id: 'message-1',
    channelId: 'channel-1',
    senderUserId: 'user-1',
    body: 'Hello',
    createdAtUtc: DateTime.utc(2026, 1, 2),
  );

  @override
  Future<List<ChatChannelModel>> getChannels() async => [_channel];

  @override
  Future<ChatChannelModel> getChannel(String channelId) async => _channel;

  @override
  Future<ChatChannelModel> createChannel(
    CreateChannelRequestModel request,
  ) async => _channel;

  @override
  Future<List<ChatMessageModel>> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async => [_message];

  @override
  Future<ChatMessageModel> sendMessage({
    required String channelId,
    required SendChatMessageRequestModel request,
  }) async => ChatMessageModel(
    id: 'message-1',
    channelId: channelId,
    senderUserId: 'user-1',
    body: request.body,
    createdAtUtc: DateTime.utc(2026, 1, 2),
  );

  @override
  Future<ChatMessageModel> editMessage({
    required String messageId,
    required UpdateChatMessageRequestModel request,
  }) async => _message;

  @override
  Future<ChatMessageModel> deleteMessage(String messageId) async => _message;

  @override
  Future<MessageReadModel> markMessageRead(String messageId) async =>
      MessageReadModel(
        channelId: 'channel-1',
        userId: 'user-1',
        lastReadMessageId: messageId,
        lastReadAtUtc: DateTime.utc(2026, 1, 3),
      );

  @override
  Future<ChatChannelModel> addMember({
    required String channelId,
    required AddChannelMemberRequestModel request,
  }) async => _channel;

  @override
  Future<ChatChannelModel> removeMember({
    required String channelId,
    required String userId,
  }) async => _channel;
}

final class _ThrowingChatRemoteDataSource implements ChatRemoteDataSource {
  _ThrowingChatRemoteDataSource(this._error);

  final Object _error;

  Never _throw() => throw _error;

  @override
  Future<List<ChatChannelModel>> getChannels() async => _throw();

  @override
  Future<ChatChannelModel> getChannel(String channelId) async => _throw();

  @override
  Future<ChatChannelModel> createChannel(
    CreateChannelRequestModel request,
  ) async => _throw();

  @override
  Future<List<ChatMessageModel>> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async => _throw();

  @override
  Future<ChatMessageModel> sendMessage({
    required String channelId,
    required SendChatMessageRequestModel request,
  }) async => _throw();

  @override
  Future<ChatMessageModel> editMessage({
    required String messageId,
    required UpdateChatMessageRequestModel request,
  }) async => _throw();

  @override
  Future<ChatMessageModel> deleteMessage(String messageId) async => _throw();

  @override
  Future<MessageReadModel> markMessageRead(String messageId) async => _throw();

  @override
  Future<ChatChannelModel> addMember({
    required String channelId,
    required AddChannelMemberRequestModel request,
  }) async => _throw();

  @override
  Future<ChatChannelModel> removeMember({
    required String channelId,
    required String userId,
  }) async => _throw();
}
