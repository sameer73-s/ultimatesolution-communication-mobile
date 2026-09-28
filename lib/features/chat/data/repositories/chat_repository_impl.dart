import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_channel.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/message_read.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_models.dart';

final class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<({List<ChatChannel>? channels, Failure? failure})> getChannels() async {
    try {
      final models = await _remote.getChannels();
      return (
        channels: [for (final model in models) model.toEntity()],
        failure: null,
      );
    } catch (error) {
      return (channels: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatChannel? channel, Failure? failure})> getChannel(
    String channelId,
  ) async {
    try {
      final model = await _remote.getChannel(channelId);
      return (channel: model.toEntity(), failure: null);
    } catch (error) {
      return (channel: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatChannel? channel, Failure? failure})> createChannel({
    required ChatChannelType type,
    String? name,
    required List<String> memberIds,
  }) async {
    try {
      final model = await _remote.createChannel(
        CreateChannelRequestModel(
          type: type.value,
          name: name,
          memberIds: memberIds,
        ),
      );
      return (channel: model.toEntity(), failure: null);
    } catch (error) {
      return (channel: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({List<ChatMessage>? messages, Failure? failure})> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async {
    try {
      final models = await _remote.getMessages(
        channelId: channelId,
        search: search,
        take: take,
      );
      return (
        messages: [for (final model in models) model.toEntity()],
        failure: null,
      );
    } catch (error) {
      return (messages: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatMessage? message, Failure? failure})> sendMessage({
    required String channelId,
    required String body,
  }) async {
    try {
      final model = await _remote.sendMessage(
        channelId: channelId,
        request: SendChatMessageRequestModel(body),
      );
      return (message: model.toEntity(), failure: null);
    } catch (error) {
      return (message: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatMessage? message, Failure? failure})> editMessage({
    required String messageId,
    required String body,
  }) async {
    try {
      final model = await _remote.editMessage(
        messageId: messageId,
        request: UpdateChatMessageRequestModel(body),
      );
      return (message: model.toEntity(), failure: null);
    } catch (error) {
      return (message: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatMessage? message, Failure? failure})> deleteMessage(
    String messageId,
  ) async {
    try {
      final model = await _remote.deleteMessage(messageId);
      return (message: model.toEntity(), failure: null);
    } catch (error) {
      return (message: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({MessageRead? read, Failure? failure})> markMessageRead(
    String messageId,
  ) async {
    try {
      final model = await _remote.markMessageRead(messageId);
      return (read: model.toEntity(), failure: null);
    } catch (error) {
      return (read: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatChannel? channel, Failure? failure})> addMember({
    required String channelId,
    required String userId,
  }) async {
    try {
      final model = await _remote.addMember(
        channelId: channelId,
        request: AddChannelMemberRequestModel(userId),
      );
      return (channel: model.toEntity(), failure: null);
    } catch (error) {
      return (channel: null, failure: _mapCaughtError(error));
    }
  }

  @override
  Future<({ChatChannel? channel, Failure? failure})> removeMember({
    required String channelId,
    required String userId,
  }) async {
    try {
      final model = await _remote.removeMember(
        channelId: channelId,
        userId: userId,
      );
      return (channel: model.toEntity(), failure: null);
    } catch (error) {
      return (channel: null, failure: _mapCaughtError(error));
    }
  }

  Failure _mapCaughtError(Object error) {
    if (error is Failure) {
      return error;
    }
    if (error is DioException && error.error is Failure) {
      return error.error! as Failure;
    }
    return const UnknownFailure();
  }
}
