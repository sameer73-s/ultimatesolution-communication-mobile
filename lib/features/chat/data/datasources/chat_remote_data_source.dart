import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/chat_models.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ChatChannelModel>> getChannels();

  Future<ChatChannelModel> getChannel(String channelId);

  Future<ChatChannelModel> createChannel(CreateChannelRequestModel request);

  Future<List<ChatMessageModel>> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  });

  Future<ChatMessageModel> sendMessage({
    required String channelId,
    required SendChatMessageRequestModel request,
  });

  Future<ChatMessageModel> editMessage({
    required String messageId,
    required UpdateChatMessageRequestModel request,
  });

  Future<ChatMessageModel> deleteMessage(String messageId);

  Future<MessageReadModel> markMessageRead(String messageId);

  Future<ChatChannelModel> addMember({
    required String channelId,
    required AddChannelMemberRequestModel request,
  });

  Future<ChatChannelModel> removeMember({
    required String channelId,
    required String userId,
  });
}

final class DioChatRemoteDataSource implements ChatRemoteDataSource {
  const DioChatRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<ChatChannelModel>> getChannels() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/api/v1/channels',
    );
    return _parseList(response, ChatChannelModel.fromJson);
  }

  @override
  Future<ChatChannelModel> getChannel(String channelId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/api/v1/channels/$channelId',
    );
    return _parseObject(response, ChatChannelModel.fromJson);
  }

  @override
  Future<ChatChannelModel> createChannel(
    CreateChannelRequestModel request,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/channels',
      data: request.toJson(),
    );
    return _parseObject(response, ChatChannelModel.fromJson);
  }

  @override
  Future<List<ChatMessageModel>> getMessages({
    required String channelId,
    String? search,
    int take = 50,
  }) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/api/v1/channels/$channelId/messages',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'take': take,
      },
    );
    return _parseList(response, ChatMessageModel.fromJson);
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String channelId,
    required SendChatMessageRequestModel request,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/channels/$channelId/messages',
      data: request.toJson(),
    );
    return _parseObject(response, ChatMessageModel.fromJson);
  }

  @override
  Future<ChatMessageModel> editMessage({
    required String messageId,
    required UpdateChatMessageRequestModel request,
  }) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      '/api/v1/messages/$messageId',
      data: request.toJson(),
    );
    return _parseObject(response, ChatMessageModel.fromJson);
  }

  @override
  Future<ChatMessageModel> deleteMessage(String messageId) async {
    final response = await _client.dio.delete<Map<String, dynamic>>(
      '/api/v1/messages/$messageId',
    );
    return _parseObject(response, ChatMessageModel.fromJson);
  }

  @override
  Future<MessageReadModel> markMessageRead(String messageId) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/messages/$messageId/read',
    );
    return _parseObject(response, MessageReadModel.fromJson);
  }

  @override
  Future<ChatChannelModel> addMember({
    required String channelId,
    required AddChannelMemberRequestModel request,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/channels/$channelId/members',
      data: request.toJson(),
    );
    return _parseObject(response, ChatChannelModel.fromJson);
  }

  @override
  Future<ChatChannelModel> removeMember({
    required String channelId,
    required String userId,
  }) async {
    final response = await _client.dio.delete<Map<String, dynamic>>(
      '/api/v1/channels/$channelId/members/$userId',
    );
    return _parseObject(response, ChatChannelModel.fromJson);
  }

  T _parseObject<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final payload = response.data ?? const <String, dynamic>{};
    if (payload['success'] != true ||
        payload['data'] is! Map<String, dynamic>) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 500,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    return fromJson(payload['data']! as Map<String, dynamic>);
  }

  List<T> _parseList<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final payload = response.data ?? const <String, dynamic>{};
    if (payload['success'] != true || payload['data'] is! List<dynamic>) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 500,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    final items = <T>[];
    for (final item in payload['data']! as List<dynamic>) {
      if (item is Map<String, dynamic>) {
        items.add(fromJson(item));
      }
    }
    return items;
  }
}
