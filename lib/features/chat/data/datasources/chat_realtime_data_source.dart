import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/network/api_client.dart';
import '../models/chat_models.dart';

/// Low-level SignalR ChatHub client. Token is supplied via [AccessTokenStore]
/// the same way [ApiClient] attaches Bearer headers.
abstract interface class ChatRealtimeDataSource {
  Future<void> connect();

  Future<void> disconnect();

  Future<void> subscribeChannel(String channelId);

  Future<void> unsubscribeChannel(String channelId);

  Future<void> startTyping(String channelId);

  Future<void> stopTyping(String channelId);

  Stream<ChatMessageModel> get messageCreated;

  Stream<ChatMessageModel> get messageUpdated;

  Stream<ChatMessageModel> get messageDeleted;

  Stream<TypingChangedModel> get typingChanged;

  Stream<PresenceChangedModel> get presenceChanged;
}

final class SignalRChatRealtimeDataSource implements ChatRealtimeDataSource {
  SignalRChatRealtimeDataSource({
    required this._tokenStore,
    String? hubUrl,
  }) : _hubUrl =
           hubUrl ??
           '${const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:5042')}/hubs/chat';

  final AccessTokenStore _tokenStore;
  final String _hubUrl;

  HubConnection? _connection;

  final _messageCreatedController =
      StreamController<ChatMessageModel>.broadcast();
  final _messageUpdatedController =
      StreamController<ChatMessageModel>.broadcast();
  final _messageDeletedController =
      StreamController<ChatMessageModel>.broadcast();
  final _typingChangedController =
      StreamController<TypingChangedModel>.broadcast();
  final _presenceChangedController =
      StreamController<PresenceChangedModel>.broadcast();

  @override
  Stream<ChatMessageModel> get messageCreated =>
      _messageCreatedController.stream;

  @override
  Stream<ChatMessageModel> get messageUpdated =>
      _messageUpdatedController.stream;

  @override
  Stream<ChatMessageModel> get messageDeleted =>
      _messageDeletedController.stream;

  @override
  Stream<TypingChangedModel> get typingChanged =>
      _typingChangedController.stream;

  @override
  Stream<PresenceChangedModel> get presenceChanged =>
      _presenceChangedController.stream;

  @override
  Future<void> connect() async {
    if (_connection != null &&
        _connection!.state == HubConnectionState.Connected) {
      return;
    }

    await disconnect();

    final httpOptions = HttpConnectionOptions(
      accessTokenFactory: () async {
        final token = await _tokenStore.read();
        return token ?? '';
      },
    );

    _connection = HubConnectionBuilder()
        .withUrl(_hubUrl, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    _connection!.on('messageCreated', _onMessageCreated);
    _connection!.on('messageUpdated', _onMessageUpdated);
    _connection!.on('messageDeleted', _onMessageDeleted);
    _connection!.on('typingChanged', _onTypingChanged);
    _connection!.on('presenceChanged', _onPresenceChanged);

    await _connection!.start();
  }

  @override
  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection == null) {
      return;
    }
    try {
      await connection.stop();
    } catch (_) {
      // Connection may already be closed.
    }
  }

  @override
  Future<void> subscribeChannel(String channelId) async {
    await _ensureConnected();
    await _connection!.invoke('SubscribeChannel', args: <Object>[channelId]);
  }

  @override
  Future<void> unsubscribeChannel(String channelId) async {
    if (_connection?.state != HubConnectionState.Connected) {
      return;
    }
    await _connection!.invoke('UnsubscribeChannel', args: <Object>[channelId]);
  }

  @override
  Future<void> startTyping(String channelId) async {
    await _ensureConnected();
    await _connection!.invoke('StartTyping', args: <Object>[channelId]);
  }

  @override
  Future<void> stopTyping(String channelId) async {
    await _ensureConnected();
    await _connection!.invoke('StopTyping', args: <Object>[channelId]);
  }

  Future<void> _ensureConnected() async {
    if (_connection == null ||
        _connection!.state != HubConnectionState.Connected) {
      await connect();
    }
  }

  void _onMessageCreated(List<Object?>? args) {
    final json = _asJsonMap(args);
    if (json != null) {
      _messageCreatedController.add(ChatMessageModel.fromJson(json));
    }
  }

  void _onMessageUpdated(List<Object?>? args) {
    final json = _asJsonMap(args);
    if (json != null) {
      _messageUpdatedController.add(ChatMessageModel.fromJson(json));
    }
  }

  void _onMessageDeleted(List<Object?>? args) {
    final json = _asJsonMap(args);
    if (json != null) {
      _messageDeletedController.add(ChatMessageModel.fromJson(json));
    }
  }

  void _onTypingChanged(List<Object?>? args) {
    final json = _asJsonMap(args);
    if (json != null) {
      _typingChangedController.add(TypingChangedModel.fromJson(json));
    }
  }

  void _onPresenceChanged(List<Object?>? args) {
    final json = _asJsonMap(args);
    if (json != null) {
      _presenceChangedController.add(PresenceChangedModel.fromJson(json));
    }
  }

  Map<String, dynamic>? _asJsonMap(List<Object?>? args) {
    if (args == null || args.isEmpty) {
      return null;
    }
    final first = args.first;
    if (first is Map<String, dynamic>) {
      return first;
    }
    if (first is Map) {
      return Map<String, dynamic>.from(first);
    }
    return null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messageCreatedController.close();
    await _messageUpdatedController.close();
    await _messageDeletedController.close();
    await _typingChangedController.close();
    await _presenceChangedController.close();
  }
}
